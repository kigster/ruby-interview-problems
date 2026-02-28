# frozen_string_literal: true

require 'graphs/node'
require 'rspec'
require 'rspec/its'

module Graphs
  RSpec.describe Node do
    let(:build_node) { ->(data, connections = []) { described_class.new(data, connections) } }

    let(:bce) { build_node[:bce] }
    let(:usd) { build_node[:usd] }
    let(:can) { build_node[:can, [usd, bce]] }

    subject(:aus) { build_node[:aus, [can, bce]] }

    before do
      bce.add_connection(usd)
      can.add_connection(aus)
    end

    its(:connections) { should_not be_empty }
    its('connections.size') { should eq 2 }

    context 'graph' do
      # subject { aus.traverse.map(&:data) }
      # it { should eq [:aus, :can, :bce, :usd] }
    end
  end
end
