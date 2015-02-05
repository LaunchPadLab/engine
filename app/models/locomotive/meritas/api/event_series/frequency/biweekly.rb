module Locomotive
  class Meritas::Api::EventSeries::Frequency::Biweekly < Meritas::Api::EventSeries::Frequency

    def dates_from_frequency
      weekly_dates(2)
    end

  end
end