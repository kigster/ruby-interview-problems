# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IPV4Parser do
  let(:ip4) { '120.4.234.0' }
  let(:parser) { described_class.new(ip4) }

  describe '#parse' do
    it 'should split IP into four parts' do
      expect(parser.parse).to eq [120, 4, 234, 0]
    end
  end

  describe '#valid?' do
    it 'should validate IP' do
      expect(parser).to be_valid
    end
  end
end
