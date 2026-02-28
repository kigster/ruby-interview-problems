# frozen_string_literal: true

require 'spec_helper'

module Pharmacy
  RSpec.describe UpcomingInventory do
    let(:medications) { Medications.medications }
    let(:inventory) { UPCOMING_INVENTORY }

    subject(:medication_inventory) { inventory.first }

    its(:quantity) { should eq 30 }
    its(:date) { should_not be_nil }
  end
end
