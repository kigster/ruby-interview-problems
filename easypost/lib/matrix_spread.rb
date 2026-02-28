# frozen_string_literal: true

module EasyPost
  class MatrixSpread
    attr_accessor :data, :check_proc

    def initialize(data = [])
      self.data = data

      rows = data.size
      cols = data.first.size

      self.check_proc = ->(row, col) do
        if row < 0 || col < 0 || row > rows - 1 || col > cols - 1
          nil
        else
          data[row][col]
        end
      end
    end

    def shift
      data.map(&:dup).tap do |shifted_data|
        data.each_with_index do |row, row_idx|
          row.each_with_index do |cell, col_idx|
            next if cell == 1

            [[-1, 0], [0, 1], [1, 0], [0, -1]].each do |shift|
              if check_proc[row_idx + shift[0], col_idx + shift[1]] == 1
                shifted_data[row_idx][col_idx] = 1
                next
              end
            end
          end
        end
      end
    end
  end
end
