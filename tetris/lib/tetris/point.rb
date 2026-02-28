# frozen_string_literal: true

require 'matrix'

module Tetris
  class Point
    ROTATIONS = [
      Matrix[[+0, -1], [+1, +0]], #  90º
      Matrix[[-1, +0], [+0, -1]], # 180º
      Matrix[[+0, +1], [-1, +0]], # 270º
    ].freeze

    class << self
      def [](x, y)
        Point.new(x, y)
      end
    end

    attr_reader :x, :y

    def shift_by(dx, dy)
      Point[x + dx, y + dy]
    end

    def move_to(x1, y1)
      Point[x1, y1]
    end

    def rotate_right(count = 1)
      rotate(count, ROTATIONS.first)
    end

    def rotate_left(count = 1)
      rotate(count, ROTATIONS.last)
    end

    def rotate(count, rotation_matrix)
      coords = [x, y]
      count.times do
        coords = (Matrix[[*coords]] * rotation_matrix).to_a.first
      end
      Point[*coords]
    end

    def eql?(other)
      other.is_a?(Point) &&
        other.x == x &&
        other.y == y
    end

    alias == eql?

    private

    # @param [int] x columns
    # @param [int] y rows
    def initialize(x, y)
      @x = x
      @y = y
    end
  end
end
