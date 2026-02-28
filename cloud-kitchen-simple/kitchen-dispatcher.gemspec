# frozen_string_literal: true

lib_path = "#{File.expand_path(__dir__)}/lib"
$LOAD_PATH << lib_path if Dir.exist?(lib_path)

require 'kitchen/version'

Gem::Specification.new do |spec|
  spec.name     = 'kitchen-dispatcher'
  spec.version  = Kitchen::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors  = ['Konstantin Gredeskoul']
  spec.email    = ['kigster@gmail.com']
  spec.homepage = 'https://github.com/kigster/kitchen'
  spec.summary  = 'Order fulfillment simulation with couriers picking up orders placed on appropriate shelves.'
  spec.license  = 'MIT'

  spec.metadata = {
    'source_code_ursi' => 'https://github.com/kigster/kitchen',
    'rubygems_mfa_required' => 'true'
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain  = [Gem.default_cert_path]

  spec.add_dependency 'colored2'
  spec.add_dependency 'dry-initializer'
  spec.add_dependency 'dry-struct'
  spec.add_dependency 'dry-types'
  spec.add_dependency 'uuid'

  spec.add_development_dependency 'asciidoc'
  spec.add_development_dependency 'asciidoctor'
  spec.add_development_dependency 'asciidoctor-pdf'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'
  spec.add_development_dependency 'yard-dry-initializer'
  spec.add_development_dependency 'yard-rspec'

  spec.files            = Dir['lib/**/*', 'design/**/*', 'exe/*']
  spec.extra_rdoc_files = Dir['README.adoc', 'LICENSE.adoc',]
  spec.executables << 'kitchen-ctl'

  spec.require_paths = ['lib']
end
