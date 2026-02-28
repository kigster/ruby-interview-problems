#!/usr/bin/env ruby
# frozen_string_literal: true

# vim: ft=ruby
# rubocop: disable

require 'forwardable'
require 'json'
require 'colored2'

require 'dry-initializer'
require 'dry-struct'
require 'dry-types'

require_relative 'core_ext'
require_relative 'output_debug'

require_relative 'kitchen/sous_chef'
require_relative 'kitchen/order'
require_relative 'kitchen/shelf'
require_relative 'kitchen/cabinet'
require_relative 'kitchen/courier'

# Main module where all of the kitchen and order dispatching
# happens.
module Kitchen
  DEFAULT_FILE = 'orders.json'

  MAX_COURIER_DELAY = 10.0
  MIN_COURIER_DELAY = 4.0

  COURIER_WAIT = -> do
    delay = MIN_COURIER_DELAY + ((MAX_COURIER_DELAY - MIN_COURIER_DELAY) * rand)
    sleep(delay)
  end

  ORDER_RATE          = 20.0 # per second
  ORDER_RECEIVED_WAIT = -> do
    sleep((1.0 / ORDER_RATE.to_f) + (0.1 * (0.5 + rand)))
  end

  def self.order_id(order_or_id)
    case order_or_id
    when String
      order_or_id
    when Order
      order_or_id.id
    else
      raise TypeError, "Invalid argument type #{order_or_id.inspect}"
    end
  end
end

include OutputDebug
