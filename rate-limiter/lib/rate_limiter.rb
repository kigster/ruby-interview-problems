# frozen_string_literal: true

# Implement a rate limiter that allows N requests per time window per user.
# The interface should be something like isAllowed(userId: string): boolean.
# if number of req reaches N during 10 minutes period we return false until
# 10 minute period resets, then we start returning true, until we hit N again
# or end of 10 minute period.

class RateLimiter
  attr_reader :period, :max_allowed, :period_start, :period_end, :user_cache

  def initialize(period:, max_allowed:)
    @period = period
    @max_allowed = max_allowed
    @period_start = now
    @period_end = @period_start + period
    @user_cache = {} # user_id =>  count
  end

  def is_allowed(user_id:)
    count = @user_cache[user_id]
    if count.nil?
      @user_cache[user_id] = 1
    elsif now - period_start > period
      user_cache[user_id] = 1
    elsif now < period_end
      if user_cache[user_id] < max_allowed
        user_cache[user_id] += 1
      else
        user_cache[user_id] = 1
        @period_start = now
        @period_end = @period_start - @period
      end
    else
      user_cache[user_id] = 1
      @period_start = now
      @period_ned = @period_start - @period
    end
    true
  end

  def inspect
    pp "start=#{period_start}, end=#{period_end}, now=#{now}, user_cache=#{user_cache}"
  end

  private

  def now
    Time.now.to_f
  end
end
