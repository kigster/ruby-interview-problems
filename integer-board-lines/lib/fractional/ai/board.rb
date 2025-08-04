# frozen_string_literal: true

module Fractional
  module Ai
    # Represents the drawing board/canvas for ASCII art lines
    #
    # The Board class manages the 2D grid where lines are drawn.
    # It handles line registration, rendering, and maintains the
    # visual representation of all drawn lines with color coding.
    #
    # @example Creating and using a board
    #   board = Board.new(width: 10, height: 10)
    #   line = Line.new(Point.new(0, 0), Point.new(5, 5))
    #   board.add_line(line)
    #
    # @author Fractional AI
    # @since 0.1.0
    class Board
      include Calc

      # @return [Integer] the width of the board
      attr_reader :width
      # @return [Integer] the height of the board
      attr_reader :height
      # @return [Array<Array<String>>] 2D array representing the board grid
      attr_reader :rows
      # @return [Array<Line>] array of all lines added to the board
      attr_reader :lines

      # Initializes a new board with specified dimensions
      #
      # @param width [Integer] the width of the board (default: 20)
      # @param height [Integer] the height of the board (default: 20)
      # @example
      #   board = Board.new(width: 15, height: 10)
      def initialize(width: 20, height: 20)
        @width = width
        @height = height
        @rows = Array.new(height) { EMPTY }
        @lines = []
        @rows.each_with_index do |_row, index|
          @rows[index] = Array.new(width) { EMPTY }
        end
      end

      # Adds a line to the board and renders it
      #
      # Validates the line and registers it on the board grid.
      # The line will be visually represented with color coding.
      #
      # @param line [Line] the line to add to the board
      # @raise [Errors::MissingArguments] if line is nil or invalid
      # @example
      #   line = Line.new(Point.new(0, 0), Point.new(5, 5))
      #   board.add_line(line)
      def add_line(line)
        raise Errors::MissingArguments, "Either line or p1 and p2 must be provided" if line.nil?
        raise Errors::MissingArguments, "Line is not valid!" unless line.valid?

        @lines << line
        register_line(line)
      end

      # Calculates the total size of the board
      #
      # @return [Integer] the total number of cells (width * height)
      # @example
      #   Board.new(width: 10, height: 5).size  # => 50
      def size
        width * height
      end

      private

      # Registers a line on the board grid with visual representation
      #
      # This method handles the actual drawing of the line on the board:
      # - Endpoints are marked in cyan
      # - Vertical lines are drawn in green
      # - Horizontal lines are drawn in yellow
      # - Diagonal lines are drawn in red using line equation
      #
      # @param line [Line] the line to register on the board
      # @private
      def register_line(line)
        # Mark endpoints

        register_dot(line.p1.x, line.p1.y, line.color)
        register_dot(line.p2.x, line.p2.y, line.color)

        # Draw vertical lines
        if line.min_x == line.max_x
          (line.min_y..line.max_y).each do |y|
            register_dot(line.min_x, y, line.color)
          end
        elsif line.min_y == line.max_y
          (line.min_x..line.max_x).each do |x|
            register_dot(x, line.min_y, line.color)
          end
        else
          dx = line.p1.x > line.p2.x ? -1 : 1
          dy = line.p1.y > line.p2.y ? -1 : 1

          (line.p1.x..line.p2.x).step(dx).each do |x|
            (line.p1.y..line.p2.y).step(dy).each do |y|
              next unless y == line.function(x)

              register_dot(x, y, line.color)
            end
          end
        end
      end

      def valid_coordinates?(x, y)
        x.is_a?(Integer) && y.is_a?(Integer) &&
          x >= 0 && y >= 0 && x < width && y < height
      end

      def register_dot(x, y, color)
        @rows[y][x] = OCCUPIED.send(color) if valid_coordinates?(x, y)
      end
    end
  end
end
