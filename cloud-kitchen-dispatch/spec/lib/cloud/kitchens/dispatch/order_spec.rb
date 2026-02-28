# frozen_string_literal: true

require 'spec_helper'
require 'dry/configurable/test_interface'
require "cloud/kitchens/dispatch/app/config"

module Cloud
  module Kitchens
    module Dispatch
      class EventReceiver
        @orders_received = Set.new
        @mutex           = Mutex.new
        @total_orders    = 0

        class << self
          attr_accessor :orders_received, :mutex, :total_orders

          def on_order_received(event)
            mutex.synchronize do
              unless orders_received.include?(event.order)
                orders_received << event.order
                self.total_orders += 1
              end
            end
          end

          def total_orders_received
            orders_received.size
          end
        end
      end

      RSpec.describe Order do
        let(:observer) { EventReceiver }

        Fixtures.each_order do |order, index|
          break if index > 5

          context "processing order No.#{index}, \"#{order.name}\"" do
            describe order do
              it { is_expected.to be_a_kind_of(Order) }

              its('aasm.current_state') { is_expected.to eq :received }

              describe 'event' do
                subject { observer }

                include EventPublisher

                before do
                  Events::OrderReceivedEvent.observers.clear

                  this_observer = observer
                  Events::OrderReceivedEvent.configure do
                    notifies this_observer
                  end

                  publish :order_received, order: order, index: index
                end

                its(:orders_received) { should include(order) }

                its(:total_orders_received) { should be > 0 }
              end
            end
          end
        end

        context '#order value' do
          subject(:order) { Fixtures[1] }

          it { is_expected.to be_a_kind_of(Order) }

          its(:age) { is_expected.to be_within(0.1).of(0) }

          its(:order_value) { is_expected.to be > 0 }
        end
      end
    end
  end
end
