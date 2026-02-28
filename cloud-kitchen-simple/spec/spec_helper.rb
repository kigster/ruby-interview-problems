# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'simplecov'

SimpleCov.start do
  add_filter %r{^/(spec|design)/}
end

if ENV['CODECOV_TOKEN']
  require 'codecov'
  SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
                                                                    SimpleCov::Formatter::HTMLFormatter,
                                                                    SimpleCov::Formatter::Codecov
                                                                  ])
end

require 'kitchen'
require 'output_debug'

OutputDebug.enabled = false

RSpec.configure do |config|
  config.example_status_persistence_file_path = './tmp/rspec-examples.txt'
  config.filter_run_when_matching :focus

  config.expect_with :rspec do |expectations|
    expectations.syntax                                               = :expect
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_doubled_constant_names = true
    mocks.verify_partial_doubles        = true
  end
end

Dir.glob(File.expand_path('./support/**/*.rb', __dir__)).each { |f| require f }
