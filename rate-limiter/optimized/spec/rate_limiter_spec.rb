# frozen_string_literal: true

module Rate
  RSpec.describe Limiter do
    let(:period) { 600 }
    let(:max_allowed) { 3 }

    def limiter(*times)
      q = times.each
      described_class.new(period:, max_allowed:, clock: -> { q.next })
    end

    describe '#allowed?' do
      it 'allows up to max_allowed in one window, then denies' do
        t = 100.0
        l = limiter(t, t + 1, t + 2, t + 3)
        3.times { expect(l.allowed?(user_id: 'u')).to be true }
        expect(l.allowed?(user_id: 'u')).to be false
      end

      it 'resets window after period' do
        t = 100.0
        l = limiter(t, t + 1, t + 2, t + 3, t + period + 1)
        3.times { expect(l.allowed?(user_id: 'u')).to be true }
        expect(l.allowed?(user_id: 'u')).to be false
        expect(l.allowed?(user_id: 'u')).to be true
      end

      it 'tracks each user separately' do
        t = 100.0
        l = limiter(t, t, t, t, t, t)
        3.times { expect(l.allowed?(user_id: 'a')).to be true }
        expect(l.allowed?(user_id: 'a')).to be false
        expect(l.allowed?(user_id: 'b')).to be true
      end

      it 'starts new window when now >= start + period' do
        t = 100.0
        l = limiter(t, t + 1, t + 2, t + period)
        3.times { expect(l.allowed?(user_id: 'u')).to be true }
        expect(l.allowed?(user_id: 'u')).to be true
      end
    end
  end
end
