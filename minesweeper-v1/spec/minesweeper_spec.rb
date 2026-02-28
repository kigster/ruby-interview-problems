# frozen_string_literal: true

require 'rspec'
require_relative '../lib/minesweeper'

RSpec.describe Board do
  let(:cols) { 3 }
  let(:rows) { 3 }
  let(:bombs) { 1 }

  subject(:board) { described_class.new(rows, cols, bombs) }

  describe '#initialize' do
    it '#size' do
      expect(board.size).to eq 9
    end

    it '#bombs' do
      expect(board.matrix.find{ |c| c == Board::BOMB }.size).to eq bombs
    end
  end

  describe 'counts' do
    let(:matrix) {
      [
        nil, nil, nil,
        nil, Board::BOMB, nil,
        nil, nil, nil
      ]
    }

    before { board.matrix = matrix; board.send(:compute_counts!) }

    it 'should have a couple of 1 in all cells' do
      (cols * rows).times do |index|
        next if index == 4

        expect(board[index]).to eq 1
      end
    end
  end
end
