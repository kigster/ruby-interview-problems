# frozen_string_literal: true

require 'graphs/node_weighted'
require 'rspec'
require 'rspec/its'

module Graphs
  RSpec.describe NodeWeighted do
    let(:build_node) { ->(data) { described_class.new(data) } }
    let(:add_connection) { ->(node_from, node_to, weight) { node_from.add_connection(node_to, weight) } }

    let(:bce) { build_node[:bce] }
    let(:usd) { build_node[:usd] }
    let(:can) { build_node[:can] }
    let(:aus) { build_node[:aus] }

    before do
      add_connection[can, usd, 1000]
      add_connection[usd, aus, 0.7]
      add_connection[bce, can, 1.1]
      add_connection[aus, bce, 1200]
    end

    subject { aus }

    its(:connections) { should_not be_empty }
    its('connections.size') { should eq 1 }

    context 'graph' do
      subject { aus.traverse.map(&:data) }
      # it { should eq [:aus, :bce, :can, :usd] }
    end
  end
end
