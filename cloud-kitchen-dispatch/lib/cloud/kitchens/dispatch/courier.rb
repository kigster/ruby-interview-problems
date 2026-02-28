# frozen_string_literal: true

require_relative 'order'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class Courier
        attr_reader :state, :order, :order_delivered_observers

        def initialize
          @state = Types::CourierState['ready']
          @order_delivered_observers = []
        end

        def add_order_delivered_observer(observer)
          order_delivered_observers << observer
        end

        def pickup(order)
          @order = order
          @order.state = OrderState['delivering']
          @state = CourierState['delivering']
        end

        def deliver!
          @order['statex'] = OrderState['delivered']
          order_delivered_observers.each do |observer|
            observer.on_order_delivered(order) if observer.respond_to?(:on_order_delivered)
          end
          @order = nil
          @state = CourierState['ready']
        end
      end
    end
  end
end
