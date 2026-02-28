# frozen_string_literal: true

require_relative 'shelf'
require_relative 'types'

module Cloud
  module Kitchens
    module Dispatch
      class ShelfManager
        attr_reader :shelves, :overflow_shelf

        def initialize
          @shelves = {}
          Types::Temperature.each_value do |temp|
            @shelves[temp] = Shelf.new(temperature: temp)
          end
          @overflow_shelf = Shelf.new(temperature: nil, overflow: true)
        end

        def place_order(order)
          target_shelf = @shelves[order.temperature]

          if target_shelf.add_order(order)
            target_shelf
          elsif @overflow_shelf.add_order(order)
            @overflow_shelf
          else
            order.expire!
            nil
          end
        end

        def remove_order(order)
          order.shelf&.remove_order(order)
        end

        def update_all_orders!
          all_shelves.each(&:update_order_values!)
        end

        def all_orders
          all_shelves.flat_map { |shelf| shelf.orders.to_a }
        end

        def ready_orders
          all_orders.select { |order| order.aasm.current_state == :ready }
        end

        def stats
          {
            total_orders:   all_orders.size,
            ready_orders:   ready_orders.size,
            hot_shelf:      @shelves['hot'].orders.size,
            cold_shelf:     @shelves['cold'].orders.size,
            frozen_shelf:   @shelves['frozen'].orders.size,
            overflow_shelf: @overflow_shelf.orders.size
          }
        end

        private

        def all_shelves
          @shelves.values + [@overflow_shelf]
        end
      end
    end
  end
end
