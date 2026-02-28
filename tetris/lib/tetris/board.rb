# frozen_string_literal: true

require 'forwardable'
require 'matrix'

module Tetris
  class Board
    HEIGHT = 20
    WIDTH  = 10

    # Board is a 1-dimensional array representing W x H board.
    # First W elements is the first row.
    attr_accessor :cells, :width, :height, :matrix

    extend Forwardable

    def_delegators :cells, :each, :map, :each_with_index

    # Allow initializing from another Matrix, or a two-dimensional array.
    def initialize(matrix_or_array = nil)
      @matrix = if matrix_or_array.nil?
                  Matrix.build(HEIGHT, WIDTH) { 0 }
                elsif matrix_or_array.is_a?(Matrix)
                  matrix_or_array
                elsif matrix_or_array.is_a?(Array) && matrix_or_array.first.is_a?(Array)
                  Matrix[*matrix_or_array]
                end

      unless @matrix.instance_of?(Matrix)
        raise ArgumentError, "matrix argument is meant to be a Matrix instance, got #{matrix_or_array.class.name}"
      end

      @width  = @matrix.column_count
      @height = @matrix.row_count
    end

    def [](x, y)
      matrix[x, y]
    end

    def size
      width * height
    end

    def each_row(&block)
      matrix.to_a.each(&block)
    end

    def add_piece(piece, at = nil)
      # add at the top left corner
      # check if we are able to add
    end

    # Returns true if the piece overlaps with the an existing piece
    # or is out of bounds
    def collides?(_piece)
      false
    end
  end
end
