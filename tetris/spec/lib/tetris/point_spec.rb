# frozen_string_literal: true

require 'spec_helper'

module Tetris
  RSpec.describe Point do
    let(:point) { Point[x, y] }
    let(:rot_left) { point.rotate_left }

    describe 'Rotating Point(1,1)' do
      let(:x) { 1 }
      let(:y) { 1 }

      it 'should rotate right to 1, -1' do
        expect(point.rotate_right).to eq Point[1, -1]
      end

      it 'should rotate left to -1, 1' do
        expect(point.rotate_left).to eq Point[-1, 1]
      end

      it 'should rotate right thrice and match rotate_left' do
        expect(point.rotate_right(3)).to eq point.rotate_left
      end

      it 'should rotate left thrice and match rotate_right' do
        expect(point.rotate_left(3)).to eq point.rotate_right
      end

      it 'should rotate left twice and match rotate_right twice' do
        expect(point.rotate_left(2)).to eq point.rotate_right(2)
      end
    end
  end
end
