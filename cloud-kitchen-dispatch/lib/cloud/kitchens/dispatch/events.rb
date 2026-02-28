# frozen_string_literal: true

require 'ventable'
require 'active_support/inflector'
require 'cloud/kitchens/dispatch/errors'
require 'cloud/kitchens/dispatch/logging'

module Cloud
  module Kitchens
    module Dispatch
      module Events
      end

      module EventPublisher
        class << self
          def included(base)
            base.include(Logging)
          end
        end

        def publish(event, **opts)
          event_class_name = "#{event.to_s.camelize}Event"
          unless Events.const_defined?(event_class_name)
            raise Errors::InvalidEventError, "event name #{event} does not map to an event class"
          end

          event_class = Events.const_get(event_class_name)
          event_class.new(self, **opts).fire!
        rescue Ventable::Error => e
          raise Errors::EventPublishingError, e
        end
      end
    end
  end
end

require_relative 'events/abstract_order_event'
require_relative 'events/order_received_event'
require_relative 'events/order_delivered_event'
require_relative 'events/order_ready_event'
require_relative 'events/order_picked_up_event'
