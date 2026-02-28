# frozen_string_literal: true

require_relative '../lib/order'

RSpec.describe Order do
  let(:order_data) do
    {
      'id' => '123',
      'name' => 'Test Pizza',
      'temp' => 'hot',
      'shelfLife' => 300,
      'decayRate' => 0.45
    }
  end

  subject(:order) { Order.new(order_data) }

  describe '#initialize' do
    it 'sets attributes from data hash' do
      expect(order.id).to eq('123')
      expect(order.name).to eq('Test Pizza')
      expect(order.temp).to eq('hot')
      expect(order.shelf_life).to eq(300.0)
      expect(order.decay_rate).to eq(0.45)
    end

    it 'starts in received state' do
      expect(order.state).to eq(:received)
    end

    it 'sets created_at timestamp' do
      expect(order.created_at).to be_within(1).of(Time.now)
    end
  end

  describe 'state transitions' do
    it 'transitions from received to cooking' do
      expect(order.cook!).to be true
      expect(order.state).to eq(:cooking)
    end

    it 'transitions from cooking to ready' do
      order.cook!
      expect(order.ready!).to be true
      expect(order.state).to eq(:ready)
    end

    it 'transitions from ready to picked_up' do
      order.cook!
      order.ready!
      expect(order.pick_up!).to be true
      expect(order.state).to eq(:picked_up)
    end

    it 'transitions from picked_up to delivered' do
      order.cook!
      order.ready!
      order.pick_up!
      expect(order.deliver!).to be true
      expect(order.state).to eq(:delivered)
    end

    it 'can expire from any state' do
      expect(order.expire!).to be true
      expect(order.state).to eq(:expired)
    end

    it 'prevents invalid state transitions' do
      expect(order.ready!).to be false
      expect(order.pick_up!).to be false
      expect(order.deliver!).to be false
    end
  end

  describe '#age' do
    it 'returns time elapsed since creation' do
      initial_age = order.age
      sleep(0.01) # Reduced sleep time for faster tests
      expect(order.age).to be > initial_age # Just check it increases
    end
  end

  describe '#value' do
    it 'calculates initial value as 1.0' do
      expect(order.value).to be_within(0.01).of(1.0)
    end

    it 'decreases over time' do
      allow(order).to receive(:age).and_return(10)
      expect(order.value).to be < 1.0
    end

    it 'applies shelf decay modifier' do
      allow(order).to receive(:age).and_return(10)
      value_normal = order.value(1)
      value_overflow = order.value(2)
      expect(value_overflow).to be < value_normal
    end

    it 'never goes below 0' do
      allow(order).to receive(:age).and_return(1000)
      expect(order.value).to eq(0.0)
    end

    it 'returns 0 for expired orders' do
      order.expire!
      expect(order.value).to eq(0.0)
    end
  end

  describe '#expired?' do
    it 'returns true for expired orders' do
      order.expire!
      expect(order.expired?).to be true
    end

    it 'returns true for orders with zero value' do
      allow(order).to receive(:value).and_return(0.0)
      expect(order.expired?).to be true
    end

    it 'returns false for fresh orders' do
      expect(order.expired?).to be false
    end
  end

  describe '#to_s' do
    it 'returns a readable string representation' do
      str = order.to_s
      expect(str).to include(order.id[0..7])
      expect(str).to include(order.name)
      expect(str).to include(order.temp)
    end
  end
end
