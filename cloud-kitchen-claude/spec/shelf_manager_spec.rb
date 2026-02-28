# frozen_string_literal: true

require_relative '../lib/shelf_manager'
require_relative '../lib/order'

RSpec.describe ShelfManager do
  subject(:shelf_manager) { ShelfManager.new }

  let(:hot_order_data) do
    {
      'id' => 'hot1',
      'name' => 'Hot Pizza',
      'temp' => 'hot',
      'shelfLife' => 300,
      'decayRate' => 0.45
    }
  end

  let(:cold_order_data) do
    {
      'id' => 'cold1',
      'name' => 'Cold Salad',
      'temp' => 'cold',
      'shelfLife' => 250,
      'decayRate' => 0.35
    }
  end

  describe '#initialize' do
    it 'creates temperature-specific shelves' do
      expect(shelf_manager.shelves['hot']).to be_a(Shelf)
      expect(shelf_manager.shelves['cold']).to be_a(Shelf)
      expect(shelf_manager.shelves['frozen']).to be_a(Shelf)
      expect(shelf_manager.overflow_shelf).to be_a(Shelf)
    end

    it 'sets correct capacities' do
      expect(shelf_manager.shelves['hot'].capacity).to eq(10)
      expect(shelf_manager.shelves['cold'].capacity).to eq(10)
      expect(shelf_manager.shelves['frozen'].capacity).to eq(10)
      expect(shelf_manager.overflow_shelf.capacity).to eq(15)
    end
  end

  describe '#place_order' do
    context 'when preferred shelf has space' do
      it 'places order on temperature-specific shelf' do
        order = Order.new(hot_order_data)
        result = shelf_manager.place_order(order)

        expect(result[:action]).to eq(:placed_on_temp_shelf)
        expect(result[:shelf]).to eq(shelf_manager.shelves['hot'])
        expect(order.shelf).to eq(shelf_manager.shelves['hot'])
      end
    end

    context 'when preferred shelf is full' do
      before do
        # Fill the hot shelf
        10.times do |i|
          order = Order.new(hot_order_data.merge('id' => "hot#{i}"))
          shelf_manager.shelves['hot'].add_order(order)
        end
      end

      it 'places order on overflow shelf' do
        order = Order.new(hot_order_data.merge('id' => 'overflow_order'))
        result = shelf_manager.place_order(order)

        expect(result[:action]).to eq(:placed_on_overflow)
        expect(result[:shelf]).to eq(shelf_manager.overflow_shelf)
        expect(order.shelf).to eq(shelf_manager.overflow_shelf)
      end
    end

    context 'when both preferred and overflow shelves are full' do
      before do
        # Fill hot shelf
        10.times do |i|
          order = Order.new(hot_order_data.merge('id' => "hot#{i}"))
          shelf_manager.shelves['hot'].add_order(order)
        end
      end

      it 'tries to move order from overflow to make space' do
        # Fill overflow shelf with 15 cold orders (completely full)
        cold_orders = []
        15.times do |i|
          order = Order.new(cold_order_data.merge('id' => "overflow#{i}"))
          shelf_manager.overflow_shelf.add_order(order)
          cold_orders << order
        end

        # Now overflow is full, try to add a new hot order
        new_order = Order.new(hot_order_data.merge('id' => 'new_hot'))
        result = shelf_manager.place_order(new_order)

        expect(result[:action]).to eq(:placed_on_overflow_after_move)
        expect(result[:moved_order]).to be_a(Order)
        expect(result[:moved_order].temp).to eq('cold') # Should be a cold order that was moved
        expect(result[:moved_order].shelf).to eq(shelf_manager.shelves['cold'])
        expect(new_order.shelf).to eq(shelf_manager.overflow_shelf)

        # Verify cold shelf now has the moved order
        expect(shelf_manager.shelves['cold'].orders).to include(result[:moved_order])
      end

      it 'discards random order when no moves possible' do
        # Fill all temperature shelves so moves aren't possible
        10.times do |i|
          order = Order.new(cold_order_data.merge('id' => "cold#{i}"))
          shelf_manager.shelves['cold'].add_order(order)
        end

        10.times do |i|
          frozen_data = cold_order_data.merge('id' => "frozen#{i}", 'temp' => 'frozen')
          order = Order.new(frozen_data)
          shelf_manager.shelves['frozen'].add_order(order)
        end

        # Fill overflow shelf completely
        15.times do |i|
          order = Order.new(cold_order_data.merge('id' => "overflow#{i}"))
          shelf_manager.overflow_shelf.add_order(order)
        end

        new_order = Order.new(hot_order_data.merge('id' => 'new_hot'))
        result = shelf_manager.place_order(new_order)

        expect(result[:action]).to eq(:placed_on_overflow_after_discard)
        expect(result[:discarded_order]).to be_a(Order)
        expect(result[:discarded_order].state).to eq(:expired)
        expect(new_order.shelf).to eq(shelf_manager.overflow_shelf)
      end
    end
  end

  describe '#remove_order' do
    it 'removes order from its shelf' do
      order = Order.new(hot_order_data)
      shelf_manager.place_order(order)

      expect(shelf_manager.remove_order(order)).to be true
      expect(order.shelf).to be_nil
      expect(shelf_manager.shelves['hot'].orders).not_to include(order)
    end

    it 'returns false for order not on any shelf' do
      order = Order.new(hot_order_data)
      expect(shelf_manager.remove_order(order)).to be false
    end
  end

  describe '#update_all_shelves!' do
    it 'updates all shelves and returns expired count' do
      order1 = Order.new(hot_order_data)
      order2 = Order.new(cold_order_data)
      shelf_manager.place_order(order1)
      shelf_manager.place_order(order2)

      allow(order1).to receive(:value).and_return(0.0)
      allow(order2).to receive(:value).and_return(0.5)

      expired_count = shelf_manager.update_all_shelves!

      expect(expired_count).to eq(1)
      expect(order1.state).to eq(:expired)
      expect(order2.state).not_to eq(:expired)
    end
  end

  describe '#all_orders' do
    it 'returns orders from all shelves' do
      hot_order = Order.new(hot_order_data)
      cold_order = Order.new(cold_order_data)
      shelf_manager.place_order(hot_order)
      shelf_manager.place_order(cold_order)

      all_orders = shelf_manager.all_orders
      expect(all_orders).to include(hot_order)
      expect(all_orders).to include(cold_order)
    end
  end

  describe '#shelf_contents' do
    it 'returns contents of all shelves' do
      hot_order = Order.new(hot_order_data)
      shelf_manager.place_order(hot_order)

      contents = shelf_manager.shelf_contents
      expect(contents['hot']).to include(hot_order)
      expect(contents['cold']).to be_empty
      expect(contents['frozen']).to be_empty
      expect(contents['overflow']).to be_empty
    end
  end

  describe '#stats' do
    it 'returns shelf statistics' do
      hot_order = Order.new(hot_order_data)
      cold_order = Order.new(cold_order_data)
      shelf_manager.place_order(hot_order)
      shelf_manager.place_order(cold_order)

      stats = shelf_manager.stats
      expect(stats[:hot]).to eq(1)
      expect(stats[:cold]).to eq(1)
      expect(stats[:frozen]).to eq(0)
      expect(stats[:overflow]).to eq(0)
      expect(stats[:total]).to eq(2)
    end
  end
end
