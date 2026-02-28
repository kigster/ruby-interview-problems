# frozen_string_literal: true

require 'graphs/node_weighted'
require 'graphs/dijkstra'
require 'rspec'
require 'rspec/its'
require 'awesome_print'

module Graphs
  RSpec.describe Dijkstra do
    let(:build_node) { ->(data) { NodeWeighted.new(data) } }

    let(:add_edge) { ->(from, to, weight) { from.add_connection(to, weight) } }

    let(:san_francisco) { build_node[:san_francisco] }
    let(:san_jose) { build_node[:san_jose] }
    let(:los_angeles) { build_node[:los_angeles] }
    let(:bakersfield) { build_node[:bakersfield] }
    let(:santa_barbara) { build_node[:santa_barbara] }

    let(:cities) { [san_francisco, san_jose, bakersfield, santa_barbara, los_angeles] }

    before do
      add_edge[san_francisco, santa_barbara, 325.2]
      add_edge[san_francisco, san_jose, 48.3]
      add_edge[san_jose, bakersfield, 241.1]
      add_edge[bakersfield, los_angeles, 113.4]
      add_edge[santa_barbara, los_angeles, 95.0]
    end

    context 'algorithm' do
      let(:source) { san_francisco }
      let(:algo) { described_class.new(source, cities - [source]) }
      let(:result) { algo.compute }

      subject { result }

      it { is_expected.to be_a_kind_of(Hash) }

      # Result is a hash of this form:
      #
      # { :san_francisco => [0, :san_francisco],
      #   :san_jose      => [48.3, :san_francisco],
      #   :bakersfield   => [289.4, :san_jose],
      #   :santa_barbara => [325.2, :san_francisco],
      #   :los_angeles   => [402.79999999999995, :bakersfield] }
      #
      it 'should compute route via bakersfield' do
        expect(result[:los_angeles][1]).to eq :bakersfield
        expect(result[:bakersfield][1]).to eq :san_jose
      end
    end
  end
end
