# frozen_string_literal: true

require 'spec_helper'

module Pharmacy
  RSpec.describe Inventory do
    let(:medications) { MEDICATIONS }
    let(:inventory) { INVENTORY }

    subject(:medication_inventory) { inventory.first }

    its(:quantity) { should eq 27 }
  end
end
