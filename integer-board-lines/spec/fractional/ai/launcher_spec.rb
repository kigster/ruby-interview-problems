# frozen_string_literal: true

require "spec_helper"

module Fractional
  module Ai
    RSpec.describe Launcher do
      let(:argv) { [] }
      let(:stdin) { double("stdin") }
      let(:stdout) { double("stdout") }
      let(:stderr) { double("stderr") }
      let(:kernel) { double("kernel") }
      let(:launcher) do
        described_class.new(argv, stdin, stdout, stderr, kernel)
      end

      subject { launcher }

      describe "class methods" do
        describe ".launch!" do
          let(:launcher_instance) { double("launcher_instance") }

          before do
            allow(described_class).to receive(:new).and_return(
              launcher_instance
            )
            allow(launcher_instance).to receive(:execute!)
          end

          it "synchronizes execution with mutex" do
            expect(described_class::MUTEX).to receive(:synchronize)
            described_class.launch!(argv)
          end

          it "creates new instance and executes" do
            expect(described_class).to receive(:new).with(argv)
            expect(launcher_instance).to receive(:execute!)
            described_class.launch!(argv)
          end
        end
      end

      describe "initialization" do
        let(:cli_parser) { double("cli_parser") }
        let(:config) { double("config", config_file: nil, interactive: false) }

        before do
          allow(CliParser).to receive(:new).and_return(cli_parser)
          allow(cli_parser).to receive(:parse).and_return(config)
        end

        its(:argv) { is_expected.to eq(argv) }
        its(:stdin) { is_expected.to eq(stdin) }
        its(:stdout) { is_expected.to eq(stdout) }
        its(:stderr) { is_expected.to eq(stderr) }
        its(:kernel) { is_expected.to eq(kernel) }
        its(:config) { is_expected.to eq(config) }

        it "duplicates argv to prevent mutation" do
          original_argv = ["--interactive"]
          launcher =
            described_class.new(original_argv, stdin, stdout, stderr, kernel)
          launcher.argv << "--verbose"
          expect(original_argv).to eq(["--interactive"])
        end

        it "creates CLI parser with correct arguments" do
          expect(CliParser).to receive(:new).with(
            launcher: anything,
            argv: argv
          )
          launcher
        end
      end

      describe "configuration validation" do
        let(:cli_parser) { double("cli_parser") }
        let(:config_file) { "test_config.json" }

        before { allow(CliParser).to receive(:new).and_return(cli_parser) }

        context "when both config file and interactive mode are specified" do
          let(:config) do
            double("config", config_file: config_file, interactive: true)
          end

          before { allow(cli_parser).to receive(:parse).and_return(config) }

          it "raises ConfigurationError" do
            expect {
              described_class.new(argv, stdin, stdout, stderr, kernel)
            }.to raise_error(
              Errors::ConfigurationError,
              "Config file and Interactive mode are mutually exclusive."
            )
          end
        end

        context "when config file does not exist" do
          let(:config) do
            double("config", config_file: config_file, interactive: false)
          end

          before do
            allow(cli_parser).to receive(:parse).and_return(config)
            allow(File).to receive(:exist?).with(config_file).and_return(false)
          end

          it "raises ConfigurationError" do
            expect {
              described_class.new(argv, stdin, stdout, stderr, kernel)
            }.to raise_error(
              Errors::ConfigurationError,
              "Config file does not exist: #{config_file}"
            )
          end
        end

        context "when config file is not readable" do
          let(:config) do
            double("config", config_file: config_file, interactive: false)
          end

          before do
            allow(cli_parser).to receive(:parse).and_return(config)
            allow(File).to receive(:exist?).with(config_file).and_return(true)
            allow(File).to receive(:readable?).with(config_file).and_return(
              false
            )
          end

          it "raises ConfigurationError" do
            expect {
              described_class.new(argv, stdin, stdout, stderr, kernel)
            }.to raise_error(
              Errors::ConfigurationError,
              "Config file is not readable: #{config_file}"
            )
          end
        end

        context "when config file is not a JSON file" do
          let(:config_file) { "test_config.txt" }
          let(:config) do
            double("config", config_file: config_file, interactive: false)
          end

          before do
            allow(cli_parser).to receive(:parse).and_return(config)
            allow(File).to receive(:exist?).with(config_file).and_return(true)
            allow(File).to receive(:readable?).with(config_file).and_return(
              true
            )
            allow(File).to receive(:extname).with(config_file).and_return(
              ".txt"
            )
          end

          it "raises ConfigurationError" do
            expect {
              described_class.new(argv, stdin, stdout, stderr, kernel)
            }.to raise_error(
              Errors::ConfigurationError,
              "Config file must be a JSON file: #{config_file}"
            )
          end
        end

        context "with valid JSON config file" do
          let(:config_file) { "test_config.json" }
          let(:config) do
            double("config", config_file: config_file, interactive: false)
          end

          before do
            allow(cli_parser).to receive(:parse).and_return(config)
            allow(File).to receive(:exist?).with(config_file).and_return(true)
            allow(File).to receive(:readable?).with(config_file).and_return(
              true
            )
            allow(File).to receive(:extname).with(config_file).and_return(
              ".json"
            )
          end

          it "does not raise error" do
            expect {
              described_class.new(argv, stdin, stdout, stderr, kernel)
            }.not_to raise_error
          end
        end
      end

      describe "#execute!" do
        let(:runner) { double("runner") }
        let(:cli_parser) { double("cli_parser") }
        let(:config) { double("config", config_file: nil, interactive: false) }

        before do
          allow(CliParser).to receive(:new).and_return(cli_parser)
          allow(cli_parser).to receive(:parse).and_return(config)
          allow(Runner).to receive(:new).and_return(runner)
          allow(runner).to receive(:run)
          allow(kernel).to receive(:exit)
        end

        it "creates and runs runner" do
          expect(Runner).to receive(:new).with(argv: argv, launcher: launcher)
          expect(runner).to receive(:run)
          launcher.execute!
        end

        it "exits with code 0 on success" do
          expect(kernel).to receive(:exit).with(0)
          launcher.execute!
        end

        context "when an error occurs" do
          let(:error) { StandardError.new("test error") }

          before do
            allow(runner).to receive(:run).and_raise(error)
            allow(launcher).to receive(:ap) # Mock amazing_print
          end

          it "prints the error and still exits" do
            expect(launcher).to receive(:ap).with(error)
            expect(kernel).to receive(:exit).with(0)
            launcher.execute!
          end
        end
      end

      describe "constants" do
        it "defines MUTEX constant" do
          expect(described_class::MUTEX).to be_a(Mutex)
        end
      end

      describe "thread safety" do
        it "uses the same mutex instance across calls" do
          mutex1 = described_class::MUTEX
          mutex2 = described_class::MUTEX
          expect(mutex1).to be(mutex2)
        end
      end
    end
  end
end
