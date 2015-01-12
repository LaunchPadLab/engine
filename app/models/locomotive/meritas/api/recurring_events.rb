module Locomotive
  class Meritas::Api::RecurringEvents

    attr_accessor :events, :params

    def initialize(args = {})
      @events = args[:events]
      @params = args[:params]
    end

    def generate
      filter_by_stop_date if params[:start_date].present?
      generate_recurring_events
    end

    private

      # DATE RANGE
      def filter_by_stop_date
        # we don't want events that have a stop date prior to beginning of requested date range.
        # for example, if we are looking for all February events, any recurring event that stops
        # in January would not be included.
        start_date = Date.parse(params[:start_date])
        @events = @events.or({:stop_date => nil}, {:stop_date.gte => start_date})
      end

      def generate_recurring_events
        @events.map {|event| Locomotive::Meritas::Api::RecurringEvent.new(event: event, params: params).recurring_event_objects }.flatten
      end

  end
end