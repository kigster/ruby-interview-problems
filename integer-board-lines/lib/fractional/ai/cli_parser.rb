require "forwardable"
require "optparse"

module Fractional
  module Ai
    class CliParser
      Configuration =
        Struct.new(:config_file, :config_file_contents, :interactive, :verbose)

      attr_reader :argv,
                  :config_file,
                  :config_file_contents,
                  :configuration,
                  :interactive,
                  :verbose

      extend Forwardable
      def_delegators :@launcher, :stdout, :stderr, :kernel

      def initialize(launcher:, argv:)
        @argv = argv.dup
        @launcher = launcher
        @configuration = Configuration.new
      end

      def parse
        # Pleeae write a parser that will parse the argv and return a hash of options
        # The options should be:
        # - config_file — if provided, starts non-interactive mode, draws lines and exists
        # - interactive - if provided, starts interactive mode, asks for coordinates and draws lines
        # - verbose - if provided, prints verbose output such as coordinates of the lines
        # Use built-in OptParse for this.
        options =
          OptionParser.new do |opts|
            opts.banner = "Usage: #{File.basename($0)} [options]"

            opts.on(
              "-c",
              "--config-file FILE",
              "Path to the JSON config file"
            ) { |file| configuration.config_file = file }

            opts.on(
              "-i",
              "--interactive",
              "Interactive mode, ask user for lines."
            ) { configuration.interactive = true }

            opts.on("-v", "--verbose", "Print verbose output") do
              configuration.verbose = true
            end

            opts.on("-h", "--help", "Print help") do
              stdout.puts opts
              exit
            end
          end
        options.parse!(@argv)

        configuration
      end
    end
  end
end
