# frozen_string_literal: true

require_relative 'ip_parser'

class IPV4Parser < IPParser
  # Input: 127.0.0.1
  # Output: array [127, 0, 0, 1]
  def parse
    ip.split('.').map(&:to_i)
  end

  def valid?
    ip_elements = parse

    return false unless ip_elements.size == 4
    return false unless ip_elements.all? { |e| (0..256).include?(e) }

    true
  end
end
