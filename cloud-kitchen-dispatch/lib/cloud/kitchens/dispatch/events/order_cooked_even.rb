# frozen_string_literal: true

require 'ventable'
require_relative 'abstract_order_event'

module Cloud
  module Kitchens
    module Dispatch
      module Events
        class OrderCookedEvent < AbstractOrderEvent
        end
      end
    end
  end
end
