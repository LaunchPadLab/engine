module Locomotive
  class Meritas::Api::EventSeries::Frequency::Daily < Meritas::Api::EventSeries::Frequency

      def dates_from_frequency
        while current_date <= date_range_stop
          current_date += 1.day
          dates << current_date if current_date <= date_range_stop
        end
      end

  end
end