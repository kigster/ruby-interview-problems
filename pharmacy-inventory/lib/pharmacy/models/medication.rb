# frozen_string_literal: true

module Pharmacy
  class Medication
    @medications = {}

    class << self
      attr_accessor :medications
    end

    attr_accessor :id, :name, :price

    def initialize(id:, name:, price:)
      self.id    = id
      self.name  = name
      self.price = price

      Medication.medications[id] = self
    end

    def self.find_by_id(medication_id)
      medications[medication_id]
    end

    def to_hash
      {
        id: id,
        name: name,
        price: price
      }
    end
  end
end
