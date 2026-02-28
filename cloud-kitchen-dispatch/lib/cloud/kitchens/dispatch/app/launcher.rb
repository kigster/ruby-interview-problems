# frozen_string_literal: true

require 'active_support/core_ext/string'

require 'forwardable'
require 'stringio'
require 'dry/cli'
require 'dry/cli/parser'
require 'tty/box'
require 'tty/screen'

require 'cloud/kitchens/dispatch'
require 'cloud/kitchens/dispatch/ui'
require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/app/commands'
require 'cloud/kitchens/dispatch/app/config'

::Dry::CLI.class_eval do
  def exit(*)
    nil
  end
end
module Cloud
  module Kitchens
    module Dispatch
      module App
        class << self
          def screen_width
            @screen_width ||= [TTY::Screen.width, 150].min - 10
          end
        end

        class Launcher
          class << self
            attr_accessor :launcher
          end

          attr_accessor :argv, :stdin, :stdout, :stderr, :kernel, :trace

          include UI

          def initialize(argv, stdin = $stdin, stdout = $stdout, stderr = $stderr, kernel = nil)
            if ::Cloud::Kitchens::Dispatch.launcher
              raise(ArgumentError, 'Another instance of CLI Launcher was detected, aborting.')
            end

            Launcher.launcher = self

            ::Cloud::Kitchens::Dispatch.stdout = stdout
            ::Cloud::Kitchens::Dispatch.stderr = stderr
            ::Cloud::Kitchens::Dispatch.launcher = self

            self.argv   = argv
            self.stdin  = stdin
            self.stdout = stdout
            self.stderr = stderr
            self.kernel = kernel

            self.trace = !ENV['TRACE'].nil?
          end

          def execute!
            stdout.puts

            if argv.empty? || argv?(%w(--help -h help version -v --version))
              print_header(stream: stdout) unless test?
              stdout.puts cursor.down(2) unless test?
              argv << '--help' if argv.empty?
            end

            # self.trace = true if argv?('-t')
            # argv << '--trace' if argv?('-t') && !argv?('--trace')
            argv << '--help' if argv?('help') && !argv?('--trace')

            # noinspection RubyYardParamTypeMatch
            ::Dry::CLI.new(::Cloud::Kitchens::Dispatch::App::Commands) \
              .call(arguments: argv, out: stdout, err: stderr)
            nil
          rescue StandardError => e
            process_error(e, stream: stderr); e
          ensure
            2.times { stdout.puts } unless test?
          end
        end
      end
    end
  end
end
