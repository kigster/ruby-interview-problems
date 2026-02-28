# frozen_string_literal: true

require_relative 'inventory'

module Pharmacy
  class UpcomingInventory < Inventory
    attr_accessor :date

    def initialize(date:, **)
      super(**)
      self.date = date
    end
  end
end
