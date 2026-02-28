# frozen_string_literal: true

require_relative 'node'
module Trees
  class NodeBinary < Node
    def initialize(data, left = nil, right = nil)
      raise(ArgumentError, 'Invalid left or right') unless (left.nil? || left.is_a?(self.class)) && (right.nil? || right.is_a?(self.class))

      super(data, [left, right], size: 2)
    end

    def left
      children[0]
    end

    def right
      children[1]
    end
  end
end
