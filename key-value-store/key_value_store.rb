# frozen_string_literal: true

require 'rspec/autorun'

class KeyValueStore
  attr_accessor :store

  def initialize
    self.store = {}
  end

  def read(key)
    return nil unless store[key]

    store[key][store[key].keys.max]
  end

  def read_at_time(key, time)
    return nil unless store[key]

    ts = find_closest(store[key].keys.sort, time)

    store[key][ts]
  end

  def write(key, value)
    time = current_time
    store[key] ||= {}
    store[key][time] = value
  end

  def delete(key)
    store.delete(key)
  end

  # timestamp is sorted
  def find_closest(timestamps, time)
    return nil if time < timestamps.first

    timestamps.each_with_index do |ts, index|
      if index < timestamps.size - 1
        return ts if time >= ts && time < timestamps[index + 1]
      elsif time >= ts
        return ts
      end
    end

    nil
  end

  def current_time
    Time.now.to_f
  end
end
