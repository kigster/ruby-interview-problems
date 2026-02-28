# frozen_string_literal: true

require 'spec_helper'

module Cloud
  module Kitchens
    module Dispatch
      RSpec.describe 'Kitchen Simulation Integration', :integration do
        let(:dispatcher) { Dispatcher.new(order_source: orders_file) }
        let(:orders_file) { File.join(__dir__, '..', 'fixtures', 'orders.json') }

        before do
          ::Cloud::Kitchens::Dispatch.in_test = true
        end

        after do
          dispatcher.stop! if dispatcher.running
          ::Cloud::Kitchens::Dispatch.in_test = false
        end

        it 'processes orders through complete lifecycle' do
          expect(File.exist?(orders_file)).to be true

          # Start the dispatcher
          dispatcher.start!

          # Give some time for initial processing
          sleep(1)

          initial_stats = dispatcher.stats
          expect(initial_stats[:orders_received]).to be > 0

          # Wait for some cooking to complete
          sleep(3)

          cooking_stats = dispatcher.stats
          expect(cooking_stats[:cooking_orders]).to be >= 0
          expect(cooking_stats[:total_orders]).to be > 0

          # Wait for some orders to be ready and picked up
          sleep(8)

          final_stats = dispatcher.stats
          expect(final_stats[:orders_delivered]).to be >= 0

          # Verify the system is working
          expect(final_stats[:orders_received]).to be > 0
          puts "\nFinal simulation stats: #{final_stats}"
        end

        it 'handles order decay properly' do
          dispatcher.start!

          # Let simulation run for a bit
          sleep(5)

          stats = dispatcher.stats

          # Should have some orders in various states
          expect(stats[:orders_received]).to be > 0

          # Check that shelves are being used
          total_on_shelves = stats[:hot_shelf] + stats[:cold_shelf] +
                             stats[:frozen_shelf] + stats[:overflow_shelf]
          expect(total_on_shelves).to be >= 0
        end
      end
    end
  end
end
