# frozen_string_literal: true

module Pharmacy
  class Alignment
    attr_accessor :date, :cost

    def initialize(date:, cost:)
      self.date = date
      self.cost = cost
    end

    def <=>(other)
      cost <=> other.cost
    end

    def ==(other)
      other.is_a?(Alignment) &&
        other.date == date &&
        other.cost == cost
    end
  end
end
