# frozen_string_literal: true

class Courier
  attr_reader :id, :state, :assigned_order

  STATES = [:ready, :assigned, :delivering].freeze

  def initialize(id)
    @id = id
    @state = :ready
    @assigned_order = nil
  end

  def assign_order(order)
    return false unless @state == :ready

    @assigned_order = order
    @state = :assigned

    # Simulate random travel time (2-6 seconds)
    travel_time = rand(2.0..6.0)

    Thread.new do
      sleep(travel_time)
      pickup_order
    end

    true
  end

  def pickup_order
    return false unless @state == :assigned
    return false unless @assigned_order
    return false unless @assigned_order.state == :ready

    @assigned_order.pick_up!
    @state = :delivering

    # Simulate instant delivery (as per requirements)
    Thread.new do
      deliver_order
    end

    true
  end

  def deliver_order
    return false unless @state == :delivering
    return false unless @assigned_order

    @assigned_order.deliver!
    delivered_order = @assigned_order
    @assigned_order = nil
    @state = :ready

    delivered_order
  end

  def to_s
    "Courier(#{@id}, #{@state})"
  end
end
