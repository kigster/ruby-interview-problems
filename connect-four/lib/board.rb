# frozen_string_literal: true

module ConnectFour
  class Board
    COLOR_RED   = 'X '
    COLOR_BLACK = 'O '
    COLOR_NIL   = '. '

    attr_accessor :board_state

    COLS = 7
    ROWS = 6

    def initialize
      self.board_state = []
      COLS.times do
        board_state << Array.new(ROWS) { COLOR_NIL }
      end
    end

    def place_piece(column_index, color)
      first_empty_index = next_empty_slot(column_index)
      raise ArgumentError, "Column #{column_index} is full" if first_empty_index.nil?

      board_state[column_index][first_empty_index] = color
    end

    def check_winner; end

    def print_board
      puts self
    end

    def to_s
      out = StringIO.new
      ROWS.times do |row|
        COLS.times do |col|
          out.print board_state[col][row]
        end
        out.puts
      end
      yield(out) if block_given?
      out.string
    end

    def next_empty_slot(column_index)
      index = board_state[column_index].find_index { |e| !e.eql?(COLOR_NIL) }
      if index && index > 0
        return index - 1
      elsif index.nil?
        return ROWS - 1
      end

      nil
    end
  end
end
