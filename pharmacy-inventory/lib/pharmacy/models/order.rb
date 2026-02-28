# frozen_string_literal: true

require_relative 'upcoming_inventory'

module Pharmacy
  class Order
    attr_accessor :ordered_medications, :date

    def initialize(inventories = [])
      inventories.each do |inv|
        add(medication: inv.medication, quantity: inv.quantity)
      end
      self.date = Time.now
    end

    def add(medication:, quantity:)
      self.ordered_medications ||= []
      self.ordered_medications << { medication: medication, quantity: quantity }
    end

    def can_fulfill_on
      Time.now
    end

    def submit!; end
  end
end
