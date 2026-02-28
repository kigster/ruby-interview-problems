# frozen_string_literal: true

require_relative 'medication'
module Pharmacy
  class Prescription
    attr_accessor :medication,
                  :last_dispense_date,
                  :next_billable_date,
                  :days_supply

    def initialize(hash)
      hash.each_pair do |key, value|
        send("#{key}=", value)
      end
    end

    def cost_to_pharmacy(day)
      exact_cost_to_pharmacy(day).round(2)
    end

    private

    def end_of_supply
      last_dispense_date + days_supply
    end

    def day_cost
      medication.price.to_f / days_supply
    end

    def exact_cost_to_pharmacy(day)
      return day_cost * (day - end_of_supply) if day > end_of_supply

      return 0 if day >= next_billable_date

      day_cost * (day + CYCLE - end_of_supply)
    end
  end
end
