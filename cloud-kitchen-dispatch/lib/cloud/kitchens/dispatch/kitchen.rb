# frozen_string_literal: true

require 'dry-initializer'
require 'dry-struct'

require_relative 'types'
require_relative 'order'

module Cloud
  module Kitchens
    module Dispatch
      class Kitchen
        attr_accessor :orders, :order_prepared_observers

        def initialize
          @order_prepared_observers = []
          @orders = Set.new
        end

        def add_order_prepared_observer(observer)
          @order_prepared_observers << observer
        end

        def complete_order!
          return if orders.empty?

          order = orders.pop
          order_prepared_observers.each do |observer|
            observer.on_order_prepared(order) if observer.respond_to?(:on_order_prepared)
          end
        end
      end
    end
  end
end
