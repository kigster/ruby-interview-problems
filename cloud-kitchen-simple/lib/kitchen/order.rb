# frozen_string_literal: true

module Kitchen
  module Types
    # noinspection RubyResolve,RubyParenthesesAfterMethodCallInspection
    include ::Dry.Types()

    # noinspection RubyConstantNamingConvention
    Temperature = String.enum('hot', 'frozen', 'cold')
  end

  # Order class is a both: a JSON import hash, and new metadata
  # to define order's movement through various states.
  #
  # When the order is prepared, it is placed on a shelf. When it is picked
  # up, it is removed from the shelf. The order value is computed only while
  # the order is on the shelf, and is undefined otherwise.
  #
  class Order < ::Dry::Struct
    transform_keys(&:to_sym)

    attribute :id, Types::String
    attribute :name, Types::String
    attribute :temp, Types::Temperature
    attribute :shelfLife, Types::Integer
    attribute :decayRate, Types::Float

    # noinspection RubyResolve
    alias shelf_life shelfLife
    # noinspection RubyResolve
    alias decay_rate decayRate

    attr_reader :number,
                :received_at,
                :prepared_at,
                :picked_up_at

    attr_accessor :shelf

    def initialize(*)
      super
      @received_at = now
      @shelf       = nil
    end

    def move_to(target_shelf)
      unless target_shelf.fits?(self)
        raise ArgumentError, "Target shelf #{target_shelf.name} " \
                             "does not fit #{temperature} order, it's size " \
                             "is #{target_shelf.size}"
      end

      shelf&.remove(self)

      target_shelf << self
      self.shelf = target_shelf
    end

    def receive!
      @received_at = now
    end

    def place_on_shelf!(shelf)
      @shelf = shelf
      prepare! unless prepared_at
    end

    def pick_up!
      @picked_up_at = now
      @shelf        = nil
    end

    def prepare!
      @prepared_at = now
    end

    def order_value
      raise ArgumentError, "Order value can only be computed while it's on the shelf." if shelf.nil?

      value = (shelf_life.to_f - (age.to_f * decay_rate * shelf&.coefficient)).to_f / shelf_life
      value = 0 if value < 0
      value
    end

    # @return [Boolean] true if the value is zero
    def worthless?
      order_value <= 0
    end

    # @return [Symbol] :hot, :cold, :frozen - symbol version of the temperature
    def temperature
      # noinspection RubyResolve
      temp&.to_sym
    end

    # @return [Float] number of seconds since the order has been received
    def age
      now - received_at
    end

    # @return [Float] number of seconds since the order was prepared
    def shelf_age
      now - prepared_at
    end

    # @return [String] representation of the Order
    def to_s
      "Order #{name} ordered @ #{Time.at(received_at).strftime('%T.%L')}"
    end

    alias inspect to_s

    # @param [Order] other order to compare to, used in sorting.
    def <=>(other)
      order_value <=> other.order_value
    end

    def pretty_inspect
      indent = "\n  "
      "Order<[#{id}] " \
        "#{indent}id ➔ #{id.green} " \
        "#{indent}name ➔ #{(sprintf '%-20.20s', name).green} " \
        "#{indent}temp ➔ #{(sprintf '%-7s', temp).green} " \
        "#{indent}decay ➔ #{(sprintf '%07.2f', decay_rate).green} " \
        "#{indent}sh/life ➔ #{(sprintf '%07d', shelf_life).green} " \
        "#{indent}age (secs) ➔ #{(sprintf '%04.2f', age).cyan}" \
        "#{indent}value ➔ " \
        "#{(sprintf '%04.2f', order_value).send(order_value > 0 ? :cyan : :red)}" \
        "\n>"
    end

    # noinspection RubyStringKeysInHashInspection
    def to_h
      {
        'id' => id,
        'name' => name,
        'decay_rate' => decay_rate,
        'shelf_life' => shelf_life,
        'order_value' => order_value
      }
    end

    protected

    # Helper, returns the current time as a floating point epoc number.
    #
    # @return [Float] EPOCH time as a floating point number
    def now
      Time.now.to_f
    end
  end
end
