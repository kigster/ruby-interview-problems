# frozen_string_literal: true

require 'json'

module Pharmacy
  class OrdersController
    class << self
      def earliest_available(order)
        { date: order.can_fulfill_on }.to_json
      end

      def place(order)
        order.submit!
      end
    end
  end
end
