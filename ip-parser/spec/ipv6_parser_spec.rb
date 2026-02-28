# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IPV6Parser do
  let(:ip6) { '2001:0db8:0000:0000:0000:ff00:0042:8329' }

  let(:parser) { described_class.new(ip6) }

  describe '#parse' do
    it 'should split IP into four parts' do
      expect(parser.parse).to eq %w(2001 0db8 0000 0000 0000 ff00 0042 8329)
    end
  end

  describe '#valid?' do
    it 'should validate IP' do
      expect(parser).to be_valid
    end
  end
end
