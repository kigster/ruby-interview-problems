# frozen_string_literal: true

class Order
  attr_accessor :shelf

  STATES = [:received, :cooking, :ready, :picked_up, :delivered, :expired].freeze

  def initialize(data)
    @id = data['id']
    @name = data['name']
    @temp = data['temp']
    @shelf_life = data['shelfLife'].to_f
    @decay_rate = data['decayRate'].to_f
    @created_at = Time.now
    @state = :received
    @shelf = nil
  end

  attr_reader :id, :name, :temp, :shelf_life, :decay_rate, :created_at, :shelf, :state

  def cook!
    return false unless @state == :received

    @state = :cooking
    true
  end

  def ready!
    return false unless @state == :cooking

    @state = :ready
    true
  end

  def pick_up!
    return false unless @state == :ready

    @state = :picked_up
    true
  end

  def deliver!
    return false unless @state == :picked_up

    @state = :delivered
    true
  end

  def expire!
    @state = :expired
    @shelf = nil
    true
  end

  def age
    Time.now - @created_at
  end

  def value(shelf_decay_modifier = 1)
    return 0.0 if @state == :expired

    numerator = shelf_life - (decay_rate * age * shelf_decay_modifier)
    (numerator / shelf_life).clamp(0.0, 1.0)
  end

  def expired?
    @state == :expired || value <= 0.0
  end

  def to_s
    "Order(#{@id[0..7]}, #{@name}, #{@temp}, age: #{age.round(2)}s, value: #{value.round(3)}, state: #{@state})"
  end
end
