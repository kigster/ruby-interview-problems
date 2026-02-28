# frozen_string_literal: true

require_relative '../lib/courier'
require_relative '../lib/order'

RSpec.describe Courier do
  subject(:courier) { Courier.new('test-courier') }

  let(:order_data) do
    {
      'id' => '123',
      'name' => 'Test Pizza',
      'temp' => 'hot',
      'shelfLife' => 300,
      'decayRate' => 0.45
    }
  end

  let(:order) { Order.new(order_data) }

  describe '#initialize' do
    it 'sets id and initial state' do
      expect(courier.id).to eq('test-courier')
      expect(courier.state).to eq(:ready)
      expect(courier.assigned_order).to be_nil
    end
  end

  describe '#assign_order' do
    before do
      order.cook!
      order.ready!
    end

    it 'assigns order when courier is ready' do
      expect(courier.assign_order(order)).to be true
      expect(courier.state).to eq(:assigned)
      expect(courier.assigned_order).to eq(order)
    end

    it 'rejects assignment when courier is not ready' do
      courier.assign_order(order)
      other_order = Order.new(order_data.merge('id' => 'other'))
      other_order.cook!
      other_order.ready!

      expect(courier.assign_order(other_order)).to be false
    end

    it 'starts pickup process after travel time' do
      expect(courier.assign_order(order)).to be true

      # Wait for pickup (should happen within 6 seconds)
      sleep_time = 0
      while courier.state == :assigned && sleep_time < 7
        sleep(0.1)
        sleep_time += 0.1
      end

      # Wait a bit more for delivery to complete
      sleep(0.2)

      expect(courier.state).to eq(:ready)
      expect(order.state).to eq(:delivered)
    end
  end

  describe '#pickup_order' do
    before do
      order.cook!
      order.ready!
      courier.instance_variable_set(:@assigned_order, order)
      courier.instance_variable_set(:@state, :assigned)
    end

    it 'picks up order when conditions are met' do
      expect(courier.pickup_order).to be true
      expect(courier.state).to eq(:delivering)
      expect(order.state).to eq(:picked_up)
    end

    it 'fails when courier is not assigned' do
      courier.instance_variable_set(:@state, :ready)
      expect(courier.pickup_order).to be false
    end

    it 'fails when order is not ready' do
      order.instance_variable_set(:@state, :cooking)
      expect(courier.pickup_order).to be false
    end

    it 'starts delivery process immediately' do
      courier.pickup_order

      # Wait for delivery (should happen immediately)
      sleep(0.2)

      expect(courier.state).to eq(:ready)
      expect(order.state).to eq(:delivered)
      expect(courier.assigned_order).to be_nil
    end
  end

  describe '#deliver_order' do
    before do
      order.cook!
      order.ready!
      order.pick_up!
      courier.instance_variable_set(:@assigned_order, order)
      courier.instance_variable_set(:@state, :delivering)
    end

    it 'delivers order and resets courier' do
      delivered_order = courier.deliver_order

      expect(delivered_order).to eq(order)
      expect(order.state).to eq(:delivered)
      expect(courier.state).to eq(:ready)
      expect(courier.assigned_order).to be_nil
    end

    it 'fails when courier is not delivering' do
      courier.instance_variable_set(:@state, :assigned)
      expect(courier.deliver_order).to be false
    end
  end

  describe '#to_s' do
    it 'returns readable string representation' do
      str = courier.to_s
      expect(str).to include(courier.id)
      expect(str).to include(courier.state.to_s)
    end
  end
end
