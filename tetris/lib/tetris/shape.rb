# frozen_string_literal: true

require 'matrix'

require_relative 'point'

module Tetris
  class Shape
    WIDTH  = 4
    HEIGHT = 4

    attr_reader :matrix, :height, :width, :size, :cells

    def initialize(matrix: nil)
      if matrix.nil?
        @matrix = Matrix.build(HEIGHT, WIDTH) { 0 }
      end

      @height   = matrix.column_count
      @width    = matrix.row_count
      @size     = width * height
      @position = Point[0, 0]
      @cells    = matrix.to_a
    end

    def shift_by(dx, dy)
      @position = @position.shift_by(dx, dy)
    end

    def move_to(x, y)
      @position = @position.move_to(x, y)
    end

    def [](x, y)
      @cells[x, y]
    end

    def each_row(&block)
      @cells.each(&block)
    end

    def each_cell
      each_row do |y|
        row.each do |x|
          yield(self[x, y], Point[x, y])
        end
      end
    end

    def each_active_cell
      each_cell do |cell, point|
        yield(cell, point) if cell && cell != 0
      end
    end
  end
end
