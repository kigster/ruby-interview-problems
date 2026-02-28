# frozen_string_literal: true

require_relative '../lib/ticker_graph'
require 'rspec'
require 'rspec/its'

RSpec.describe TickerGraph do
  let(:input_hash) { nil }
  subject(:ticker_graph) { described_class.new(input_hash) }

  its(:ticker_tuples) { should be_empty }
  its(:graph) { should be_empty }

  context 'with tuples' do
    let(:input_hash) {
      {
        'BTC-ETH' => 200.0,
        'BTC-USD' => 7000.0,
        'ETH-USD' => 15.0,
        'ETH-LTC' => 10.0,
        'LTC-EUR' => 12.0,
        'EUR-USD' => 1.3
      }
    }

    before { ticker_graph.resolve! }

    before { Colored2.disable! }

    its(:ticker_tuples) { should_not be_empty }
    its(:ticker_tuples) { should include TickerGraph::TickerTuple.new('LTC-EUR', 12.0) }

    context 'ticker-tuple' do
      subject(:tuple) { ticker_graph.ticker_tuples.find { |t| t.tuple == 'BTC-ETH' } }
      its(:from) { should eq 'BTC' }
      its(:to) { should eq 'ETH' }
      context 'ticker_graph' do
        subject { ticker_graph }

        # tuple_prices are just the input hash
        its('tuple_prices.keys') { should include 'BTC-ETH' }
        its('tuple_prices.keys') { should_not include 'BTC-LTC' }

        # graph is the resolved hash, and should contain all conversions
        its(:graph) { should include 'BTC-ETH' }
        its(:graph) { should include 'BTC-LTC' }

        context '#to_s' do
          let(:expected_output) {
            <<~CURRENCIES

              BTC-ETH ————▶  200.0000
              BTC-EUR ————▶ 2307.7000
              BTC-LTC ————▶ 2000.0000
              BTC-USD ————▶ 7000.0000
              ETH-BTC ————▶    0.0050
              ETH-EUR ————▶   11.5385
              ETH-LTC ————▶   10.0000
              ETH-USD ————▶   15.0000
              EUR-BTC ————▶    0.0004
              EUR-ETH ————▶    0.0867
              EUR-LTC ————▶    0.0833
              EUR-USD ————▶    1.3000
              LTC-BTC ————▶    0.0005
              LTC-ETH ————▶    0.1000
              LTC-EUR ————▶   12.0000
              LTC-USD ————▶    1.5000
              USD-BTC ————▶    0.0001
              USD-ETH ————▶    0.0667
              USD-EUR ————▶    0.7692
              USD-LTC ————▶    0.2857
            CURRENCIES
          }

          it 'should generate edges ticker_graph as string' do
            expect(ticker_graph.to_s).to eq expected_output
          end

          it 'should print to_s' do
            Colored2.enable!
            puts ticker_graph
          end
        end
      end
    end
  end
end
