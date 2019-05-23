require_relative '../lib/node'
require 'rspec'
require 'rspec/its'

RSpec.describe Node do
  let(:values) { [1] }

  subject(:node) { described_class.new(values.first) }

  its(:left) { should be_nil }
  its(:right) { should be_nil }
  its(:value) { should eq values.first }
  its(:sum) { should eq values.sum }
  its(:complete?) { should be false }

  context '.from_array' do
    let(:args) { [1000, 100, 200, 10, 20, 30, 40] }
  end

end
