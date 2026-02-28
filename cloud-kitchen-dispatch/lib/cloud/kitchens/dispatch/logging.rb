# frozen_string_literal: true

require 'tty-logger'
require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/app/config'

module Cloud
  module Kitchens
    module Dispatch
      # This method holds the singleton instance of the @logger
      # variable.
      module Logging
        module LoggingMethods
          class << self
            def included(base)
              base.instance_eval do
                LOGGING_METHODS.each do |log_method|
                  define_method log_method do |msg, *args|
                    return unless logger

                    logger.send(
                      log_method,
                      ::Cloud::Kitchens::Dispatch.colorize(
                        msg,
                        *Array(
                          ::Cloud::Kitchens::Dispatch::Logging::DEFAULT_LOGGING_METHODS[log_method] \
                                  || :normal
                        )
                      ),
                      *args
                    )
                  rescue StandardError => e
                    logger.error(e)
                    logger.info(e.backtrace)
                  end
                end
              end
            end
          end
        end

        @logger ||= nil

        class << self
          def included(base)
            base.include(LoggingMethods)
            base.instance_eval do
              class << self
                include(LoggingMethods)
              end
            end
          end
        end

        # noinspection RubyResolve
        class << self
          def logger
            return @logger if @logger

            if ::Cloud::Kitchens::Dispatch.stdout.nil?
              raise ArgumentError,
                    "Please configure #stdout and #stderr on Dispatch module"
            end

            configure_logger(App::Config.config)
          end

          def configure_logger(*args)
            @logger = create_logger(*args)
          end

          def create_logger(settings, output = log_output(settings))
            if settings.logging.quiet
              TTY::Logger.configure do |config|
                config.handlers = []
              end

              return nil
            end

            TTY::Logger.new(
              output: output,
              fields: (Thread.current.name ? { thread: Thread.current.name } : {})
            ) do |config|
              config.level    = settings.logging.log_level.to_sym
              config.handlers = []
              config.handlers << Logging::CONSOLE_LOG_HANDLER[] unless settings.logging.quiet
              config.metadata = [:time]

              config.types ||= Logging::LOGGING_TYPES

              if settings.logging.log_file
                # create log directory
                FileUtils.mkdir_p(File.dirname(settings.logging.log_file))

                # append log handler
                config.handlers << Logging::FILE_LOG_HANDLER[settings.logging.log_file,
                                                             settings.logging.log_level]
              end
            end
          end

          private

          def log_output(settings)
            if settings.logging.log_file
              File.open(settings.logging.log_file, 'a')
            elsif settings.logging.log_stderr
              ::Cloud::Kitchens::Dispatch.stderr
            else
              ::Cloud::Kitchens::Dispatch.stdout
            end
          end
        end

        LOGGING_TYPES = {
          cooking:    { level: :info },
          ready:      { level: :info },
          delivering: { level: :info },
          expired:    { level: :warning },
          event:      { level: :info },
          invalid:    { level: :error },
        }.freeze

        DEFAULT_LOGGING_METHODS = {
          debug:   %i(black bold),
          info:    %i(cyan),
          success: %i(green bold),
          warn:    %i(yellow),
          error:   %i(red),
          fatal:   %i(red bold),
        }.freeze

        LOGGING_METHODS = (DEFAULT_LOGGING_METHODS.keys + LOGGING_TYPES.keys).freeze

        CONSOLE_LOG_HANDLER = -> {
          [:console, {
            styles: {
              event:      {
                symbol:   ' 💬 ',
                label:    'event',
                color:    :cyan,
                levelpad: 7
              },
              cooking:    {
                symbol:   ' 👩‍🍳 ',
                label:    'cooking',
                color:    :yellow,
                levelpad: 5
              },
              ready:      {
                symbol:   ' 🍜 ',
                label:    'ready',
                color:    :green,
                levelpad: 7
              },
              delivering: {
                symbol:   ' 🚙 ',
                label:    'delivering',
                color:    :green,
                levelpad: 2
              },
              expired:    {
                symbol:   ' ⛔️ ',
                label:    'expired',
                color:    :red,
                levelpad: 5
              },
              invalid:    {
                symbol:   ' 🧨 ',
                label:    ::Cloud::Kitchens::Dispatch.colorize('INVALID', :white, :on_red),
                color:    :red,
                levelpad: 5
              },
            }
          }]
        }

        # noinspection RubyResolve
        FILE_LOG_HANDLER = ->(filename, level) do
          [
            :stream, {
              output: File.open(filename, 'a').tap { |file| file.sync = true },
              level:  level
            }
          ]
        end
      end
    end
  end
end
