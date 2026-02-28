# frozen_string_literal: true

require 'spec_helper'

module Tetris
  RSpec.describe Tetromino do
    let(:game) { Board.new }
    let(:shape_l) { described_class[:L] }

    context 'layout is defined' do
      it 'should have a layout' do
        expect(shape_l.height).to eq(3)
        expect(shape_l.width).to eq(3)
      end
    end
  end
end
