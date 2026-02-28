# frozen_string_literal: true

require 'dry-configurable'

module Cloud
  module Kitchens
    module Dispatch
      module App
        class Config
          extend ::Dry::Configurable

          setting :total, reader: true do
            setting :couriers
            setting :shelf_capacity, 10
          end

          setting :logging, reader: true do
            setting :log_level, :debug
            setting :log_stderr, false
            setting :log_file, nil
            setting :quiet, false
            setting :debug, false
            setting :trace, false
          end

          setting :order, reader: true do
            setting :source, 'orders.json', reader: true
            setting :rate, 2.0
          end
        end
      end
    end
  end
end
