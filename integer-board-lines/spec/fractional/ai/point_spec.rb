# frozen_string_literal: true

require 'spec_helper'

module Fractional
  module Ai
    RSpec.describe Point do
      let(:x) { 5 }
      let(:y) { 10 }
      let(:point) { described_class.new(x, y) }

      subject { point }

      describe 'initialization' do
        its(:x) { is_expected.to eq(x) }
        its(:y) { is_expected.to eq(y) }

        it 'is a Data object' do
          expect(point).to be_a(Data)
        end
      end

      describe '#to_s' do
        subject { point.to_s }

        it { is_expected.to eq("#{x},#{y}") }

        context 'with different coordinates' do
          let(:x) { 0 }
          let(:y) { 0 }
          it { is_expected.to eq("0,0") }
        end

        context 'with larger coordinates' do
          let(:x) { 100 }
          let(:y) { 250 }
          it { is_expected.to eq("100,250") }
        end
      end

      describe '#valid?' do
        subject { point.valid? }

        context 'with valid coordinates' do
          let(:valid_subject) { described_class.new(5, 10) }
          let(:invalid_subject) { described_class.new(-1, 5) }

          it_behaves_like 'a validatable object'
        end

        context 'with zero coordinates' do
          let(:x) { 0 }
          let(:y) { 0 }
          it { is_expected.to be true }
        end

        context 'with positive coordinates' do
          let(:x) { 100 }
          let(:y) { 200 }
          it { is_expected.to be true }
        end

        context 'with negative x coordinate' do
          let(:x) { -1 }
          let(:y) { 5 }
          it { is_expected.to be false }
        end

        context 'with negative y coordinate' do
          let(:x) { 5 }
          let(:y) { -1 }
          it { is_expected.to be false }
        end

        context 'with both negative coordinates' do
          let(:x) { -5 }
          let(:y) { -10 }
          it { is_expected.to be false }
        end

        context 'with non-integer x coordinate' do
          let(:x) { 5.5 }
          let(:y) { 10 }
          it { is_expected.to be false }
        end

        context 'with non-integer y coordinate' do
          let(:x) { 5 }
          let(:y) { 10.5 }
          it { is_expected.to be false }
        end

        context 'with string coordinates' do
          let(:x) { "5" }
          let(:y) { "10" }
          it { is_expected.to be false }
        end

        context 'with nil coordinates' do
          let(:x) { nil }
          let(:y) { nil }
          it { is_expected.to be false }
        end
      end

      describe 'equality and comparison' do
        let(:same_point) { described_class.new(x, y) }
        let(:different_point) { described_class.new(x + 1, y + 1) }

        it 'is equal to point with same coordinates' do
          expect(point).to eq(same_point)
        end

        it 'is not equal to point with different coordinates' do
          expect(point).not_to eq(different_point)
        end

        it 'has same hash for equal points' do
          expect(point.hash).to eq(same_point.hash)
        end
      end

      describe 'immutability' do
        it 'cannot modify x coordinate' do
          expect { point.x = 99 }.to raise_error(NoMethodError)
        end

        it 'cannot modify y coordinate' do
          expect { point.y = 99 }.to raise_error(NoMethodError)
        end
      end

      describe 'edge cases' do
        context 'with very large coordinates' do
          let(:x) { 999_999 }
          let(:y) { 999_999 }

          its(:valid?) { is_expected.to be true }
          its(:to_s) { is_expected.to eq("999999,999999") }
        end

        context 'with zero coordinates' do
          let(:x) { 0 }
          let(:y) { 0 }

          its(:valid?) { is_expected.to be true }
          its(:to_s) { is_expected.to eq("0,0") }
        end
      end
    end
  end
end
