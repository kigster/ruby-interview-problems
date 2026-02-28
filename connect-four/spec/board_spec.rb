# frozen_string_literal: true

require 'rspec'
require 'rspec/its'

require_relative '../lib/board'

RSpec.describe ConnectFour::Board do
  let(:black) { ConnectFour::Board::COLOR_BLACK }
  let(:red) { ConnectFour::Board::COLOR_RED }
  let(:empty) { ConnectFour::Board::COLOR_NIL }

  subject(:board) { described_class.new }

  let(:rows) { board.to_s.split("\n") }

  context '#initialize' do
    its(:board_state) { should be_a_kind_of Array }
    its(:to_s) { should match /^(\. ){7}/ }
  end

  context '#to_s' do
    its(:to_s) { is_expected.to_not include red }
    its(:to_s) { is_expected.to_not include black }
    its(:to_s) { is_expected.to include empty }
  end

  context '#place_piece' do
    let(:column_index) { 0 }

    subject { rows.last }

    describe 'first move' do
      before { board.place_piece(column_index, black) }
      let(:expected) { black + (empty * (ConnectFour::Board::COLS - 1)) }
      it { is_expected.to eq expected }

      describe 'second move' do
        let(:expected) { black + red + (empty * (ConnectFour::Board::COLS - 2)) }
        before { board.place_piece(column_index + 1, red) }
        it { is_expected.to eq expected }

        describe 'third move' do
          let(:last_row_string) { rows[-2] }
          let(:expected) { black + red + (empty * (ConnectFour::Board::COLS - 2)) }
          before { board.place_piece(column_index + 1, red) }
          it { is_expected.to eq expected }
        end
      end
    end
  end
end
