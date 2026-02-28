# frozen_string_literal: true

lib_path = "#{File.expand_path(__dir__)}/lib"
$LOAD_PATH << lib_path if Dir.exist?(lib_path)

require 'cloud/kitchens/dispatch/identity'

Gem::Specification.new do |spec|
  spec.name = Cloud::Kitchens::Dispatch::Identity::NAME
  spec.version = Cloud::Kitchens::Dispatch::Identity::VERSION
  spec.platform = Gem::Platform::RUBY
  spec.authors = ['Konstantin Gredeskoul']
  spec.email = ['kigster@gmail.com']
  spec.homepage = 'https://github.com/kigster/kitchen-ctl'
  spec.summary = 'Order fulfillment simulation'
  spec.license = 'MIT'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/kigster/kitchen-ctl',
    'changelog_uri' => 'https://github.com/kigster/kitchen-ctl/blob/master/CHANGES.md',
    'bug_tracker_uri' => 'https://github.com/kigster/kitchen-ctl/issues'
  }

  spec.signing_key = Gem.default_key_path
  spec.cert_chain = [Gem.default_cert_path]

  spec.add_dependency 'aasm'
  spec.add_dependency 'activesupport'
  spec.add_dependency 'colored2'
  spec.add_dependency 'dry-auto_inject'
  spec.add_dependency 'dry-cli'
  spec.add_dependency 'dry-configurable'
  spec.add_dependency 'dry-container'
  spec.add_dependency 'dry-initializer'
  spec.add_dependency 'dry-struct'
  spec.add_dependency 'dry-types'
  spec.add_dependency 'pastel', '~> 0.7.2'
  spec.add_dependency 'tty-box'
  spec.add_dependency 'tty-font'
  spec.add_dependency 'tty-logger'
  spec.add_dependency 'tty-screen'
  spec.add_dependency 'tty-table'
  spec.add_dependency 'tty-tree'
  spec.add_dependency 'ventable'

  spec.add_development_dependency 'aruba', '= 1.0.0'
  spec.add_development_dependency 'asciidoctor'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'yard'

  spec.files = Dir['lib/**/*']
  spec.extra_rdoc_files = Dir['README*', 'LICENSE*']
  spec.executables << 'kitchen-ctl'

  spec.require_paths = ['lib']
end
