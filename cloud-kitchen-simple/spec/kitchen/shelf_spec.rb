# frozen_string_literal: true

require 'spec_helper'

module Kitchen
  describe 'Kitchen::Shelf' do
    extend OrdersHelper
    include OrdersHelper

    each_shelf do |shelf|
      context " #{shelf.name} shelf" do
        each_order(0..10) do |order|
          context "order #{order.name} (#{order.temp}) " do
            subject { shelf }
            before { shelf.orders.clear }

            its(:empty?) { is_expected.to be true }
            its(:full?) { is_expected.to be false }
            its(:open?) { is_expected.to be true }

            if order.temperature == shelf.temperature
              it 'accepts an order with a matching temperature' do
                expect(shelf.accepts?(order)).to be true
              end
            elsif shelf.is_a? OverflowShelf
              it 'accepts an order to an overflow shelf' do
                expect(shelf.accepts?(order)).to be true
              end
            else
              it 'does not accept an order with a non matching temperature' do
                expect(shelf.accepts?(order)).to be false
              end
            end

            if shelf.accepts?(order)
              describe 'when shelf can accept the order' do
                it 'can append order and increment its size' do
                  expect { shelf << order }.to change { shelf.size }.by(1)
                end

                describe 'after appending an order' do
                  before { shelf << order }
                  its(:empty?) { is_expected.to be false }
                end
              end
            else
              describe 'when shell can not accept an order' do
                it 'throws ArgumentError when << is called' do
                  expect { shelf << order }.to raise_error(ArgumentError)
                end
              end
            end
          end
        end
      end
    end
  end
end
