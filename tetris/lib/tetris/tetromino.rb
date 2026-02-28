# frozen_string_literal: true

require_relative 'point'
require_relative 'shape'

module Tetris
  class Tetromino < Shape
    class << self
      def [](type)
        PIECES[type]
      end

      def types
        PIECES.keys
      end
    end

    PIECES = {
      L: new(matrix: Matrix[
                         [0, 1, 0],
                         [0, 1, 0],
                         [0, 1, 1]
                     ]),
      J: new(matrix: Matrix[
                           [0, 1, 0],
                           [0, 1, 0],
                           [1, 1, 0]
                       ]),
      T: new(matrix: Matrix[
                           [0, 1, 0],
                           [0, 1, 1],
                           [0, 1, 1]
                       ]),
      O: new(matrix: Matrix[
                           [1, 1],
                           [1, 1]
                       ]),
      I: new(matrix: Matrix[
                           [0, 0, 0, 0],
                           [1, 1, 1, 1],
                           [0, 0, 0, 0],
                           [0, 0, 0, 0],
                       ]),
    }.freeze
  end
end
