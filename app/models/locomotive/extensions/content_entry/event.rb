module Locomotive
  module Extensions
    module ContentEntry
      module Event
        extend ActiveSupport::Concern

        included do
          validate :recurring_event_fields, if: :event_series?
          validate :unique_color, if: :has_color?

          after_create      :generate_event_series, if: :event_series?
          after_update      :propagate_event_series_changes, if: :event_series?
          before_update     :disconnect_from_series, if: :part_of_event_series?
          before_destroy    :delete_children, if: :event_series?
        end

        def event_series?
          content_type.slug == "events" && respond_to?(:recurring) && recurring
        end

        def part_of_event_series?
          content_type.slug == "events" && parent_id.present?
        end

        def hex_color
          return nil unless content_type.slug == "events"
          return function.color.hex if function && function.color
          nil
        end

        private

          # FUNCTION COLORS

          def has_color?
            content_type.slug == "functions" && respond_to?(:color)
          end

          def unique_color
            return unless color.present?
            if content_type.entries.where(color: color).count > 0
              errors.add(:color, "is already in use by another category.")
            end
          end


          # EVENT SERIES

          def generate_event_series
            Locomotive::Meritas::Api::EventSeries.new(event: self).create
          end

          def propagate_event_series_changes
            Locomotive::Meritas::Api::EventSeries.new(event: self).update
          end

          def disconnect_from_series
            self.parent_id = nil
          end

          def recurring_event_fields
            require_events_frequency
            require_stop_date
            if frequency == "Daily"
              require_daily_frequency_fields
            elsif frequency == "Weekly" || frequency == "Biweekly"
              require_weekly_frequency_fields
            elsif frequency == "Monthly"
              require_monthly_frequency_fields
            else
              errors.add(:frequency, "is invalid")
            end
          end

          def require_stop_date
            unless stop_date && stop_date > start_time.to_date
              errors.add(:formatted_stop_date, "required for repeating events and must be greater than the start date")
            end
          end

          def require_events_frequency
            unless frequency
              errors.add(:frequency, "required for repeating events")
            end
          end

          def require_daily_frequency_fields
            # there are no daily frequency fields at this time
          end

          def require_weekly_frequency_fields
            # days of week to repeat
            unless weekdays && weekdays.count >= 1
              errors.add(:weekdays, "required for an event that repeats on a weekly or biweekly basis.")
            end
          end

          def require_monthly_frequency_fields
            unless monthly_type.present?
              errors.add(:monthly_type, "required for an event that repeats on a monthly basis.")
            end
            if monthly_type == "By day of week"
              require_monthly_day_of_week_fields
            end
          end

          def require_monthly_day_of_week_fields
            unless monthly_week.present?
              errors.add(:monthly_week, "required for an event that repeats on a monthly basis based on the day of the week.")
            end
            unless monthly_week.present?
              errors.add(:weekday, "required for an event that repeats on a monthly basis based on the day of the week.")
            end
          end

          def delete_children
            children.each {|c| c.destroy }
          end

      end
    end
  end
end