# frozen_string_literal: true

#  __  __ _
# |  \/  (_)_ __   ___ _____      _____  ___ _ __   ___ _ __
# | |\/| | | '_ \ / _ / __\ \ /\ / / _ \/ _ | '_ \ / _ | '__|
# | |  | | | | | |  __\__ \\ V  V |  __|  __| |_) |  __| |
# |_|  |_|_|_| |_|\___|___/ \_/\_/ \___|\___| .__/ \___|_|
#                                           |_|
#
# Example game: http://minesweeperonline.com/
#
# Concepts:
#   1. The game is played on a board of cells
#     - Some cells randomly contain bombs
#     - All cells begin the game in a hidden state
#
#   2. Cells are selected to be revealed
#     - If a bomb cell is revealed - Game over!
#     - Otherwise, the cell becomes visible, revealing how many bombs surround that cell
#       - If no bombs surround the selected cell, expand adjacent cells that are not
#         surrounded by bombs either
#
# Ruby is the preferred language for this challenge
#
# 1) What data structures do you think would be appropriate to track the board and cells?
# 2) What would this look like in pseudocode?
# 3) Implementation time! Let's see how far we get, together, in the time we have

require 'stringio'
require 'rspec'

class Board
  attr_reader :rows, :columns, :bombs, :size
  attr_accessor :matrix, :vis

  BOMB = :b

  # @param [Object] r rows
  # @param [Object] c columns
  # @param [Object] b bombs
  def initialize(r, c, b)
    @rows    = r
    @columns = c
    @bombs   = b

    @size   = @rows * @columns
    @matrix = Array.new(size) { nil }
    @vis    = Array.new(size) { nil }

    raise ArgumentError("Not enough empty cells") if @bombs > @size

    bombs_away!
    compute_counts!
  end

  def to_s
    s = StringIO.new
    rows.times do |r|
      s.puts
      columns.times do |c|
        i = (r * columns) + c
        if matrix[i] == BOMB
          s.printf "%s", "BM "
        elsif matrix[i].nil?
          s.print "__ "
        else
          s.printf "%2d ", matrix[i]
        end
      end
    end
    s.string
  end

  def print_board
    puts self
  end

  def make_move(x, y)
    raise 'Game over' if self[x, y] == BOMB
  end

  def [](x, y = nil)
    if y.nil?
      matrix[x]
    else
      matrix[(y * columns) + x]
    end
  end

  private

  def compute_counts!
    rows.times do |y|
      columns.times do |x|
        compute_cell!(x, y)
      end
    end
  end

  def compute_cell!(x, y)
    return if self[x, y] == BOMB

    delta = [-1, 0, 1]
    bombs = 0
    delta.each do |x_delta|
      delta.each do |y_delta|
        next if x_delta == 0 && y_delta == 0

        x1 = x + x_delta
        y1 = y + y_delta
        next if x1 < 0 || y1 < 0 || x1 >= columns || y1 >= rows

        bombs += 1 if self[x1, y1] == BOMB
      end
    end
    matrix[(y * columns) + x] = bombs
  end

  def bombs_away!
    bombs.times do
      index = nil
      loop do
        index = rand(size)
        break if matrix[index].nil?
      end
      matrix[index] = BOMB
    end
  end
end

#############################################
# 0  1  1  1  0  0  0  1  1  1  0  1 BM  1  0
# 0  1 BM  2  1  1  1  2 BM  1  0  2  2  2  0
# 0  1  2 BM  1  1 BM  4  3  2  0  1 BM  1  0
# 1  1  2  1  1  2  3 BM BM  1  0  1  1  1  0
# 1 BM  1  0  0  1 BM  3  2  1  0  0  0  0  0
# 1  1  1  0  0  1  1  1  0  0  0  0  0  0  0
# 0  0  0  0  0  0  0  0  0  0  0  0  1  1  1
# 0  0  0  0  0  0  0  0  0  0  0  1  2 BM  1
# 0  0  0  0  0  0  0  0  0  0  0  1 BM  2  1
# 0  0  0  0  0  0  0  0  0  0  0  1  1  1  0

class MineSweeperUI
  def run!
    raise "No Board class present" unless defined?(Board)

    @rows    = 10
    @columns = 15
    @bombs   = 12

    @board = Board.new(@rows, @columns, @bombs)

    raise "No print_board method present on Board!" unless @board.methods.include?(:print_board)

    @board.print_board

    raise "No make_move method present on Board!" unless @board.methods.include?(:make_move)
  end
end
