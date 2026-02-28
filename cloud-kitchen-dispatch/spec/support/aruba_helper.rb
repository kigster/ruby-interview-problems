# frozen_string_literal: true

LogFileWrapper = Struct.new(:filename, :content) do
  def initialize(filename)
    super(filename)
    puts unless File.exist?(filename)
  end

  def puts(*args)
    File.open(filename, 'a') do |file|
      file.puts(*args)
    end
  end

  def content
    File.read(filename)
  end

  def rm!
    FileUtils.rm_f(filename)
  end
end

RSpec.shared_context 'aruba setup', shared_context: :aruba_setup do
  let(:binary) { ::Cloud::Kitchens::Dispatch::BINARY }
  let(:args) { [] }
  let(:command) { "#{File.basename(binary)} #{args.join(' ')}" }
  let(:log_path) { Tempfile.new('kitchen').path }
  let(:log_file) { LogFileWrapper.new(log_path) }

  after(:each, type: :aruba) { log_file.rm! }

  before { run_command_and_stop(command) }

  let(:cmd) { last_command_started }

  let(:stdout) { cmd.stdout.chomp }
  let(:stderr) { cmd.stderr.chomp }
end

RSpec.configure do |rspec|
  rspec.include_context 'aruba setup', include_shared: true
end
