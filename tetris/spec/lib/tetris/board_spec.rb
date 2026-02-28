# frozen_string_literal: true

require 'spec_helper'

module Tetris
  RSpec.describe Board do
    let(:height) { Board::HEIGHT }
    let(:width) { Board::WIDTH }
    let(:zeros) { Matrix.build(height, width) { 0 } }

    let(:matrix) { zeros }
    let(:board) { Board.new(matrix) }

    context 'blank board' do
      context "Board's matrix" do
        it 'should be a an instance of Matrix class' do
          expect(board.matrix).to be_a_kind_of(Matrix)
          expect(board.size).to eq(board.matrix.column_count * board.matrix.row_count)
        end
      end
    end

    context 'prepopulated board' do
      let(:matrix) {
        [[0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
         [0, 0, 0, 1, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
         [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]
      }

      describe '#matrix' do
        it 'should be accessible via indices on @matrix' do
          expect(board.matrix[1, 2]).to eq(0)
          expect(board.matrix[1, 3]).to eq(1)
          expect(board.matrix[1, 4]).to eq(1)
          expect(board.matrix[1, 5]).to eq(1)
          expect(board.matrix[1, 6]).to eq(0)
        end
      end

      describe '#[]' do
        it 'should be accessible via X/Y of the Board' do
          expect(board[1, 2]).to eq(0)
        end
      end
    end
  end
end
