# frozen_string_literal: true

require "rspec/its"
require "fractional/ai"

Fractional::Ai.test_mode = true

# Load shared examples
Dir[File.join(__dir__, "support", "**", "*.rb")].each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  # Filter out long backtrace lines
  config.filter_gems_from_backtrace "bundler"

  # Use color output
  config.color = true

  # Use documentation format
  config.default_formatter = "doc"
end
