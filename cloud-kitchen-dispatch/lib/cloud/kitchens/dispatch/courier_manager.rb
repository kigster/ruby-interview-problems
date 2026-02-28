# frozen_string_literal: true

require_relative 'courier'

module Cloud
  module Kitchens
    module Dispatch
      class CourierManager
        attr_reader :couriers, :order_delivered_observers

        def initialize(courier_count: 5)
          @couriers = Array.new(courier_count) { |i| Courier.new("courier-#{i + 1}") }
          @order_delivered_observers = []
          @mutex = Mutex.new
        end

        def add_order_delivered_observer(observer)
          @order_delivered_observers << observer
          @couriers.each { |courier| courier.add_order_delivered_observer(observer) }
        end

        def dispatch_courier_for_order(order)
          courier = find_available_courier
          return nil unless courier

          courier.assign!

          # Simulate courier travel time (2-6 seconds)
          travel_time = rand(2..6)

          Thread.new do
            sleep(travel_time)
            pickup_order(courier, order)
          end

          courier
        end

        def pickup_order(courier, order)
          @mutex.synchronize do
            return unless courier.assigned? && order.aasm.current_state == :ready

            if courier.pickup(order)
              # Simulate delivery time (1-5 seconds after pickup)
              delivery_time = rand(1..5)

              Thread.new do
                sleep(delivery_time)
                deliver_order(courier)
              end
            end
          end
        end

        def deliver_order(courier)
          @mutex.synchronize do
            courier.deliver! if courier.delivering?
          end
        end

        def available_couriers
          @couriers.select(&:ready?)
        end

        def stats
          {
            total_couriers:      @couriers.size,
            ready_couriers:      available_couriers.size,
            assigned_couriers:   @couriers.count(&:assigned?),
            delivering_couriers: @couriers.count(&:delivering?)
          }
        end

        private

        def find_available_courier
          @couriers.find(&:ready?)
        end
      end
    end
  end
end
