# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'
require 'yard'
require 'colored2'

def shell(*args)
  puts "❯ #{args.join(' ').bold.green}"
  system(args.join(' '))
end

desc 'Clean generated folders such as pkg, log and coverage'
task :clean do
  shell('rm -rf pkg/ coverage/ log/')
  shell("chmod -v o+r,g+r * */* */*/* */*/*/* */*/*/*/* */*/*/*/*/*")
  shell("find . -type d -exec chmod o+x,g+x {} \\;")
end

task build: :clean

YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = %w(lib/**/*.rb exe/*.rb - README.adoc LICENSE.md)
  t.options.unshift('--title', '"SimpleFeed — Fast and Scalable "write-time" Simple Feed for Social Networks, with a Redis-based default backend implementation."')
  t.after = -> { exec('open doc/index.html') } if RUBY_PLATFORM =~ /darwin/
end

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop)

task default: %i[spec rubocop]
