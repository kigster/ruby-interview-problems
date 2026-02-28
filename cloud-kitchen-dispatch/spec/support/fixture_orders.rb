# frozen_string_literal: true

require 'active_support/core_ext/hash/keys'

module Cloud
  module Kitchens
    module Dispatch
      module Fixtures
        class << self
          def file
            @file ||= File.expand_path('../fixtures/orders.json', __dir__)
          end

          def order_hashes
            @order_hashes ||= JSON.parse(File.read(file))
          end

          def orders_total
            order_hashes.size
          end

          def [](index)
            raise ArgumentError, "Invalid index #{index}" if index >= orders_total

            Order.new(OrderStruct.new(order_hashes[index]))
          end

          def each_order_hash
            order_hashes.each_with_index do |order, index|
              yield(order, index) if block_given?
            end
          end

          def each_order_struct
            each_order_hash do |order_hash, index|
              yield(OrderStruct.new(**order_hash.symbolize_keys), index) if block_given?
            end
          end

          def each_order
            each_order_struct do |order_struct, index|
              yield(Order.new(order_struct), index) if block_given?
            end
          end
        end
      end
    end
  end
end
