# frozen_string_literal: true

require 'spec_helper'

module Pharmacy
  RSpec.describe Medication do
    let(:medications) { MEDICATIONS }
    subject!(:medication) { medications.first }

    describe '#initialize' do
      its(:price) { should eq 65.59 }
      its(:name) { should eq 'Progesterone 100 MG' }
      its(:id) { should eq 1 }
    end

    describe '.medications' do
      it 'should register the medication in the @medications' do
        expect(described_class.medications).to_not be_empty
      end
    end

    describe '.find_by_id' do
      it 'should return the medication' do
        expect(described_class.find_by_id(medication.id)).to eq medication
      end
    end
  end
end
