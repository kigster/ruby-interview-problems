# frozen_string_literal: true

require 'spec_helper'

module Cloud
  module Kitchens
    module Dispatch
      RSpec.describe Shelf do
        let(:shelf) { described_class.new(temperature: 'hot') }
        let(:overflow_shelf) { described_class.new(temperature: nil, overflow: true) }
        let(:order) do
          order_struct = OrderStruct.new(
            id:        'test-order-1',
            name:      'Test Order',
            temp:      'hot',
            shelfLife: 300,
            decayRate: 0.45,
            state:     'new'
          )
          Order.new(order_struct)
        end

        describe '#initialize' do
          it 'sets default capacity' do
            expect(shelf.capacity).to eq(Shelf::DEFAULT_CAPACITY)
          end

          it 'sets temperature' do
            expect(shelf.temperature).to eq('hot')
          end

          it 'sets overflow flag' do
            expect(shelf.overflow).to be false
            expect(overflow_shelf.overflow).to be true
          end
        end

        describe '#add_order' do
          it 'adds order successfully' do
            expect(shelf.add_order(order)).to be true
            expect(shelf.orders).to include(order)
            expect(order.shelf).to eq(shelf)
          end

          it 'returns false when shelf is full and not overflow' do
            Shelf::DEFAULT_CAPACITY.times do |i|
              test_order = Order.new(OrderStruct.new(
                                       id:        "order-#{i}",
                                       name:      "Order #{i}",
                                       temp:      'hot',
                                       shelfLife: 300,
                                       decayRate: 0.45,
                                       state:     'new'
                                     ))
              shelf.add_order(test_order)
            end

            new_order = Order.new(OrderStruct.new(
                                    id:        'overflow-order',
                                    name:      'Overflow Order',
                                    temp:      'hot',
                                    shelfLife: 300,
                                    decayRate: 0.45,
                                    state:     'new'
                                  ))

            expect(shelf.add_order(new_order)).to be false
          end
        end

        describe '#remove_order' do
          before { shelf.add_order(order) }

          it 'removes order successfully' do
            shelf.remove_order(order)
            expect(shelf.orders).not_to include(order)
            expect(order.shelf).to be_nil
          end
        end

        describe '#can_store?' do
          it 'returns true for matching temperature' do
            expect(shelf.can_store?(order)).to be true
          end

          it 'returns true for overflow shelf' do
            expect(overflow_shelf.can_store?(order)).to be true
          end
        end

        describe '#decay_modifier' do
          it 'returns 1 for regular shelf' do
            expect(shelf.decay_modifier).to eq(1)
          end

          it 'returns 2 for overflow shelf' do
            expect(overflow_shelf.decay_modifier).to eq(2)
          end
        end
      end
    end
  end
end
