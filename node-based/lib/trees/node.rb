# frozen_string_literal: true

module Trees
  class Node
    attr_accessor :children
    attr_reader :data, :size

    DEFAULT_CHILDREN = 2

    def initialize(data, children = [], size: DEFAULT_CHILDREN)
      @size     = size
      @data     = data
      @children = children || Array(size) { nil }
    end

    def complete?
      num_children == size
    end

    def num_children
      children&.compact&.size
    end

    def sum
      (data + children&.compact&.map(&:sum)&.sum) || 0
    end
  end
end
