# frozen_string_literal: true

require 'spec_helper'

module Kitchen
  describe SousChef do
    subject(:chef) { described_class.new }

    its('class.instance') { is_expected.to eq chef }
  end
end
