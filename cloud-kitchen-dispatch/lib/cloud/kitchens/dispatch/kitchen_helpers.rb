# frozen_string_literal: true

require 'cloud/kitchens/dispatch/app/config'
require 'cloud/kitchens/dispatch/logging'

module Cloud
  module Kitchens
    module Dispatch
      module KitchenHelpers
        def self.included(base)
          base.include(Logging)
          base.extend(KitchenHelpers)
        end

        def colorize(string, *colors)
          COLOR.decorate(string, *colors)
        end

        def configure
          yield(app_config)
        end

        def app_config
          App::Config.config
        end

        def log_event(event)
          logger.info("order event ❯ #{event.order.color_inspect}", event: event_name(event), from: event.producer)
        end

        def logger
          ::Cloud::Kitchens::Dispatch::Logging.logger
        end

        def configure_logger(*args)
          ::Cloud::Kitchens::Dispatch::Logging.configure_logger(*args)
        end

        def help?
          !(%w[help -h --help] & ARGV).empty?
        end

        def stderr
          ::Cloud::Kitchens::Dispatch.launcher.stderr
        end

        def stdout
          ::Cloud::Kitchens::Dispatch.launcher.stderr
        end

        def event_name(event)
          (event.is_a?(Class) ? event.name : event.class.name).
            gsub(/.*Events/, '').
                                                                gsub(/Event$/, '').
                                                                underscore
        end
      end
    end
  end
end
