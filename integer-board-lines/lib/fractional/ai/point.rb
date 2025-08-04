# frozen_string_literal: true

module Fractional
  module Ai
    # Represents a point on the board with x and y coordinates
    #
    # @example Creating a new point
    #   point = Point.new(5, 10)
    #   puts point.to_s  # => "5,10"
    #
    # @author Fractional AI
    # @since 0.1.0
    class Point
      attr_reader :x, :y

      # Initialize a new Point with x and y coordinates
      #
      # @param x [Integer] the x coordinate
      # @param y [Integer] the y coordinate
      def initialize(x, y)
        @x = x
        @y = y
      end

      # Converts the point to a string representation
      #
      # @return [String] formatted as "x,y"
      # @example
      #   Point.new(5, 10).to_s  # => "5,10"
      def to_s
        "#{x},#{y}"
      end

      # Validates that the point has valid coordinates
      #
      # @return [Boolean] true if coordinates are non-negative integers
      # @example
      #   Point.new(5, 10).valid?   # => true
      #   Point.new(-1, 5).valid?   # => false
      #   Point.new(5.5, 10).valid? # => false
      def valid?
        x.is_a?(Integer) && y.is_a?(Integer) &&
          x >= 0 && y >= 0
      end

      # Equality comparison
      #
      # @param other [Point] another point to compare with
      # @return [Boolean] true if both points have the same coordinates
      def ==(other)
        other.is_a?(Point) && x == other.x && y == other.y
      end

      # Hash method for use in hashes and sets
      #
      # @return [Integer] hash value based on coordinates
      def hash
        [x, y].hash
      end

      # Alias for equality
      alias eql? ==
    end
  end
end