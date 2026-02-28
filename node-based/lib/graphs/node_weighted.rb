# frozen_string_literal: true

require_relative 'node'

module Graphs
  class NodeWeighted < Node
    def initialize(data)
      super(data, {})
    end

    def add_connection(node, weight)
      connections[node] = weight
    end
  end
end
