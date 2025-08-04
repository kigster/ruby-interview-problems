# frozen_string_literal: true

require "spec_helper"

module Fractional
  module Ai
    RSpec.describe CliParser do
      let(:launcher) do
        double("launcher", stdout: stdout, stderr: stderr, kernel: kernel)
      end
      let(:stdout) { double("stdout") }
      let(:stderr) { double("stderr") }
      let(:kernel) { double("kernel") }
      let(:argv) { [] }
      let(:parser) { described_class.new(launcher: launcher, argv: argv) }

      subject { parser }

      describe "Configuration struct" do
        let(:config) { described_class::Configuration.new }

        it "defines Configuration struct with correct attributes" do
          expect(config).to respond_to(
            :config_file,
            :config_file_contents,
            :interactive,
            :verbose
          )
        end

        it "allows setting and getting values" do
          config.config_file = "test.json"
          config.interactive = true
          config.verbose = true

          expect(config.config_file).to eq("test.json")
          expect(config.interactive).to be true
          expect(config.verbose).to be true
        end
      end

      describe "initialization" do
        its(:argv) { is_expected.to eq(argv) }

        it "duplicates argv to prevent mutation" do
          original_argv = ["--interactive"]
          parser = described_class.new(launcher: launcher, argv: original_argv)
          parser.argv << "--verbose"
          expect(original_argv).to eq(["--interactive"])
        end

        it "creates new Configuration instance" do
          expect(parser.configuration).to be_a(described_class::Configuration)
        end

        it "delegates stdout, stderr, kernel to launcher" do
          expect(parser.stdout).to eq(stdout)
          expect(parser.stderr).to eq(stderr)
          expect(parser.kernel).to eq(kernel)
        end
      end

      describe "#parse" do
        context "with no arguments" do
          let(:argv) { [] }

          it "returns configuration with default values" do
            config = parser.parse
            expect(config.config_file).to be_nil
            expect(config.interactive).to be_falsy
            expect(config.verbose).to be_falsy
          end
        end

        context "with --interactive flag" do
          let(:argv) { ["--interactive"] }

          it "sets interactive to true" do
            config = parser.parse
            expect(config.interactive).to be true
          end
        end

        context "with -i flag" do
          let(:argv) { ["-i"] }

          it "sets interactive to true" do
            config = parser.parse
            expect(config.interactive).to be true
          end
        end

        context "with --config-file option" do
          let(:config_file) { "test_config.json" }
          let(:argv) { ["--config-file", config_file] }

          it "sets config_file" do
            config = parser.parse
            expect(config.config_file).to eq(config_file)
          end
        end

        context "with -c option" do
          let(:config_file) { "test_config.json" }
          let(:argv) { ["-c", config_file] }

          it "sets config_file" do
            config = parser.parse
            expect(config.config_file).to eq(config_file)
          end
        end

        context "with --verbose flag" do
          let(:argv) { ["--verbose"] }

          it "sets verbose to true" do
            config = parser.parse
            expect(config.verbose).to be true
          end
        end

        context "with -v flag" do
          let(:argv) { ["-v"] }

          it "sets verbose to true" do
            config = parser.parse
            expect(config.verbose).to be true
          end
        end

        context "with --help flag" do
          let(:argv) { ["--help"] }

          before do
            allow(stdout).to receive(:puts)
            allow(parser).to receive(:exit)
          end

          it "prints help and exits" do
            expect(stdout).to receive(:puts).with(/Usage:/)
            expect(parser).to receive(:exit)
            parser.parse
          end
        end

        context "with -h flag" do
          let(:argv) { ["-h"] }

          before do
            allow(stdout).to receive(:puts)
            allow(parser).to receive(:exit)
          end

          it "prints help and exits" do
            expect(stdout).to receive(:puts).with(/Usage:/)
            expect(parser).to receive(:exit)
            parser.parse
          end
        end

        context "with multiple flags" do
          let(:argv) { %w[--interactive --verbose -c config.json] }

          it "sets all flags correctly" do
            config = parser.parse
            expect(config.interactive).to be true
            expect(config.verbose).to be true
            expect(config.config_file).to eq("config.json")
          end
        end

        context "with invalid arguments" do
          let(:argv) { ["--invalid-option"] }

          it "raises OptionParser::InvalidOption" do
            expect { parser.parse }.to raise_error(OptionParser::InvalidOption)
          end
        end
      end

      describe "delegation" do
        it "includes Forwardable" do
          expect(described_class.ancestors).to include(Forwardable)
        end

        it "delegates stdout to launcher" do
          expect(parser).to respond_to(:stdout)
          expect(parser.stdout).to eq(launcher.stdout)
        end

        it "delegates stderr to launcher" do
          expect(parser).to respond_to(:stderr)
          expect(parser.stderr).to eq(launcher.stderr)
        end

        it "delegates kernel to launcher" do
          expect(parser).to respond_to(:kernel)
          expect(parser.kernel).to eq(launcher.kernel)
        end
      end

      describe "banner message" do
        let(:argv) { ["-h"] }

        before do
          allow(stdout).to receive(:puts)
          allow(parser).to receive(:exit)
        end

        it "includes correct usage information" do
          expect(stdout).to receive(:puts) do |output|
            expect(output.to_s).to include("Usage:")
            expect(output.to_s).to include("[options]")
          end
          parser.parse
        end
      end

      describe "option descriptions" do
        let(:argv) { ["-h"] }

        before do
          allow(stdout).to receive(:puts)
          allow(parser).to receive(:exit)
        end

        it "includes all option descriptions" do
          expect(stdout).to receive(:puts) do |output|
            output_str = output.to_s
            expect(output_str).to include("config-file")
            expect(output_str).to include("Path to the JSON config file")
            expect(output_str).to include("interactive")
            expect(output_str).to include("Interactive mode")
            expect(output_str).to include("verbose")
            expect(output_str).to include("Print verbose output")
            expect(output_str).to include("help")
            expect(output_str).to include("Print help")
          end
          parser.parse
        end
      end
    end
  end
end
