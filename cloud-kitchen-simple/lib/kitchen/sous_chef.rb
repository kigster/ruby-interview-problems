# frozen_string_literal: true

# rubocop: disable
module Kitchen
  class DuplicateOrderError < StandardError; end

  class SousChef
    attr_reader :order_received_wait, :cooked_orders, :completed_orders, :couriers, :orders, :cabinet, :threads

    class << self
      attr_accessor :instance
    end

    def initialize
      @cooked_orders    = ThreadSafeHash.new
      @completed_orders = ThreadSafeHash.new
      @courier_orders   = ThreadSafeHash.new
      @couriers         = ThreadSafeArray.new
      @cond_var         = ConditionVariable.new
      @threads          = []
      @cabinet          = Cabinet.cabinet

      self.class.instance = self
    end

    def fulfill!
      @threads << start_cooking_orders
      @threads.map(&:join)
      @couriers.map(&:join)
    end

    def load_orders_from(orders_file)
      log_info "attempting to load and parse file", orders_file
      @orders = JSON.parse(File.read(orders_file)).tap do |orders|
        log_info "number of orders loaded:", orders.size
      end
      self
    end

    def order_was_picked_up(order_id)
      if cabinet.order?(order_id)
        order = cabinet.remove_order(order_id)
        order&.pick_up!
      else
        log_order_event(:refund, order_id, %i[black on yellow bold], arg: ' ❌ Unavailable to Courier for delivery')
      end
    end

    def cook_order(order_hash)
      order = Order.new(order_hash)
      if cooked_orders[order.id]
        raise DuplicateOrderError, "Order ID #{order.id} has already been received."
      end

      # not sure how this works in real life, but in this version of the "matrix"
      # we cook instantaneously :)
      cooked_orders[order.id] = order

      # shove the order shelf one of the shelves
      cabinet << order

      # dispatch as courier to come pick it up
      dispatch_courier(order)

      # prepare the order
      order.prepare!

      log_order_is_ready(order)
    end

    private

    def dispatch_courier(order)
      courier = Courier.new(order.id, observers: [self])

      @courier_orders[order.id] ||= courier
      @couriers << courier
    end

    def start_cooking_orders
      Thread.new do
        orders.each do |order|
          cook_order(order)

          # pause for processing of the incoming orders
          ORDER_RECEIVED_WAIT[]
        end
      end
    end

    def log_order_is_ready(order)
      log_order_event(:ready, order, %i[yellow on black bold], arg: ' ✔ ')
    end
  end
end
