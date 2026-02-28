# frozen_string_literal: true

require 'excel_column'
require 'spec_helper'

Integer.instance_eval do
  include ExcelColumnIndex
end

RSpec.describe Integer do
  shared_examples :excel_column_name do |expected_excel_header|
    it "should map to #{expected_excel_header}" do
      expect(subject.to_excel_column).to eq(expected_excel_header)
    end
  end

  describe '26-Base System' do
    before do
      Integer.excel_columns = ('A'..'Z')
    end

    # @formatter:off
    describe( 1) { it_behaves_like :excel_column_name,  'A' }
    describe( 2) { it_behaves_like :excel_column_name,  'B' }
    describe( 3) { it_behaves_like :excel_column_name,  'C' }
    describe(24) { it_behaves_like :excel_column_name,  'X' }
    describe(25) { it_behaves_like :excel_column_name,  'Y' }
    describe(26) { it_behaves_like :excel_column_name,  'Z' }

    describe(27) { it_behaves_like :excel_column_name, 'AA' }
    describe(28) { it_behaves_like :excel_column_name, 'AB' }
    describe(51) { it_behaves_like :excel_column_name, 'AY' }
    describe(52) { it_behaves_like :excel_column_name, 'AZ' }
    describe(53) { it_behaves_like :excel_column_name, 'BA' }
    describe(54) { it_behaves_like :excel_column_name, 'BB' }
    # @formatter:on
  end

  describe '3-Base System' do
    before do
      Integer.excel_columns = ('A'..'C')
    end

    # @formatter:off
    describe( 1) { it_behaves_like :excel_column_name,   'A' } # 1 => 000 => 0 base 3
    describe( 2) { it_behaves_like :excel_column_name,   'B' } # 2 => 001 => 1 base 3
    describe( 3) { it_behaves_like :excel_column_name,   'C' } # 3 => 002 => 2 base 3

    describe( 4) { it_behaves_like :excel_column_name,  'AA' } # 4 =>
    describe( 5) { it_behaves_like :excel_column_name,  'AB' } # 5
    describe( 6) { it_behaves_like :excel_column_name,  'AC' } # 6

    # 6 / 3 = 2

    describe( 7) { it_behaves_like :excel_column_name,  'BA' }
    describe( 8) { it_behaves_like :excel_column_name,  'BB' }
    describe( 9) { it_behaves_like :excel_column_name,  'BC' }

    describe(10) { it_behaves_like :excel_column_name,  'CA' }
    describe(11) { it_behaves_like :excel_column_name,  'CB' }
    describe(12) { it_behaves_like :excel_column_name,  'CC' }

    describe(13) { it_behaves_like :excel_column_name, 'AAA' }
    describe(14) { it_behaves_like :excel_column_name, 'AAB' }
    describe(15) { it_behaves_like :excel_column_name, 'AAC' }

    describe(16) { it_behaves_like :excel_column_name, 'ABA' }
    describe(17) { it_behaves_like :excel_column_name, 'ABB' }
    describe(18) { it_behaves_like :excel_column_name, 'ABC' }

    describe(19) { it_behaves_like :excel_column_name, 'ACA' }
    describe(20) { it_behaves_like :excel_column_name, 'ACB' }
    describe(21) { it_behaves_like :excel_column_name, 'ACC' }
    describe(39) { it_behaves_like :excel_column_name, 'CCC' }
    # @formatter:on
  end
end
