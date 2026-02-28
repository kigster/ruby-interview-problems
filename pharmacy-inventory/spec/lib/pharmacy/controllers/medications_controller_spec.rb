# frozen_string_literal: true

require 'spec_helper'

module Pharmacy
  RSpec.describe MedicationsController do
    let(:medications) { MEDICATIONS }
    let(:medication_hashes) { MEDICATIONS.map(&:to_hash) }

    subject { described_class }

    describe '.medications' do
      let(:all_medications) { described_class.medications }
      it 'should include the medication hashes' do
        expect(all_medications[0..4]).to eq(medication_hashes)
      end
    end

    describe '.medication' do
      let(:id) { 2 }
      let(:expected_medication) { Medication.find_by_id(id) }

      it 'should return Medication by id' do
        expect(expected_medication).to_not be_nil
        expect(described_class.medication(id)).to eq expected_medication.to_hash
      end
    end
  end
end
