# frozen_string_literal: true

require_relative 'ip_parser'

class IPV6Parser < IPParser
  # 2001:0db8:0000:0000:0000:ff00:0042:8329
  def parse
    ip.split(':')
  end

  def valid?
    ip_elements = parse

    return false unless ip_elements.size == 8
    return false unless ip_elements.all? { |e| (0..0xffff).include?("0x#{e}".to_i) }

    true
  end
end
