# frozen_string_literal: true

require 'spec_helper'

module Fractional
  module Ai
    RSpec.describe 'VERSION' do
      subject { VERSION }

      it { is_expected.to be_a(String) }
      it { is_expected.to match(/\A\d+\.\d+\.\d+\z/) }
      it { is_expected.to eq("0.1.0") }

      it 'follows semantic versioning' do
        expect(subject).to match(/\A\d+\.\d+\.\d+\z/)
      end

      it 'is frozen' do
        expect(subject).to be_frozen
      end

      it 'is defined in the correct module' do
        expect(Fractional::Ai.const_defined?(:VERSION)).to be true
      end
    end
  end
end
