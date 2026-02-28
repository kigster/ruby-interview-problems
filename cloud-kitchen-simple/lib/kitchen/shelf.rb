# frozen_string_literal: true

require 'forwardable'
require 'set/sorted_set'

module Kitchen
  class ShelfFullError < StandardError; end

  class Shelf
    class << self
      attr_accessor :default_shelf_capacity, :default_overflow_capacity
    end

    self.default_shelf_capacity    = 10
    self.default_overflow_capacity = 15

    attr_reader :orders, :coefficient

    attr_accessor :capacity

    extend Forwardable

    def_delegators :@orders, :size, :each, :map
    include Enumerable

    def initialize(coefficient: 1,
                   capacity: Shelf.default_shelf_capacity)
      self.capacity = capacity
      @coefficient  = coefficient
      @orders       = SortedSet.new
    end

    # Adds order to this shelf.
    #
    # @raise [ArgumentError] when the shelf is already full.
    # @param [Order] order to add
    def <<(order)
      if full?
        raise ArgumentError, "Shelf #{self} is full."
      end

      unless accepts?(order)
        raise ArgumentError,
              "Shelf can not accept this order temperature: #{order.temperature}, shelf: #{temperature}"
      end

      order.shelf = self
      orders << order
    end

    # Removes an order from the Shelf by order_id
    #
    # @param [String, Order] order an ID of the order or an actual order
    # @return [Order, NilClass] either the order deleted or nil
    # @raise [TypeError] if argument is not a String or an Order
    def remove(order)
      order_id = Kitchen.order_id(order)
      orders.reject! { |o| o.id == order_id }
      order.shelf = nil
    end

    # @param [Order] order to check
    # @return [TrueClass, FalseClass] true if this shelf can accept this order
    def fits?(order)
      accepts?(order) && open?
    end

    # @param [Order] order to check
    # @return [TrueClass, FalseClass] true if this shelf can accept this order
    def accepts?(order)
      order.temperature == temperature
    end

    # @return [TrueClass, FalseClass] true if there are no orders on this shelf, false otherwise
    def empty?
      orders.empty?
    end

    # @return [TrueClass, FalseClass] true if there is not more room for orders
    def full?
      orders.size >= capacity
    end

    def open?
      !full?
    end

    # @returns [String] name lowercase temperature specification of this shelf,  eg "hot", "frozen", "overflow"
    def name
      @name ||= self.class.name.gsub(/.*::/, '').gsub(/Shelf$/, '').downcase
    end

    # @returns [Symbol] symbol representation of the shelf's name
    def temperature
      @temperature ||= name.to_sym
    end
  end

  class HotShelf < Shelf; end

  class ColdShelf < Shelf; end

  class FrozenShelf < Shelf; end

  class OverflowShelf < Shelf
    def initialize(capacity: Shelf.default_overflow_capacity,
                   coefficient: 2)
      super
    end

    # @param [Order] _order to check
    # @return [TrueClass, FalseClass] true if this shelf can accept this order
    def accepts?(_order)
      true
    end
  end
end
