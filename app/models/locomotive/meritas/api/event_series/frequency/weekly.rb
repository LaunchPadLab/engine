module Locomotive
  class Meritas::Api::EventSeries::Frequency::Weekly < Meritas::Api::EventSeries::Frequency

    def dates_from_frequency
      weekly_dates(1)
    end

  end
end