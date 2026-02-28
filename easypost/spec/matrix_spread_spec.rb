# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'date'
require_relative '../lib/matrix_spread'

RSpec.describe EasyPost::MatrixSpread do
  subject(:matrix) { described_class.new(data).shift }

  shared_examples_for 'a shift matrix' do
    its(:size) { should eq data.size }
    it { is_expected.to eq expected }
  end

  context '5x4 matrix' do
    let(:data) {
      [
        [1, 0, 0, 0],
        [0, 1, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 0, 0],
        [0, 0, 1, 0],
      ]
    }

    let(:expected) {
      [
        [1, 1, 0, 0],
        [1, 1, 1, 0],
        [0, 1, 0, 0],
        [0, 0, 1, 0],
        [0, 1, 1, 1],
      ]
    }

    it_behaves_like 'a shift matrix'
  end

  context '2x1 matrix' do
    let(:data) {
      [
        [1],
        [0],
      ]
    }

    let(:expected) {
      [
        [1],
        [1],
      ]
    }

    it_behaves_like 'a shift matrix'
  end
end
