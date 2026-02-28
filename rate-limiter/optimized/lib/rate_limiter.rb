# frozen_string_literal: true

# Per-user rate limiter: N actions per time window. Returns true if allowed, false when over limit.
# Inject +clock+ (callable returning seconds) for deterministic tests.

module Rate
  class Limiter
    def initialize(period:, max_allowed:, clock: -> { Time.now.to_f })
      @period = period
      @max_allowed = max_allowed
      @clock = clock
      @windows = {}
    end

    def allowed?(user_id:)
      now = @clock[]
      w = @windows[user_id]

      if !w || now >= w[:start] + @period
        @windows[user_id] = { start: now, count: 1 }
        true
      elsif w[:count] < @max_allowed
        w[:count] += 1
        true
      else
        false
      end
    end
  end
end
