# frozen_string_literal: true

require_relative 'shelf'

class ShelfManager
  attr_reader :shelves, :overflow_shelf

  def initialize
    @shelves = {
      'hot' => Shelf.new(temperature: 'hot', capacity: 10),
      'cold' => Shelf.new(temperature: 'cold', capacity: 10),
      'frozen' => Shelf.new(temperature: 'frozen', capacity: 10)
    }
    @overflow_shelf = Shelf.new(temperature: 'any', capacity: 15)
  end

  def place_order(order)
    # Try preferred temperature shelf first
    target_shelf = @shelves[order.temp]
    if target_shelf&.add_order(order)
      return { shelf: target_shelf, action: :placed_on_temp_shelf }
    end

    # Try overflow shelf
    if @overflow_shelf.add_order(order)
      return { shelf: @overflow_shelf, action: :placed_on_overflow }
    end

    # Overflow is full - try to move an existing order from overflow to make room
    moved_order = try_move_from_overflow
    if moved_order && @overflow_shelf.add_order(order)
      return {
        shelf: @overflow_shelf,
        action: :placed_on_overflow_after_move,
        moved_order: moved_order
      }
    end

    # No room anywhere - discard random order from overflow
    discarded_order = discard_random_from_overflow
    if discarded_order && @overflow_shelf.add_order(order)
      return {
        shelf: @overflow_shelf,
        action: :placed_on_overflow_after_discard,
        discarded_order: discarded_order
      }
    end

    # Complete failure
    order.expire!
    { shelf: nil, action: :order_wasted }
  end

  def remove_order(order)
    return false unless order.shelf

    shelf = order.shelf
    shelf.remove_order(order)
  end

  def update_all_shelves!
    total_expired = 0
    all_shelves.each do |shelf|
      total_expired += shelf.update_order_values!
    end
    total_expired
  end

  def all_orders
    all_shelves.flat_map(&:orders)
  end

  def shelf_contents
    result = {}
    @shelves.each do |temp, shelf|
      result[temp] = shelf.orders.dup
    end
    result['overflow'] = @overflow_shelf.orders.dup
    result
  end

  def stats
    {
      hot: @shelves['hot'].orders.length,
      cold: @shelves['cold'].orders.length,
      frozen: @shelves['frozen'].orders.length,
      overflow: @overflow_shelf.orders.length,
      total: all_orders.length
    }
  end

  private

  def all_shelves
    @shelves.values + [@overflow_shelf]
  end

  def try_move_from_overflow
    # Try to move an order from overflow to its preferred shelf
    @overflow_shelf.orders.each do |order|
      target_shelf = @shelves[order.temp]
      next unless target_shelf && !target_shelf.full? && target_shelf.can_accept?(order)

      @overflow_shelf.remove_order(order)
      target_shelf.add_order(order)
      return order
    end
    nil
  end

  def discard_random_from_overflow
    return nil if @overflow_shelf.orders.empty?

    random_order = @overflow_shelf.orders.sample
    @overflow_shelf.remove_order(random_order)
    random_order.expire!
    random_order
  end
end
