# frozen_string_literal: true

require_relative 'key_value_store'
require 'rspec'
RSpec.describe KeyValueStore do
  subject(:kvs) { described_class.new }

  let(:key) { 'key1' }
  let(:value) { 'value1' }
  let(:ts) { Time.now.to_f }

  context '#read' do
    context 'non-existent key' do
      it 'should return nil' do
        expect(kvs.read(key)).to be_nil
      end
    end

    context 'existing key' do
      before do
        expect(kvs).to receive(:current_time).and_return(ts)
        kvs.write(key, value)
      end

      it 'should return value' do
        expect(kvs.read(key)).to eq(value)
      end
    end
  end

  context '#write' do
    context 'writes a key' do
      it 'should save the key/value' do
        expect(kvs.read(key)).to be_nil
        kvs.write(key, value)
        expect(kvs.read(key)).to eq value
      end
    end
  end

  context '#delete' do
    context 'deletes an existing key' do
      it 'should save the key/value' do
        expect(kvs.read(key)).to be_nil
        kvs.write(key, value)
        expect(kvs.read(key)).to eq value
        kvs.delete(key)
        expect(kvs.read(key)).to be_nil
      end
    end
  end

  context '#read_at_time' do
    context 'given three timestamps it returns the correct one' do
      let(:timestamps) { [Time.now.to_f - 10, Time.now.to_f - 5, Time.now.to_f] }
      subject(:read_at_time) { kvs.read_at_time(key, time) }

      before do
        timestamps.each_with_index do |ts, index|
          expect(kvs).to receive(:current_time).and_return(ts)
          kvs.write(key, "#{value}.#{index}")
        end
      end

      describe 'timestamp in the middle' do
        let(:time) { timestamps.first + 7 }
        let(:expected_value) { "#{value}.1" }
        it { is_expected.to eq expected_value }
      end

      describe 'timestamp in the future' do
        let(:time) { timestamps.first + 12 }
        let(:expected_value) { "#{value}.2" }
        it { is_expected.to eq expected_value }
      end

      describe 'timestamp is in the past' do
        let(:time) { timestamps.first - 10 }
        let(:expected_value) { "#{value}.1" }
        it { is_expected.to be_nil }
      end
    end
  end
end
