# frozen_string_literal: true

require 'trees/node_binary'
require 'rspec'
require 'rspec/its'

RSpec.describe Trees::NodeBinary do
  let(:values) { [1] }

  subject(:node) { described_class.new(values.first) }

  its(:left) { should be_nil }
  its(:right) { should be_nil }
  its(:data) { should eq values.first }
  its(:sum) { should eq values.sum }
  its(:complete?) { should be false }

  context '.from_array' do
    let(:args) { [1000, 100, 200, 10, 20, 30, 40] }
  end
end
