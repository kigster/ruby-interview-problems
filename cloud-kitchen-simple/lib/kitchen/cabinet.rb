# frozen_string_literal: true

# noinspection RubyYardReturnMatch

require_relative 'shelf'
require 'forwardable'

module Kitchen
  # This class manages the data structure that defines
  # the association of Orders ready to be picked up, and the
  # appropriate shelves these orders are placed on while they
  # wait for the courier to pick them up.
  #
  # The four shelves are created once per instance, and remain
  # in memory, as a mutable data structure that contains a set of
  # orders.
  #
  # Cabinet additionally provides convenient lookups by order_id,
  # and manages all of the business logic related to moving orders
  # between shelves.
  #
  # This class offers two methods that rely on mutex synchronization
  # to protect mutations across multiple threads (couriers). Each
  # invocation of #add_order and  #remove_order runs inside a mutex
  # lock. Other public methods are not protected by the lock.
  class Cabinet
    class DuplicateOrder < StandardError; end

    # Singleton Class methods for convenience.
    class << self
      # @return [Cabinet] cabinet created with all the shelves.
      def cabinet
        @cabinet ||= create_cabinet
      end

      private

      def create_cabinet
        new(create_shelves)
      end

      def create_shelves
        [
          HotShelf,
          ColdShelf,
          FrozenShelf,
          OverflowShelf
        ].map(&:new)
      end
    end

    extend Forwardable

    # @def_delegators [Integer] size - total number of orders on the shelves
    def_delegators :@orders, :size

    # @attr_reader [Array<Shelf>] shelves on which orders are placed.
    attr_reader :shelves

    # @attr_reader [Array<String>] array of order IDs that have been trashed
    attr_reader :orders_trashed

    # @attr_reader [Hash<String,Order>] orders hash that maps order_ids to orders
    attr_reader :orders

    # @attr_reader [Hash<Order,Shelf>] orders to shelves hash
    attr_reader :orders_to_shelves

    # @attr_reader [Mutex] mutex lock
    attr_reader :mutex

    def initialize(shelves = [])
      @shelves                 = shelves
      @order_trashed_observers = Set.new
      @orders_to_shelves       = ThreadSafeHash.new
      @orders_trashed          = ThreadSafeArray.new
      @orders                  = ThreadSafeHash.new
      @mutex                   = Mutex.new
    end

    # Add an order to the cabinet, and make room by trashing an old
    # order if necessary. Make sure the order is on the appropriate shelf,
    # matching its temperature.
    #
    # @param [Order] order to be placed on one of the shelves
    def add_order(order)
      raise DuplicateOrder, order.id if orders_to_shelves.key?(order.id)

      synchronize do
        # Make room in the cabinet, if possible.
        #
        # NOTE: calling this during #add_order is more efficient than
        # running a background thread to periodically clean up space,
        # because we will benefit from any expired order immediately.
        remove_trashed_orders!

        find_shelf(order).tap { |shelf| place(order, shelf: shelf) }
      end
    end

    alias << add_order

    # Removes the order from the cabinet, and disassociates the order from
    # any shelf it may have been placed on.
    #
    # @param [Order, String] order or order_id to be removed
    def remove_order(order)
      id = must_have_order(order)

      synchronize do
        order = orders[id] unless order.is_a?(Order)
        order.shelf&.remove(order)
        orders_to_shelves.delete(id)
        orders.delete(id)
      end
    end

    # @return [Integer] number of available order slots across all shelves
    def total_capacity
      shelves.map(&:capacity).sum
    end

    # @return [Integer] number of remaining order slots across all shelves
    def remaining_capacity
      total_capacity - orders.size
    end

    # @return [TrueClass,FalseClass] true if all slots are occupied at the moment
    def full?
      remaining_capacity <= 0
    end

    # @param [Symbol] type of shelf to look up eg, :hot
    # @return [Object<Shelf] a shelf based on a type
    def shelf(type)
      shelves.find { |s| s.temperature == type.to_s.downcase.to_sym }
    end

    def [](order_id)
      orders[order_id]
    end

    # @param [Order, String] order or order_id to look up
    # @return [TrueClass,FalseClass] true if cabinet contains this order
    def order?(order)
      orders.key?(Kitchen.order_id(order))
    end

    protected

    def on_order_trashed_notify(observer)
      @order_trashed_observers << observers if observer.respond_to?(:on_order_trashed)
    end

    # Wraps possible internal mutations in a mutex's synchronize call,
    # also, properly handles recursive calls to #synchronize as well.
    def synchronize(&block)
      if mutex.locked?
        block.call
      else
        mutex.synchronize(&block)
      end
    end

    private

    # Removes any order that have reached a certain age.
    def remove_trashed_orders!
      orders.values.select(&:worthless?).tap do |worthless_orders = []|
        log_info("Removing #{worthless_orders.size} expired orders") unless worthless_orders.empty?
        worthless_orders.each { |o| remove_order(o) }
      end
    end

    # @return [Array<Symbol>] array of temperatures, eg [:hot, :cold, ...]
    def shelve_types
      # noinspection RubyYardReturnMatch
      shelves.map(&:temperature)
    end

    # Finds a shelf for an order and places it there, while
    # possibly removing an older order from one of the shelves
    #
    # @param [Order] order
    # @return [Shelf,NilClass] proper_shelf with space to add the order to
    # noinspection RubyYardReturnMatch
    def find_shelf(order)
      proper_shelf = [shelf(order.temperature), overflow_shelf].find(&:open?)

      proper_shelf ||
        (find_space_for_overflow! && overflow_shelf) ||
        (make_room! && overflow_shelf)
    end

    # This method rearranges things in the cabinet, either throwing some orders away
    # or moving them between shelves.
    def make_room!
      overflow_shelf.orders.to_a[rand(overflow_shelf.size)].tap do |throw_away_order|
        log_order_event(:trashed, throw_away_order, %i[bold white on red])
        remove_order(throw_away_order)
      end
    end

    def find_space_for_overflow!
      shelves.select(&:open?).each do |potential_shelf|
        next if potential_shelf.is_a?(OverflowShelf)

        order_to_move = overflow_shelf.orders.find { |o| potential_shelf.accepts?(o) }
        next unless order_to_move

        log_order_event(:moved, order_to_move, %i[white on magenta bold], arg: "moving to #{potential_shelf.temperature} shelf.")
        order_to_move.move_to(potential_shelf)
        orders_to_shelves[order_to_move.id] = potential_shelf

        return true
      end

      false
    end

    # Associates the order with a given shelf.
    #
    # @param [Order] order to place on the shelf
    # @param [Shelf] shelf the shelf
    def place(order, shelf:)
      shelf << order
      orders_to_shelves[order.id] = shelf
      orders[order.id]            = order
    end

    def overflow_shelf
      @overflow_shelf ||= shelf(:overflow)
    end

    def other_shelves(order)
      other_shelf_types = shelve_types - [order.temperature, :overflow]
      shelves.select { |shelf| other_shelf_types.include?(shelf.temperature) }
    end

    def must_have_order(order)
      Kitchen.order_id(order).tap do |id|
        raise ArgumentError, "No order id #{id} found!" unless orders.key?(id)
      end
    end
  end
end

# rubocop: enable Metrics/ClassLength
