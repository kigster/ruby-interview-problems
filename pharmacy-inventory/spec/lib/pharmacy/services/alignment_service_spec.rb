# frozen_string_literal: true

require 'spec_helper'

module Pharmacy
  RSpec.describe AlignmentService do
    let(:calc) { described_class.new(prescriptions) }

    describe 'easy prescriptions' do
      let(:prescriptions) { PRESCRIPTIONS[].map { |p| Prescription.new(**p) } }

      describe '#initialize' do
        subject { prescriptions.first }

        its(:class) { should eq Prescription }
        its('medication.name') { should eq 'Aspirin' }
      end

      describe '#earliest_end_of_supply' do
        subject { calc }
        its(:earliest_end_of_supply) { should eq 14 }
      end

      describe '#alignment_date computation' do
        let(:expected_alignment) { Alignment.new(date: 15, cost: 1.43) }

        it 'should compute alignment date' do
          expect(calc.alignment_date).to eq expected_alignment
        end
      end
    end

    # describe 'hard prescriptions' do
    #   let(:prescriptions) { HARD_PRESCRIPTIONS[].map { |p| Prescription.new(**p) } }
    #   let(:expected_alignment) { Alignment.new(date: 49, cost: 5.83) }
    #
    #   it 'should compute alignment date' do
    #     expect(calc.alignment_date).to eq expected_alignment
    #   end
    # end
  end
end
