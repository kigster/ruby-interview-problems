# frozen_string_literal: true

require 'trees/node_binary'
require 'trees/binary_tree'
require 'rspec'
require 'rspec/its'

module Trees
  RSpec.describe BinaryTree do
    let(:root_value) { 2 }
    let(:left_left_node) { NodeBinary.new(0) }
    let(:right_right_node) { NodeBinary.new(5) }
    let(:right_left_node) { NodeBinary.new(3) }
    let(:left_node) { NodeBinary.new(1, left_left_node) }
    let(:right_node) { NodeBinary.new(4, right_left_node, right_right_node) }
    let(:root_node) { NodeBinary.new(root_value, left_node, right_node) }

    subject(:tree) { described_class.new(root_node) }

    its(:root) { should eq root_node }

    its('root.left') { should eq left_node }
    its('root.right') { should eq right_node }

    context 'in_order_traversal' do
      subject(:result) do
        values = []
        tree.in_order_traversal(node: root_node) do |node, _level|
          values << node.data if node&.data
        end
        values
      end
      it { is_expected.to eq [0, 1, 2, 3, 4, 5] }
    end
  end
end
