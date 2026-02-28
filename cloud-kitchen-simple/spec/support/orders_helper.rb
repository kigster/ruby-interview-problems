# frozen_string_literal: true

require 'spec_helper'

module Kitchen
  module OrdersHelper
    ORDERS_FIXTURE_FILE = File.expand_path('../fixtures/orders.json', __dir__).freeze

    def order_hashes
      @order_hashes ||= JSON.parse(File.read(ORDERS_FIXTURE_FILE))
    end

    def orders
      @orders = order_hashes.map { |o| Order.new(**o) }
    end

    def order
      @order ||= orders.first
    end

    def each_order(range = nil, &)
      range ? orders[range].each(&) : orders.each(&)
    end

    def hot_shelf
      @hot_shelf ||= HotShelf.new(capacity: 1)
    end

    def cold_shelf
      @cold_shelf ||= ColdShelf.new(capacity: 1)
    end

    def frozen_shelf
      @frozen_shelf ||= FrozenShelf.new(capacity: 1)
    end

    def overflow_shelf
      @overflow_shelf ||= OverflowShelf.new(capacity: 2)
    end

    def shelves
      [hot_shelf, cold_shelf, frozen_shelf, overflow_shelf]
    end

    def each_shelf(&)
      shelves.each(&)
    end
  end
end
