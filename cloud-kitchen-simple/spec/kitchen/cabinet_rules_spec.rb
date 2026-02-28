# frozen_string_literal: true

require 'spec_helper'
require 'uuid'

module Kitchen
  SHELF_TYPES = %i[hot cold frozen overflow].freeze

  RSpec.describe 'Kitchen::Cabinet Business Rules' do
    include OrdersHelper

    let(:order_creator) { ->(**opts) { Order.new(**opts) } }

    let(:hot_order) do
      lambda {
        order_creator[
          id: UUID.generate,
          name: 'Pad Thai',
          temp: 'hot',
          shelfLife: 210,
          decayRate: 0.72
        ]
      }
    end

    let(:cold_order) do
      lambda {
        order_creator[
          id: UUID.generate,
          name: 'Cheese',
          temp: 'cold',
          shelfLife: 255,
          decayRate: 0.2]
      }
    end

    let(:frozen_order) do
      lambda {
        order_creator[
          id: UUID.generate,
          name: 'Ice Cream',
          temp: 'frozen',
          shelfLife: 210,
          decayRate: 0.54]
      }
    end

    subject(:cabinet) { Cabinet.send(:create_cabinet) }

    before do
      subject.shelves.each do |shelf|
        expect(SHELF_TYPES).to include(shelf.name.to_sym)
        shelf.capacity = 1 unless shelf.name == 'overflow'
        shelf.capacity = 2 if shelf.name == 'overflow'
      end
    end

    its('shelves.size') { should eq 4 }
    its('shelves.first') { should be_an_kind_of(HotShelf) }
    its(:total_capacity) { is_expected.to eq 5 }

    RSpec.shared_examples 'a cabinet' do |with: {}|
      SHELF_TYPES.each do |type|
        next unless with.key?(type)

        it "#{type} shelf should contain #{with[type]} orders" do
          expect(cabinet.shelf(type).size).to eq with[type]
        end
      end
    end

    RSpec.shared_examples 'a full cabinet' do
      SHELF_TYPES.each do |type|
        it "should have shelf of type #{type} as full" do
          expect(cabinet.shelf(type)).to be_full
        end
      end
    end

    context 'adding one appropriate order to each shelf' do
      let(:orders) { [hot_order[], cold_order[], frozen_order[]] }
      before { orders.each { |order| cabinet << order } }

      it_should_behave_like 'a cabinet', with: { hot: 1, cold: 1, frozen: 1, overflow: 0 }

      context 'adding second hot order' do
        before { cabinet << hot_order[] }

        it 'should not yet fill the overflow shelf' do
          expect(cabinet.shelf(:overflow)).to_not be_full
        end

        context 'adding second frozen order' do
          before { cabinet << frozen_order[] }

          it_should_behave_like 'a full cabinet'

          context 'adding second cold order' do
            before { cabinet << cold_order[] }

            it_should_behave_like 'a full cabinet'

            it 'should bump the lowest value order from the shelf' do
            end
          end

          context 'removing an order from a hot shelf' do
            context 'and adding second cold order' do
              it 'should move overflow order to the hot shelf' do
              end
            end
          end
        end
      end
    end
  end
end
