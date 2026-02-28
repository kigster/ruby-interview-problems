# frozen_string_literal: true

require_relative 'lib/credit_card_validator/version'

Gem::Specification.new do |spec|
  spec.name          = 'credit_card_validator'
  spec.version       = CreditCardValidator::VERSION
  spec.authors       = ['Konstantin Gredeskoul']
  spec.email         = ['kigster@gmail.com']

  spec.summary       = 'Validates credit cards and detects issuer'
  spec.description   = 'Validates credit cards and detects issuer'
  spec.homepage      = 'https://github.com/kigster/interview-questions'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files`.split("\u0000").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
end
