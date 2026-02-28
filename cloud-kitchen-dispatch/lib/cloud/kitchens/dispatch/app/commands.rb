# frozen_string_literal: true

require 'cloud/kitchens/dispatch/app'

module Cloud
  module Kitchens
    module Dispatch
      module App
        module Commands
          extend ::Dry::CLI::Registry

          class << self
            include ::Cloud::Kitchens::Dispatch::Logging
          end

          class BaseCommand < Dry::CLI::Command
            class << self
              def inherited(base)
                super(base)
                base.include(UI)
                base.include(KitchenHelpers)
                base.instance_eval do
                  option :trace,
                         default: nil,
                         type:    :boolean,
                         desc:    'Print full stack trace, if an error occurs',
                         aliases: %w[-t]
                end
              end
            end

            def call(**opts)
              logging_options_to_config :trace, opts[:trace]
            end

            protected

            def logging_options_to_config(option, value)
              logging_setting = option

              assigner = "#{logging_setting}="
              return unless value && app_config.logging.respond_to?(assigner)

              info("setting config.#{assigner}#{value}")
              app_config.logging.send(assigner, value)
            end
          end

          class AbstractOrderCommand < BaseCommand
            include EventPublisher

            class << self
              def inherited(base)
                super(base)
                base.extend(Forwardable)
                base.instance_eval do
                  def_delegators ::Cloud::Kitchens::Dispatch, :colorize, :app_config, :logger

                  option :log_level,
                         values:  Logging::DEFAULT_LOGGING_METHODS.keys.map(&:to_s),
                         desc:    'Logging level',
                         aliases: %w[-ll]

                  option :log_file,
                         default: nil,
                         desc:    'Log events into the specified file',
                         aliases: %w[-L]

                  option :log_stderr,
                         type:    :boolean,
                         default: false,
                         desc:    'When true, the console logs go to STDERR',
                         aliases: %w[-e]

                  option :quiet,
                         type:    :boolean,
                         default: false,
                         desc:    'Enable or disable all logging',
                         aliases: %w[-q]
                end
              end
            end

            def call(**opts)
              %i[log_level log_file log_stderr quiet].each do |setting|
                logging_options_to_config setting, opts[setting]
              end

              ::Cloud::Kitchens::Dispatch.configure_logger(app_config)
            end
          end

          class Version < BaseCommand
            desc Dispatch::PASTEL.yellow('Print version')

            def call(*)
              nil
            end
          end

          class Cook < AbstractOrderCommand
            desc PASTEL.yellow('Open the kitchen to process a given set of orders in a JSON file')

            argument :orders,
                     type:    :string,
                     default: App::Config.config.order.source,
                     desc:    'File path to the orders.json file',
                     aliases: %w[-o --orders]

            option :rate,
                   type:    :float,
                   default: App::Config.config.order.rate,
                   desc:    'Order ingestion rate per second',
                   aliases: %w[-r]

            # noinspection RubyYardParamTypeMatch
            example(['orders.json --rate 2.0',
                     '--orders orders.json',].map { |e| PASTEL.bold.green(e) })

            def call(orders: nil, **opts)
              super(**opts)
              return if help?

              app_config.order.rate   = opts[:rate] if opts[:rate]
              app_config.order.source = orders if orders

              info("Starting dispatcher with config:")
              info(app_config.to_h.pretty_inspect)

              Dispatcher[order_source: orders].start!
            rescue Errors::EventPublishingError => e
              stderr.puts error_box(e, stream: stderr)
            rescue Errno::ENOENT => e
              stderr.puts error_box(e, stream: stderr)
            end
          end

          register 'version', Version, aliases: %w[v --version -v]
          register 'cook', Cook, aliases: %w[c cook]
        end
      end
    end
  end
end
