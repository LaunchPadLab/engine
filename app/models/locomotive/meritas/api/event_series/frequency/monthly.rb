module Locomotive
  class Meritas::Api::EventSeries::Frequency::Monthly < Meritas::Api::EventSeries::Frequency

    DAY_OF_WEEK_OPTIONS = {
      "First" => 0,
      "Second" => 1,
      "Third" => 2,
      "Fourth" => 3,
      "Last" => nil
    }

    def dates_from_frequency
      if base_event.monthly_type == "By day of week"
        generate_by_day_of_week
      else
        generate_by_date
      end

    end

    private

      def generate_by_date
        while @current_date <= date_range_stop
          @current_date += 1
          @dates << @current_date if @current_date.mday == event_start_date.mday
        end
      end

      def generate_by_day_of_week
        # week: first, second, third, fourth, last
        # day: monday, tuesday, wednesday, thursday, friday, saturday, sunday
        @current_date = @current_date.end_of_month + 1.day
        while @current_date <= date_range_stop
          @current_date += 1
          @dates << @current_date if current_date_matches?
        end
      end

      def current_date_matches?
        return false unless weekday_matches?
        week_matches?
      end

      def weekday_matches?
        @current_date.wday == day_num
      end

      def week_matches?
        if last_week?
          currently_last_week?
        else
          current_week_num == week_num
        end
      end

      def last_week?
        base_event.monthly_week == "Last"
      end

      def currently_last_week?
        @current_date >= (@current_date.end_of_month - 7.days)
      end

      def current_week_num
        (@current_date.mday / 7.0).ceil - 1
      end

      def week_num
        DAY_OF_WEEK_OPTIONS[base_event.monthly_week]
      end

      def day_num
        base_event.weekday.number
      end

  end
end