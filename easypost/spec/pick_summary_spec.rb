# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'date'
require_relative '../lib/pick_summary'

RSpec.describe EasyPost::PickSummary do
  context 'three pickers' do
    subject(:summary) { described_class.new(warehouse_id, date, data) }
    let(:result) { summary.result }
    let(:date) { Date.new(2019, 0o6, 10) }
    let(:date_time) { date.to_time.to_i }
    let(:warehouse_id) { 1 }
    let(:expected) {
      { 1 => 60,
        2 => 200,
        3 => 3600 }
    }
    let(:pick_start) {
      [
        {
          type: 'pick-start',
          worker_id: 1,
          warehouse_id: warehouse_id,
          pick_id: 11,
          inventory_id: nil,
          timestamp: date_time + 3600
        },
        {
          type: 'pick-start',
          worker_id: 1,
          warehouse_id: warehouse_id,
          pick_id: 21,
          inventory_id: nil,
          timestamp: date_time + 3600
        },
        {
          type: 'pick-start',
          worker_id: 2,
          warehouse_id: warehouse_id,
          pick_id: 12,
          inventory_id: nil,
          timestamp: date_time + (2 * 3600)
        },
        {
          type: 'pick-start',
          worker_id: 3,
          warehouse_id: warehouse_id,
          pick_id: 13,
          inventory_id: nil,
          timestamp: date_time + (3 * 3600)
        },
      ]
    }
    let(:pick_item) {
      [
        {
          type: 'pick-item',
          worker_id: 1,
          warehouse_id: warehouse_id,
          pick_id: 11,
          inventory_id: 100,
          timestamp: date_time + 3600 + 60
        },
        {
          type: 'pick-item',
          worker_id: 1,
          warehouse_id: warehouse_id,
          pick_id: 21,
          inventory_id: 201,
          timestamp: date_time + 3600 + 30
        },

        {
          type: 'pick-item',
          worker_id: 2,
          warehouse_id: warehouse_id,
          pick_id: 12,
          inventory_id: 101,
          timestamp: date_time + (2 * 3600) + 150
        },
        {
          type: 'pick-item',
          worker_id: 2,
          warehouse_id: warehouse_id,
          pick_id: 12,
          inventory_id: 102,
          timestamp: date_time + (2 * 3600) + 50
        },

        {
          type: 'pick-item',
          worker_id: 3,
          warehouse_id: warehouse_id,
          pick_id: 13,
          inventory_id: 103,
          timestamp: date_time + (3 * 3600) + 3600
        },
      ]
    }

    let(:data) { (pick_start + pick_item).shuffle }

    its('data.first') { should eq nil }

    before do
      pp summary.data.map(&:to_h)
    end
    context '#result' do
      subject { result }
      it { is_expected.to eq expected }
      its(:size) { should eq 3 }
    end
  end
end
