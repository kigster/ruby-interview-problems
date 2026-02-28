# frozen_string_literal: true

require 'rspec/autorun'

RSpec.describe RateLimiter do
  let(:period) { 0.1 }
  let(:max_allowed) { 3 }
  let(:rate_limiter) { described_class.new(period:, max_allowed:) }
  let(:user_id) { 1 }

  describe "under the rate limit" do
    it 'should not be rate limited if the number if less than max_allowed' do
      2.times do
        sleep(0.02)
        expect(rate_limiter.is_allowed(user_id:)).to be_truthy
      end
    end
  end

  describe "under the rate limit" do
    it 'should not be rate limited if the number if less than max_allowed' do
      5.times do
        sleep(0.01)
        expect(rate_limiter.is_allowed(user_id:)).to be_truthy
      end
    end
  end

  describe "over rate limit" do
    it "should be over the limit" do
      sleep(0.01)
      expect(rate_limiter.is_allowed(user_id:)).to be(true)
      sleep(0.01)
      expect(rate_limiter.is_allowed(user_id:)).to be(true)
      sleep(0.05)
      expect(rate_limiter.is_allowed(user_id:)).to be(true)
    end
  end
end
