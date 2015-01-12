module Locomotive
  class Meritas::Api::RecurringEvent

    attr_reader :event, :params

    def initialize(args = {})
      @event = args[:event]
      @params = args[:params]
    end

    def recurring_event_objects
      events = dates.map do |next_date|
        new_event = event.dup
        new_event.start_time = event.start_time + (next_date - event.start_time.to_date).to_i.days
        new_event.end_time = event.end_time + (next_date - event.end_time.to_date).to_i.days
        new_event
      end
      events
    end

    private

      def dates
        return [] unless end_date
        date = start_date
        dates = [start_date]

        # while date <= start
        #   date += (event.frequency * 7).days
        # end

        # raise date.inspect

        while date <= stop
          next_weekday = weekdays.detect {|d| d > date.wday}
          if next_weekday
            date += (next_weekday - date.wday).days
          else
            # go back to start of week then add frequency in days to get to next active day
            date -= date.wday - weekdays.first
            date += (event.frequency * 7).days
          end
          dates << date if date <= stop
        end
        return dates unless start
        dates.find_all {|d| d >= start }
      end

      def end_date
        Date.parse(params[:end_date])
      end

      def start
        Date.parse(params[:start_date])
      end

      def stop
        # earlier of stop date and range end date
        return end_date unless event.stop_date.present?
        event.stop_date <= end_date ? event.stop_date : end_date
      end

      def start_date
        event.start_time.to_date
        # weekdays.include?(event.start_time.to_date.wday) ? event.start_time.to_date : first_repeat_date
      end

      def weekdays
        event.weekdays.map(&:number)
      end

      def first_repeat_date
        # event.start_time.to_date
      end

  end
end