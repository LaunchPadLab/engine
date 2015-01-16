module Locomotive
  class Meritas::Api::EventSeries

    attr_reader :event, :params
    attr_accessor :end_date, :date_range_start, :date_range_stop, :events

    NON_PROPAGATED_ATTRIBUTES = ["_id", "_position", "_visible", "position_in_function", "position_in_group", "position_in_grade", "position_in_venue", "start_time", "end_time", "parent_id", "_slug", "version", "model_name", "updated_at", "created_at", "_type", "content_type_id", "site_id", "_translated", "__label_field_name", "recurring"]


    # REQUIRED FIELDS: event
    # OPTIONAL FIELDS: params[:end_date], params[:start_date] (date range to limit event generation)
    def initialize(args = {})
      @event = args[:event]
      @params = args.fetch(:params, {})
      @end_date = set_end_date
      @date_range_start = set_date_range_start
      @date_range_stop = set_date_range_stop
    end


    # PUBLIC METHODS

    def create
      generate_events_from_dates.each {|e| e.save }
    end

    def update
      delete_events_no_longer_needed
      update_children
      create_new_events
    end


    private

      # SET VARIABLES / DEFAULTS

      def default_end_date
        Date.today + 1.year
      end

      def default_start_date
        Date.today
      end

      def set_end_date
        return default_end_date unless params[:end_date]
        Date.parse(params[:end_date]) || default_end_date
      end

      def set_date_range_start
        return default_start_date unless params[:start_date]
        Date.parse(params[:start_date]) || default_start_date
      end

      def set_date_range_stop
        # earlier of stop date and range end date
        return end_date unless event.stop_date.present?
        event.stop_date <= end_date ? event.stop_date : end_date
      end

      def event_start_date
        @event_start_date ||= event.start_time.to_date
      end

      def weekdays
        @weekdays ||= event.weekdays.map(&:number)
      end


      # GENERATE ALL RECURRING EVENT DATES

      def dates
        @dates ||= (
          date = event_start_date
          dates = [event_start_date]

          while date < date_range_start
            date += 1.day
          end

          while date <= date_range_stop
            next_weekday = weekdays.detect {|d| d > date.wday}
            if next_weekday
              date += (next_weekday - date.wday).days
            else
              # go back to start of week then add frequency in days to get to next active day
              date -= date.wday - weekdays.first
              date += (event.frequency * 7).days
            end
            dates << date if date <= date_range_stop
          end
          return dates unless date_range_start
          dates.find_all {|d| d >= date_range_start }
        )
      end


      # GENERATE NON-SAVED EVENT OBJECTS

      def generate_events_from_dates(dates = dates)
        events = dates.map do |next_date|
          new_event = event.dup
          new_event.start_time = event.start_time + (next_date - event.start_time.to_date).to_i.days
          new_event.end_time = event.end_time + (next_date - event.end_time.to_date).to_i.days
          new_event.parent = event
          new_event.recurring = false
          new_event
        end
        events
      end


      # FIND MISSING AND UNNEEDED EVENTS (FOR UPDATING SERIES)

      def missing_dates
        @missing_dates ||= (
          dates - event.children.map {|e| e.start_time.to_date }
        )
      end

      def events_no_longer_needed
        @events_no_longer_needed ||= (
          event.children.find_all {|e| dates.exclude?(e.start_time.to_date) }
        )
      end


      # PROPAGATING EVENT SERIES CHANGES

      def delete_events_no_longer_needed
        events_no_longer_needed.each {|e| e.destroy }
      end

      def create_new_events
        generate_events_from_dates(missing_dates).each {|e| e.save }
      end

      def update_children
        event.class.skip_callback(:update, :before, :disconnect_from_series)
        event.content_type.entries.where(parent_id: event._id).each do |child|
          event.attributes.each do |attr, value|
            child.send("#{attr}=", value) unless NON_PROPAGATED_ATTRIBUTES.include?(attr)
          end
          # update start date times and both end date and end date times
          child.start_time = DateTime.new(child.start_time.year, child.start_time.month, child.start_time.day, event.start_time.hour, event.start_time.minute)
          duration_days = (event.end_time.to_date - event.start_time.to_date).to_i
          end_date = child.start_time.to_date + duration_days.days
          child.end_time = DateTime.new(end_date.year, end_date.month, end_date.day, event.end_time.hour, event.end_time.minute)
          child.save
        end
      end

  end
end