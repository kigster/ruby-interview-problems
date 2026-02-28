# frozen_string_literal: true

#  jared.smith@gusto.com

class HashDiff
  attr_accessor :expected, :actual, :diffs

  def initialize(expected, actual)
    self.expected = expected
    self.actual   = actual
    self.diffs    = []
  end

  def compare(one = expected,
              two = actual,
              prefix = '')
    compare_hashes(one, two, prefix)
    compare_hashes(two, one, prefix, -1)
  end

  def append_diff(*args)
    diffs << args
  end

  private

  def compare_hashes(one, two, key_prefix, sign = 1)
    return unless one
    return unless one.is_a?(Hash)

    one.each_pair do |k, one_hash|
      two_hash = two ? two[k] : nil
      next if one_hash == two_hash

      nested_key = "#{"#{key_prefix}." if key_prefix}#{k}"
      determine_diff(nested_key, one_hash, two_hash, sign)
    end
  end

  def determine_diff(nested_key, value1, value2, sign = 1)
    forward_sign = sign.positive? ? '+' : '-'
    sign.positive? ? '-' : '+'

    if value1.is_a?(Hash) || value2.is_a?(Hash)
      compare(value1, value2, nested_key)
    elsif value2.nil? && value1
      append_diff(forward_sign, nested_key, value1)
    end
  end
end
