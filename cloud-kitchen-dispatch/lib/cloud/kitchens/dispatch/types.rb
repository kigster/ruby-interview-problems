# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require "cloud/kitchens/dispatch/identity"

module Cloud
  module Kitchens
    module Dispatch
      module Types
        include ::Dry.Types()

        Temperature  = String.enum('hot', 'frozen', 'cold')
        OrderState   = String.default('new').enum('new', 'cooking', 'ready', 'delivering', 'delivered', 'expired')
        CourierState = String.default('ready').enum('ready', 'assigned', 'delivering')
      end
    end
  end
end
