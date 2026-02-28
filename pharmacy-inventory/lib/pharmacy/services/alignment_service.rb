# frozen_string_literal: true

require_relative '../models/alignment'
require_relative '../models/prescription'

module Pharmacy
  CYCLE = 28

  class AlignmentService
    attr_accessor :prescriptions

    def initialize(prescriptions)
      self.prescriptions = prescriptions
    end

    # earliest day across
    def smallest_value(attribute)
      prescriptions.map{ |p| p.send(attribute) }.min
    end

    def earliest_last_dispense_date
      @earliest_last_dispense_date ||= smallest_value(:last_dispense_date)
    end

    def earliest_end_of_supply
      @earliest_end_of_supply ||= smallest_value(:end_of_supply)
    end

    def cost_for(day)
      prescriptions.map do |p|
        p.cost_to_pharmacy(day)
      end.sum
    end

    def alignment_date
      ((earliest_end_of_supply)..(earliest_end_of_supply + CYCLE)).map do |day|
        cost = cost_for(day)
        Alignment.new(date: day, cost: cost)
      end.min
    end
  end
end
