# frozen_string_literal: true

# vim: ft=ruby
require 'rake'
require 'colored2'

def run(command)
  puts "$ #{command.bold.yellow}"
  puts `#{command}`
  $?
end

def h1(text)
  puts(("—" * 80).white.on.blue)
  puts sprintf("  %-75.75s   ", text).bold.white.on.blue
  puts(("—" * 80).white.on.blue)
  puts
end

desc 'Run bundle update for all solutions'
task :upgrade do
  $stdout.sync = true
  Dir.glob('[a-z]*').each do |entry|
    next unless File.directory?(entry)
    next if File.exist?("#{entry}/.skip")

    Dir.chdir(entry) do
      `bundle update`
    end
  end
end

namespace :solutions do
  desc 'Run RSpecs for all solutions'
  task :specs do
    code = 0
    $stdout.sync = true
    Dir.glob('[a-z]*').each do |entry|
      next unless File.directory?(entry)
      next if File.exist?("#{entry}/.skip")

      h1 entry

      Dir.chdir(entry) {
        begin
          run('bundle check || bundle install') && run('bundle exec rspec --format progress --force-color -p1')
          code += $? == 0 ? 0 : 1
        rescue StandardError => e
          code += 1
          warn "Error running #{entry.to_s.red}: #{e.inspect.red.bold}"
        end
      }
    end

    h1 "Total number of errors: #{code}"

    if code > 0
      raise "RSpecs failed"
    end
  end
end

task default: 'solutions:specs'
