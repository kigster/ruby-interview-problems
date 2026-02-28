# frozen_string_literal: true

module Pharmacy
  class Inventory
    attr_accessor :medication_id, :quantity

    def initialize(medication_id:, quantity: 0)
      self.medication_id = medication_id
      self.quantity = quantity
    end

    def medication
      @medication ||= Medication.find_by_id(medication_id)
    end
  end
end
