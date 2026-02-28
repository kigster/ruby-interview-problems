# frozen_string_literal: true

require_relative '../lib/shelf'
require_relative '../lib/order'

RSpec.describe Shelf do
  let(:order_data) do
    {
      'id' => '123',
      'name' => 'Hot Pizza',
      'temp' => 'hot',
      'shelfLife' => 300,
      'decayRate' => 0.45
    }
  end

  let(:order) { Order.new(order_data) }

  describe 'temperature-specific shelf' do
    subject(:shelf) { Shelf.new(temperature: 'hot', capacity: 10) }

    describe '#initialize' do
      it 'sets temperature and capacity' do
        expect(shelf.temperature).to eq('hot')
        expect(shelf.capacity).to eq(10)
        expect(shelf.orders).to be_empty
      end
    end

    describe '#can_accept?' do
      it 'accepts matching temperature orders' do
        expect(shelf.can_accept?(order)).to be true
      end

      it 'rejects non-matching temperature orders' do
        cold_order = Order.new(order_data.merge('temp' => 'cold'))
        expect(shelf.can_accept?(cold_order)).to be false
      end
    end

    describe '#add_order' do
      it 'adds order when shelf has capacity' do
        expect(shelf.add_order(order)).to be true
        expect(shelf.orders).to include(order)
        expect(order.shelf).to eq(shelf)
      end

      it 'rejects order when shelf is full' do
        10.times { |i| shelf.add_order(Order.new(order_data.merge('id' => i.to_s))) }

        new_order = Order.new(order_data.merge('id' => 'overflow'))
        expect(shelf.add_order(new_order)).to be false
        expect(shelf.orders).not_to include(new_order)
      end

      it 'rejects order with wrong temperature' do
        cold_order = Order.new(order_data.merge('temp' => 'cold'))
        expect(shelf.add_order(cold_order)).to be false
      end
    end

    describe '#remove_order' do
      before { shelf.add_order(order) }

      it 'removes order from shelf' do
        expect(shelf.remove_order(order)).to be true
        expect(shelf.orders).not_to include(order)
        expect(order.shelf).to be_nil
      end

      it 'returns false for order not on shelf' do
        other_order = Order.new(order_data.merge('id' => 'other'))
        expect(shelf.remove_order(other_order)).to be false
      end
    end

    describe '#full?' do
      it 'returns false when shelf has capacity' do
        expect(shelf.full?).to be false
      end

      it 'returns true when shelf is at capacity' do
        10.times { |i| shelf.add_order(Order.new(order_data.merge('id' => i.to_s))) }
        expect(shelf.full?).to be true
      end
    end

    describe '#decay_modifier' do
      it 'returns 1 for temperature-specific shelves' do
        expect(shelf.decay_modifier).to eq(1)
      end
    end
  end

  describe 'overflow shelf' do
    subject(:overflow_shelf) { Shelf.new(temperature: 'any', capacity: 15) }

    describe '#can_accept?' do
      it 'accepts any temperature order' do
        hot_order = Order.new(order_data.merge('temp' => 'hot'))
        cold_order = Order.new(order_data.merge('temp' => 'cold'))
        frozen_order = Order.new(order_data.merge('temp' => 'frozen'))

        expect(overflow_shelf.can_accept?(hot_order)).to be true
        expect(overflow_shelf.can_accept?(cold_order)).to be true
        expect(overflow_shelf.can_accept?(frozen_order)).to be true
      end
    end

    describe '#decay_modifier' do
      it 'returns 2 for overflow shelf' do
        expect(overflow_shelf.decay_modifier).to eq(2)
      end
    end
  end

  describe '#update_order_values!' do
    subject(:shelf) { Shelf.new(temperature: 'hot', capacity: 10) }

    it 'removes expired orders' do
      expired_order = Order.new(order_data)
      allow(expired_order).to receive(:value).and_return(0.0)
      shelf.add_order(expired_order)

      expired_count = shelf.update_order_values!

      expect(expired_count).to eq(1)
      expect(shelf.orders).to be_empty
      expect(expired_order.state).to eq(:expired)
    end

    it 'keeps valid orders' do
      valid_order = Order.new(order_data)
      shelf.add_order(valid_order)

      expired_count = shelf.update_order_values!

      expect(expired_count).to eq(0)
      expect(shelf.orders).to include(valid_order)
    end
  end
end
