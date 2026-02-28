# frozen_string_literal: true

require_relative 'node'

module Trees
  class BinaryTree
    attr_accessor :root

    def initialize(root = nil)
      self.root = root
    end

    def in_order_traversal(node: root, level: 0, &block)
      return unless node

      in_order_traversal(node: node.left, level: level + 1, &block) if node.left
      block.call(node, level) if block_given?
      in_order_traversal(node: node.right, level: level + 1, &block) if node.right
    end
  end
end
