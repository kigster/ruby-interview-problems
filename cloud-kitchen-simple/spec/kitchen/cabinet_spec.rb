# frozen_string_literal: true

require 'spec_helper'

module Kitchen
  RSpec.describe Cabinet do
    subject(:cabinet) { Cabinet.send(:create_cabinet) }

    its(:total_capacity) { is_expected.to eq 45 }

    context 'empty cabinet' do
      describe 'all shelves empty' do
        it 'should show as all empty' do
          expect(cabinet.shelves.all?(&:empty?)).to be true
        end
      end

      describe 'adding orders' do
        include OrdersHelper

        let(:orders) { order_hashes }

        describe 'order_hashes from fixtures should have a' do
          subject { orders }

          its(:size) { should be > 100 }
          its(:first) { is_expected.to be_a_kind_of(Hash) }
        end

        describe 'adding first 40 orders' do
          let(:temp) {
            {
              0 => 'hot',
              1 => 'cold',
              2 => 'frozen'
            }
          }

          let(:order_placement) { {} }

          before do
            cabinet.total_capacity.times do |index|
              sleep(0.001)
              order_hash = orders[index].dup.tap do |order|
                order['temp'] = temp[index % 3]
              end
              order = Order.new(order_hash).tap(&:receive!)
              shelf = (cabinet << order)
              order_placement[index] = { order.id => shelf }
            end
          end

          its(:remaining_capacity) { should eq 0 }

          its(:size) { should eq cabinet.total_capacity }

          describe 'adding the next order' do
            let(:index) { cabinet.total_capacity + 1 }
            let(:order) { Order.new(orders[index]) }
            let(:trashed_order) { cabinet.orders.values.first }
            let(:temperature) { order.temp }
            let(:observer) { double(:on_order_trashed) }

            before do
              cabinet.send(:on_order_trashed_notify, observer)
              allow(observer).to receive(:on_order_trashed).with(trashed_order)
            end

            let(:shelf) { cabinet << order }

            it 'should bump off an older order' do
            end
          end
        end
      end
    end
  end
end
