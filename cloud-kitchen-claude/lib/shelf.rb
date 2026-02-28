# frozen_string_literal: true

require_relative 'order'

class Shelf
  attr_reader :temperature, :capacity, :orders

  def initialize(temperature:, capacity:)
    @temperature = temperature
    @capacity = capacity
    @orders = []
  end

  def full?
    @orders.length >= @capacity
  end

  def can_accept?(order)
    return true if @temperature == 'any'

    @temperature == order.temp
  end

  def add_order(order)
    return false if full?
    return false unless can_accept?(order)

    @orders << order
    order.shelf = self
    true
  end

  def remove_order(order)
    if @orders.delete(order)
      order.shelf = nil
      true
    else
      false
    end
  end

  def decay_modifier
    @temperature == 'any' ? 2 : 1
  end

  def update_order_values!
    expired_orders = []
    @orders.each do |order|
      if order.value(decay_modifier) <= 0
        expired_orders << order
      end
    end

    expired_orders.each do |order|
      remove_order(order)
      order.expire!
    end

    expired_orders.length
  end

  def find_movable_order(target_shelf)
    @orders.find { |order| target_shelf.can_accept?(order) && !target_shelf.full? }
  end

  def to_s
    "Shelf(#{@temperature}, #{@orders.length}/#{@capacity})"
  end
end
