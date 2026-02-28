# frozen_string_literal: true

require 'dry-initializer'
require 'dry-struct'
require_relative 'types'
require 'pp'

module Cloud
  module Kitchens
    module Dispatch
      # Gem identity information.
      class OrderStruct < ::Dry::Struct
        transform_keys(&:to_sym)

        attribute :id, Types::String
        attribute :name, Types::String
        attribute :temp, Types::Temperature
        attribute :state, Types::OrderState
        attribute :shelfLife, Types::Integer
        attribute :decayRate, Types::Float

        def to_s
          "\n#{pretty_inspect}\n"
        end

        alias inspect to_s
      end
    end
  end
end
