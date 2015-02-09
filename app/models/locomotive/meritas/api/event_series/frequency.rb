module Locomotive
  class Meritas::Api::EventSeries::Frequency

    attr_reader :event_series, :base_event
    attr_accessor :event_start_date, :date_range_start, :date_range_stop, :current_date, :dates

    def initialize(args = {})
       @event_series = args[:event_series]
       @base_event = @event_series.event
       @event_start_date = event_series.event_start_date
       @date_range_start = event_series.date_range_start
       @date_range_stop = event_series.date_range_stop
       @current_date = event_start_date
    end

      # GENERATE ALL RECURRING EVENT DATES

    def dates_needed
      @dates_needed ||= generate_dates
    end

    private


      def generate_dates
        @dates = [event_start_date]

        while @current_date < date_range_start
          @current_date += 1.day
        end

        dates_from_frequency

        return @dates unless date_range_start
        @dates = @dates.find_all {|d| d >= date_range_start }
      end


      def weekly_dates(freq_in_weeks)
        while @current_date <= @date_range_stop
          next_weekday = @event_series.weekdays.detect {|d| d > @current_date.wday}
          if next_weekday
            @current_date += (next_weekday - @current_date.wday).days
          else
            # go back to start of week then add frequency in days to get to next active day
            @current_date -= (@current_date.wday - @event_series.weekdays.first).days
            @current_date += (freq_in_weeks * 7).days
          end
          @dates << @current_date if @current_date <= @date_range_stop
        end
      end

  end
end