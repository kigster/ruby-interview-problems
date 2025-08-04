require "forwardable"
require "io/console"
require_relative "point"
require_relative "line"
module Fractional
  module Ai
    class Ui
      attr_reader :board, :rows, :left, :top

      CELL_WIDTH = 3
      CELL_HEIGHT = 1

      extend Forwardable
      def_delegators :@board, :width, :height, :rows

      # @description
      # @param [Board] board
      # @param [Point] left_top_coordinate
      # @param [Array<Line>] lines can be passed in ahead of time
      def initialize(board:, left_top_coordinate: nil, lines: [])
        @board = board

        left_top_coordinate ||= Point.new(board.width / 2, board.height / 2)
        @left = left_top_coordinate.x
        @top = left_top_coordinate.y

        @lines = lines
      end

      def run
        render_container!

        if @lines.any?
          @lines.each do |line|
            board.add_line(line)
            render(board)
          end
        else
          while true
            render(board)
            board.add_line(get_next_line)
          end
        end
      end

      def size
        width * height
      end

      private

      def get_next_line
        p1 = get_next_point(for_what: "beginning of the line")
        p2 = get_next_point(for_what: "end of the line")
        move_cursor_to(left, top + height + 9)
        print "Adding the line with coordinates: [#{p1} -> #{p2}]".cyan
        Line.new(p1, p2)
      end

      def get_next_point(for_what: "beginning of the line")
        move_cursor_to(-1, top + height + 3)
        puts (" " * left) + "Please enter coordinates for the #{for_what},".yellow.bold
        puts (" " * left) + "comma separated as in X, Y where 0 <= X < #{width - 1} and so is Y.".yellow.bold
        puts (" " * left) + "For example: entering 5,10 means column 5 and row 10, or q or Q to exit: ".yellow.bold
        print((" " * left) + "[          ]".blue)
        move_cursor_left(10)

        $stdin.sync = true
        values = $stdin.gets.chomp

        %w[q Q].include?(values) ? exit(0) : values.strip

        unless values.match?(/^[\d,]*$/)
          raise Errors::InvalidCoordinates, "Coordinates must be integers!"
        end

        x, y, = values.split(",")
        if x.nil? || y.nil?
          raise Errors::InvalidCoordinates, "Empty coordinates!"
        end

        x = x.to_i
        y = y.to_i

        if x < 0 || x >= width || y < 0 || y >= height
          raise Errors::InvalidCoordinates, "Coordinates out of bounds."
        end

        move_cursor_left(10)
        move_cursor_up(1)
        move_cursor_right(left + (width * CELL_WIDTH))
        check!
        highlight_board_at(x, y)
        Point.new(x, y)
      rescue Errors::Error => e
        show_error(e.message)
        retry
      end

      def show_error(message)
        horizontal_shift = left
        offset = " " * horizontal_shift
        move_cursor_left(horizontal_shift)
        move_cursor_to(horizontal_shift, top / 2)
        puts offset + "ERROR: ".red
        puts offset + message.red.bold
        while true
          sleep 0.1
          puts offset + "Press any key to continue..."
          break if STDIN.getch
        end
      end

      def render(board)
        board.rows.each_with_index do |row, row_index|
          move_cursor_to(left + 2, top + row_index + 1)
          row.each_with_index do |_cell, cell_index|
            print board.rows[row_index][cell_index]
          end
          puts
        end
      end

      def render_container!
        clear!
        move_cursor_to(left - 1, top - 1)
        print("0,0")
        move_cursor_to(left, top)
        horizontal_border_top
        height.times do |row_index|
          vertical_border(row_index, side: :left)
          vertical_border(row_index, side: :right)
        end
        move_cursor_to(left, top + height + 1)
        horizontal_border_bottom
      end

      def horizontal_border_top
        move_cursor_to(left, top)
        print "┌"
        print "─" * ((CELL_WIDTH * width) + 2)
        print "┐"
        puts
      end

      def horizontal_border_bottom
        move_cursor_to(left, top + height + 1)
        print "└"
        print "─" * ((CELL_WIDTH * width) + 2)
        print "┘"
        puts
      end

      def vertical_border(row_index, side:)
        if side == :left
          move_cursor_to(left, top + row_index + 1)
          print "│ "
        elsif side == :right
          move_cursor_to(left + (CELL_WIDTH * width) + 1, top + row_index + 1)
          print "  │"
        end
      end

      def check!
        print " ✔︎ ".white.on.green
      end

      def highlight_board_at(x, y)
        move_to_board_at(x + 1, y)
        print OCCUPIED.green
        sleep 0.3
        move_to_board_at(x + 1, y)
        print OCCUPIED.yellow
        sleep 0.3
        move_to_board_at(x + 1, y)
        print OCCUPIED.red.bold
      end

      def move_to_board_at(x, y)
        x = left + (x * CELL_WIDTH) - 1
        y = top + 1 + (y * CELL_HEIGHT)
        move_cursor_to(x, y)
      end

      def move_cursor_to(x, y)
        x += 1
        y += 1
        print "\033[#{y};#{x}H"
      end

      def move_cursor_left(by)
        printf "\033[#{by}D"
      end

      def move_cursor_right(by)
        printf "\033[#{by}C"
      end

      def move_cursor_up(by)
        printf "\033[#{by}A"
      end

      def move_cursor_down(by)
        printf "\033[#{by}B"
      end

      def clear!
        system("clear")
      end
    end
  end
end
