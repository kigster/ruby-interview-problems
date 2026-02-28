# frozen_string_literal: true

require 'spec_helper'

module Cloud
  module Kitchens
    module Dispatch
      RSpec.describe Courier do
        let(:courier) { described_class.new('test-courier') }
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
          it 'starts in ready state' do
            expect(courier.ready?).to be true
            expect(courier.state).to eq('ready')
          end

          it 'has an id' do
            expect(courier.id).to eq('test-courier')
          end
        end

        describe '#pickup' do
          before { order.cook!; order.prepared! }

          it 'picks up ready order successfully' do
            expect(courier.pickup(order)).to be true
            expect(courier.delivering?).to be true
            expect(courier.order).to eq(order)
            expect(order.aasm.current_state).to eq(:picked_up)
          end

          it 'fails if courier is not ready' do
            courier.assign!
            expect(courier.pickup(order)).to be false
          end
        end

        describe '#deliver!' do
          before do
            order.cook!
            order.prepared!
            courier.pickup(order)
          end

          it 'delivers order successfully' do
            expect(courier.deliver!).to be true
            expect(courier.ready?).to be true
            expect(courier.order).to be_nil
            expect(order.aasm.current_state).to eq(:delivered)
          end
        end

        describe 'state methods' do
          it 'correctly identifies ready state' do
            expect(courier.ready?).to be true
            expect(courier.assigned?).to be false
            expect(courier.delivering?).to be false
          end

          it 'correctly identifies assigned state' do
            courier.assign!
            expect(courier.ready?).to be false
            expect(courier.assigned?).to be true
            expect(courier.delivering?).to be false
          end
        end
      end
    end
  end
end
