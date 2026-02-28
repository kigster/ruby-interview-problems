# frozen_string_literal: true

module ExcelColumnIndex
  class << self
    def included(base)
      base.instance_eval do
        class << self
          attr_reader :columns

          def excel_columns=(range_or_array)
            @columns = range_or_array.to_a
          end
        end
      end
    end
  end

  def to_excel_column(number = self)
    if number < 1
      ''
    else

      cols = self.class.columns
      base = cols.size

      to_excel_column((number - 1) / base) + cols[(number - 1) % base]

    end
  end
end
