# frozen_string_literal: true

module Graphs
  class Dijkstra
    attr_accessor :starting_vertex, :other_vertexes, :lookup

    def initialize(starting_vertex, other_vertexes)
      self.starting_vertex = starting_vertex
      self.other_vertexes  = other_vertexes
      self.lookup          = {}
      other_vertexes.each { |v| lookup[v.data] = v }
      lookup[starting_vertex.data] = starting_vertex
    end

    def compute
      edges                       = {}
      edges[starting_vertex.data] = [0, starting_vertex.data]
      other_vertexes.each do |v|
        edges[v.data] = [Float::INFINITY, nil]
      end

      visited = []

      current = starting_vertex

      while current
        visited << current.data

        current.connections.each_pair do |v, weight|
          if edges[v.data][0] > (weight + edges[current.data][0])
            edges[v.data] = [weight + edges[current.data][0], current.data]
          end
        end

        current  = nil
        cheapest = Float::INFINITY
        edges.each_pair do |v, weight_info|
          if weight_info[0] < cheapest && !visited.include?(v)
            cheapest = weight_info[0]
            current  = lookup[v]
          end
        end
      end

      edges
    end
  end
end
