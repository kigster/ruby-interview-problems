# frozen_string_literal: true

require "colored2"

module Fractional
  module Ai
    # This launcher exists to enable aruba testing.
    # @see https://kig.re/2020/09/07/writing-cli-tools-ruby-migrating-github-issues-to-pivotal-tracker.html
    class Launcher
      attr_accessor :argv, :stdin, :stdout, :stderr, :kernel, :config

      MUTEX = Mutex.new

      class << self
        def launch!(argv)
          MUTEX.synchronize { new(argv).execute! }
        end
      end

      def initialize(
        argv,
        stdin = $stdin,
        stdout = $stdout,
        stderr = $stderr,
        kernel = Kernel
      )
        self.argv = argv
        self.stdin = stdin
        self.stdout = stdout
        self.stderr = stderr
        self.kernel = kernel

        argv = %w[-h] if argv.nil? || argv.empty?

        self.config = CliParser.new(launcher: self, argv: argv).parse
        Fractional::Ai.configuration = config

        if config.config_file && config.interactive
          raise Errors::ConfigurationError,
                "Config file and Interactive mode are mutually exclusive."
        end

        if config.config_file && !File.exist?(config.config_file)
          raise Errors::ConfigurationError,
                "Config file does not exist: #{config.config_file}"
        end

        if config.config_file && !File.readable?(config.config_file)
          raise Errors::ConfigurationError,
                "Config file is not readable: #{config.config_file}"
        end

        unless config.config_file && File.extname(config.config_file) != ".json"
          return
        end

        raise Errors::ConfigurationError,
              "Config file must be a JSON file: #{config.config_file}"
      end

      def execute!
        code = 0

        Runner.new(launcher: self).run

        # Only exit if we're in interactive mode, otherwise let the process continue
        # so the user can see the drawn lines
        unless config.interactive
          puts "\nPress any key to exit...".green
          begin
            require "io/console"
            stdin.getch unless Fractional::Ai.test_mode
          rescue LoadError
            # Fallback if io/console is not available
            stdin.gets unless Fractional::Ai.test_mode
          end
        end
      rescue StandardError => e
        puts e.inspect.red
        puts e.backtrace.join("\n").red.italic
        code = 1
      ensure
        kernel.exit(code) if config.interactive || code != 0
      end
    end
  end
end
