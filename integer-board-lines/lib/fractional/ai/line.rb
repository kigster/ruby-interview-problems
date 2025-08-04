# frozen_string_literal: true

module Fractional
  module Ai
    # Represents a line on the board defined by two points
    #
    # A line connects two points and can be drawn on the board.
    # It supports horizontal, vertical, and diagonal lines with
    # optional color specification.
    #
    # @example Creating a line
    #   p1 = Point.new(0, 0)
    #   p2 = Point.new(5, 5)
    #   line = Line.new(p1, p2, color: :red)
    #
    # @author Fractional AI
    # @since 0.1.0
    class Line
      include Calc

      # @return [Point] the first point of the line
      attr_reader :p1
      # @return [Point] the second point of the line
      attr_reader :p2
      # @return [Integer] the minimum x coordinate of the line
      attr_reader :min_x
      # @return [Integer] the maximum x coordinate of the line
      attr_reader :max_x
      # @return [Integer] the minimum y coordinate of the line
      attr_reader :min_y
      # @return [Integer] the maximum y coordinate of the line
      attr_reader :max_y
      # @return [Symbol] the color of the line
      attr_reader :color
      # @return [Symbol] the color of the line
      attr_reader :coefficient

      # Initializes a new line with two points and optional color
      #
      # @param p1 [Point] the first point of the line
      # @param p2 [Point] the second point of the line
      # @param color [Symbol, nil] optional color for the line (defaults to :white)
      # @example
      #   line = Line.new(Point.new(0, 0), Point.new(5, 5), color: :red)
      def initialize(p1, p2, color: :green)
        @p1 = p1
        @p2 = p2
        @color = color || :greene

        raise ArgumentError, "p1 and p2 can not be nil" if p1.nil? || p2.nil?
        raise ArgumentError, "Both points must be Point objects" unless p1.is_a?(Point) && p2.is_a?(Point)

        @coefficient = calculate_coefficient

        @min_x = min(p1.x, p2.x)
        @max_x = max(p1.x, p2.x)

        @min_y = min(p1.y, p2.y)
        @max_y = max(p1.y, p2.y)
      end

      # Returns the bounding box of the line as two points
      #
      # @return [Array<Point>] array containing the top-left and bottom-right points
      # @example
      #   line.bounding_box  # => [Point.new(0, 0), Point.new(5, 5)]
      def bounding_box
        [
          Point.new(min_x, min_y),
          Point.new(max_x, max_y),
        ]
      end

      # Validates that the line has valid points
      #
      # @return [Boolean] true if both points are valid Point objects
      # @example
      #   line.valid?  # => true
      def valid?
        p1.is_a?(Point) && p2.is_a?(Point) &&
          p1.valid? && p2.valid?
      end

      # Calculates the Euclidean distance between the two points
      #
      # @return [Float] the length of the line
      # @example
      #   Line.new(Point.new(0, 0), Point.new(3, 4)).length  # => 5.0
      def length
        Math.sqrt(((p2.x - p1.x)**2) + ((p2.y - p1.y)**2))
      end

      # Calculates the slope coefficient of the line
      #
      # @return [Float] the slope of the line, or Float::INFINITY for vertical lines
      # @example
      #   Line.new(Point.new(0, 0), Point.new(2, 2)).coefficient  # => 1.0
      #   Line.new(Point.new(0, 0), Point.new(0, 5)).coefficient  # => Float::INFINITY
      def calculate_coefficient
        return Float::INFINITY if p2.x == p1.x

        (p2.y - p1.y).to_f / (p2.x - p1.x).to_f
      end

      def function(x)
        return Float::INFINITY if p2.x == p1.x

        y = (coefficient * (x - p1.x)) + p1.y
        y.to_i
      end
    end
  end
end
