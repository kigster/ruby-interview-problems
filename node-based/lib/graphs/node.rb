# frozen_string_literal: true

module Graphs
  class Node
    attr_accessor :data, :connections, :visited

    def initialize(data, connections = [])
      self.data        = data
      self.connections = connections
      self.visited     = false
    end

    def add_connection(node)
      connections << node
      connections.flatten!
    end

    def visit!
      self.visited = true
      yield(self) if block_given?
    end

    def add_to(array)
      array << self
    end

    def output(datum)
      print "#{datum} —— "
    end

    def reset!
      self.visited = false
    end

    def traverse
      result   = Set.new
      to_reset = [self]
      queue    = Queue.new
      queue << self
      visit! { |n| n.add_to(result) }

      until queue.empty?
        current = queue.pop
        (current.connections.is_a?(Hash) ? current.connections.keys : current.connections).each do |node|
          next if node.visited

          node.visit! { |n| n.add_to(result) }
          queue << node
          to_reset << node
        end
      end

      to_reset.each(&:reset!)

      result.to_a
    end
  end
end
