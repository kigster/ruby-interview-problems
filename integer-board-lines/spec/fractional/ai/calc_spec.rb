# frozen_string_literal: true

require 'spec_helper'

module Fractional
  module Ai
    RSpec.describe Calc do
      let(:test_class) do
        Class.new do
          include Calc
        end
      end
      let(:calc_subject) { test_class.new }

      subject { calc_subject }

      it_behaves_like 'basic calculation methods'

      describe '#min' do
        subject { calc_subject.min(a, b) }

        context 'when first number is smaller' do
          let(:a) { 5 }
          let(:b) { 10 }
          it { is_expected.to eq(5) }
        end

        context 'when second number is smaller' do
          let(:a) { 10 }
          let(:b) { 5 }
          it { is_expected.to eq(5) }
        end

        context 'when numbers are equal' do
          let(:a) { 5 }
          let(:b) { 5 }
          it { is_expected.to eq(5) }
        end

        context 'with negative numbers' do
          let(:a) { -10 }
          let(:b) { -5 }
          it { is_expected.to eq(-10) }
        end

        context 'with mixed positive and negative' do
          let(:a) { -5 }
          let(:b) { 10 }
          it { is_expected.to eq(-5) }
        end

        context 'with zero' do
          let(:a) { 0 }
          let(:b) { 5 }
          it { is_expected.to eq(0) }
        end

        context 'with floats' do
          let(:a) { 3.14 }
          let(:b) { 2.71 }
          it { is_expected.to eq(2.71) }
        end
      end

      describe '#max' do
        subject { calc_subject.max(a, b) }

        context 'when first number is larger' do
          let(:a) { 10 }
          let(:b) { 5 }
          it { is_expected.to eq(10) }
        end

        context 'when second number is larger' do
          let(:a) { 5 }
          let(:b) { 10 }
          it { is_expected.to eq(10) }
        end

        context 'when numbers are equal' do
          let(:a) { 5 }
          let(:b) { 5 }
          it { is_expected.to eq(5) }
        end

        context 'with negative numbers' do
          let(:a) { -10 }
          let(:b) { -5 }
          it { is_expected.to eq(-5) }
        end

        context 'with mixed positive and negative' do
          let(:a) { -5 }
          let(:b) { 10 }
          it { is_expected.to eq(10) }
        end

        context 'with zero' do
          let(:a) { 0 }
          let(:b) { -5 }
          it { is_expected.to eq(0) }
        end

        context 'with floats' do
          let(:a) { 3.14 }
          let(:b) { 2.71 }
          it { is_expected.to eq(3.14) }
        end
      end
    end
  end
end
