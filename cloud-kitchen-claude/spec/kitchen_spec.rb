# frozen_string_literal: true

require_relative '../lib/kitchen'
require 'json'
require 'tempfile'

RSpec.describe Kitchen do
  subject(:kitchen) { Kitchen.new(courier_count: 2) }

  let(:test_orders) do
    [
      {
        'id' => '1',
        'name' => 'Pizza',
        'temp' => 'hot',
        'shelfLife' => 300,
        'decayRate' => 0.45
      },
      {
        'id' => '2',
        'name' => 'Salad',
        'temp' => 'cold',
        'shelfLife' => 250,
        'decayRate' => 0.35
      }
    ]
  end

  let(:orders_file) do
    file = Tempfile.new(['test_orders', '.json'])
    file.write(JSON.generate(test_orders))
    file.close
    file.path
  end

  after do
    kitchen.stop if kitchen.running
    FileUtils.rm_f(orders_file)
  end

  describe '#initialize' do
    it 'creates shelf manager and couriers' do
      expect(kitchen.shelf_manager).to be_a(ShelfManager)
      expect(kitchen.couriers.size).to eq(2)
      expect(kitchen.couriers.all?(Courier)).to be true
    end

    it 'initializes stats' do
      expect(kitchen.stats).to include(
        orders_received: 0,
        orders_cooked: 0,
        orders_ready: 0,
        orders_picked_up: 0,
        orders_delivered: 0,
        orders_expired: 0,
        orders_discarded: 0
      )
    end
  end

  describe '#start' do
    it 'processes orders at specified rate' do
      start_time = Time.now

      # Use very fast rate for testing
      kitchen.start(orders_file: orders_file, orders_per_second: 10.0)

      end_time = Time.now
      duration = end_time - start_time

      # Should complete quickly with fast rate
      expect(duration).to be < 10 # Allow more buffer for processing
      expect(kitchen.stats[:orders_received]).to eq(2)
      expect(kitchen.stats[:orders_cooked]).to eq(2)
      expect(kitchen.stats[:orders_ready]).to eq(2)
    end

    it 'handles invalid orders file' do
      expect { kitchen.start(orders_file: 'nonexistent.json', orders_per_second: 2.0) }.to raise_error(SystemExit)
    end
  end

  describe 'order processing' do
    before do
      allow(kitchen).to receive(:puts) # Suppress output during tests
      allow(kitchen).to receive(:sleep) # Speed up tests
    end

    it 'processes orders through complete lifecycle' do
      # Mock sleep to speed up test
      allow_any_instance_of(Object).to receive(:sleep)

      # Start kitchen in a thread
      kitchen_thread = Thread.new do
        kitchen.start(orders_file: orders_file, orders_per_second: 10.0)
      end

      # Wait a bit for processing
      sleep(1)
      kitchen.stop
      kitchen_thread.join

      # Verify orders were processed
      expect(kitchen.stats[:orders_received]).to eq(2)
      expect(kitchen.stats[:orders_cooked]).to eq(2)
      expect(kitchen.stats[:orders_ready]).to eq(2)
    end
  end

  describe '#stop' do
    it 'sets running flag to false' do
      kitchen.instance_variable_set(:@running, true)
      kitchen.stop
      expect(kitchen.running).to be false
    end
  end

  describe 'statistics tracking' do
    before do
      allow(kitchen).to receive(:puts)
      allow(kitchen).to receive(:sleep)
    end

    it 'increments stats during order processing' do
      kitchen.send(:process_order, test_orders.first)

      expect(kitchen.stats[:orders_received]).to eq(1)
      expect(kitchen.stats[:orders_cooked]).to eq(1)
      expect(kitchen.stats[:orders_ready]).to eq(1)
    end
  end

  describe 'shelf placement logging' do
    before do
      allow(kitchen).to receive(:puts)
      allow(kitchen).to receive(:sleep)
      allow(kitchen).to receive(:display_shelf_contents)
    end

    let(:order) { Order.new(test_orders.first) }

    it 'logs successful shelf placement' do
      result = { action: :placed_on_temp_shelf, shelf: double('shelf', temperature: 'hot') }
      expect(kitchen).to receive(:log_event).with("🥶 Order placed on hot shelf", order)

      kitchen.send(:handle_shelf_placement, order, result)
    end

    it 'logs overflow placement' do
      result = { action: :placed_on_overflow, shelf: double('shelf') }
      expect(kitchen).to receive(:log_event).with("📦 Order placed on overflow shelf", order)

      kitchen.send(:handle_shelf_placement, order, result)
    end

    it 'logs order discard' do
      discarded_order = Order.new(test_orders.last)
      result = {
        action: :placed_on_overflow_after_discard,
        shelf: double('shelf'),
        discarded_order: discarded_order
      }

      expect(kitchen).to receive(:log_event).with("🗑️  Discarded random order, placed new order on overflow", order)
      expect(kitchen).to receive(:log_event).with("   ↳ Discarded", discarded_order)

      kitchen.send(:handle_shelf_placement, order, result)
    end

    it 'logs order waste' do
      result = { action: :order_wasted, shelf: nil }
      expect(kitchen).to receive(:log_event).with("💀 Order wasted - no shelf space", order)

      kitchen.send(:handle_shelf_placement, order, result)
    end
  end
end
