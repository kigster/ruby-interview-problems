# frozen_string_literal: true

module Kitchen
  class Courier
    attr_reader :order_id, :thread, :observers

    def initialize(order_id, observers: [])
      @observers = Set.new
      observers.each { |o| @observers << o }

      @order_id      = order_id
      @dispatched_at = Time.now
      @picked_up_at  = nil

      @thread = Thread.new do
        COURIER_WAIT[] # sleep

        pick_up_and_deliver!
      end
    end

    def join
      thread.join
    end

    def pick_up_and_deliver!
      log_order_event(:delivered, order_id, %i[bold white on green], arg: " ✅ ")

      observers.each { |o| o.order_was_picked_up(order_id) }
    end
  end
end
