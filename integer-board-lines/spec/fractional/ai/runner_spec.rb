# frozen_string_literal: true

require "spec_helper"

module Fractional
  module Ai
    RSpec.describe Runner do
      let(:argv) { [] }
      let(:launcher) do
        double(
          "launcher",
          argv: argv,
          stdout: stdout,
          stderr: stderr,
          kernel: kernel
        )
      end
      let(:stdout) { double("stdout") }
      let(:stderr) { double("stderr") }
      let(:kernel) { double("kernel") }
      let(:runner) { described_class.new(launcher: launcher) }

      subject { runner }

      describe "BoardParams struct" do
        let(:board_params) { BoardParams.new }

        it "defines BoardParams struct with correct attributes" do
          expect(board_params).to respond_to(
            :board,
            :left_top_coordinate,
            :lines
          )
        end

        it "allows setting and getting values" do
          board = Board.new
          point = Point.new(5, 5)
          lines = [Line.new(Point.new(0, 0), Point.new(1, 1))]

          board_params.board = board
          board_params.left_top_coordinate = point
          board_params.lines = lines

          expect(board_params.board).to eq(board)
          expect(board_params.left_top_coordinate).to eq(point)
          expect(board_params.lines).to eq(lines)
        end
      end

      describe "initialization" do
        its(:argv) { is_expected.to eq(argv) }
        its(:launcher) { is_expected.to eq(launcher) }
        its(:board_params) { is_expected.to be_a(BoardParams) }

        it "duplicates argv to prevent mutation" do
          original_argv = ["--interactive"]
          launcher_with_argv =
            double(
              "launcher",
              argv: original_argv,
              stdout: stdout,
              stderr: stderr,
              kernel: kernel
            )
          runner = described_class.new(launcher: launcher_with_argv)
          runner.argv << "--verbose"
          expect(original_argv).to eq(["--interactive"])
        end

        it "initializes instance variables" do
          expect(runner.board).to be_nil
          expect(runner.left_top_coordinate).to be_nil
          expect(runner.lines).to eq([])
        end
      end

      describe "delegation" do
        it "includes Forwardable" do
          expect(described_class.ancestors).to include(Forwardable)
        end

        it "delegates stdout to launcher" do
          expect(runner).to respond_to(:stdout)
          expect(runner.stdout).to eq(launcher.stdout)
        end

        it "delegates stderr to launcher" do
          expect(runner).to respond_to(:stderr)
          expect(runner.stderr).to eq(launcher.stderr)
        end

        it "delegates kernel to launcher" do
          expect(runner).to respond_to(:kernel)
          expect(runner.kernel).to eq(launcher.kernel)
        end
      end

      describe "#run" do
        let(:ui) { double("ui") }

        before do
          allow(runner).to receive(:configure)
          allow(runner).to receive(:ap) # Mock amazing_print
          allow(Ui).to receive(:new).and_return(ui)
          allow(ui).to receive(:run)

          # Set up board_params
          runner.board_params.board = Board.new(width: 10, height: 10)
          runner.board_params.left_top_coordinate = Point.new(5, 5)
          runner.board_params.lines = []
        end

        it "configures the runner" do
          expect(runner).to receive(:configure)
          runner.run
        end

        it "prints board params" do
          expect(runner).to receive(:ap)
          runner.run
        end

        it "creates and runs UI" do
          expect(Ui).to receive(:new).with(
            board: runner.board_params.board,
            left_top_coordinate: runner.board_params.left_top_coordinate,
            lines: runner.board_params.lines
          )
          expect(ui).to receive(:run)
          runner.run
        end
      end

      describe "#configure" do
        before do
          allow(runner).to receive(:config_file).and_return(config_file)
        end

        context "when config file exists" do
          let(:config_file) { "test_config.json" }
          let(:board) { Board.new(width: 15, height: 12) }
          let(:coordinates) { Point.new(3, 4) }
          let(:lines) { [Line.new(Point.new(0, 0), Point.new(5, 5))] }

          before do
            allow(File).to receive(:exist?).with(config_file).and_return(true)
            allow(runner).to receive(:load_config_from_file).with(
              config_file
            ).and_return([board, coordinates, lines])
          end

          it "loads configuration from file" do
            expect(runner).to receive(:load_config_from_file).with(config_file)
            runner.send(:configure)
          end

          it "sets board_params from loaded configuration" do
            runner.send(:configure)
            expect(runner.board_params.board).to eq(board)
            expect(runner.board_params.left_top_coordinate).to eq(coordinates)
            expect(runner.board_params.lines).to eq(lines)
          end
        end

        context "when config file does not exist" do
          let(:config_file) { "nonexistent.json" }

          before do
            allow(File).to receive(:exist?).with(config_file).and_return(false)
          end

          it "sets default configuration" do
            runner.send(:configure)
            expect(runner.board_params.board).to be_a(Board)
            expect(runner.board_params.board.width).to eq(20)
            expect(runner.board_params.board.height).to eq(20)
            expect(runner.board_params.left_top_coordinate).to eq(
              Point.new(10, 5)
            )
            expect(runner.board_params.lines).to eq([])
          end
        end
      end

      describe "#load_config_from_file" do
        let(:config_file) { "test_config.json" }
        let(:config_json) do
          {
            "board" => {
              "width" => 15,
              "height" => 12,
              "left" => 3,
              "top" => 4
            },
            "lines" => [
              {
                "line" => [{ "x" => 0, "y" => 0 }, { "x" => 5, "y" => 5 }],
                "color" => "red"
              },
              {
                "line" => [{ "x" => 1, "y" => 1 }, { "x" => 3, "y" => 3 }],
                "color" => "blue"
              }
            ]
          }
        end

        before do
          require "json"
          allow(File).to receive(:read).with(config_file).and_return(
            JSON.generate(config_json)
          )
          allow(runner).to receive(:ap) # Mock amazing_print
        end

        it "parses JSON configuration" do
          expect(JSON).to receive(:parse).with(
            JSON.generate(config_json)
          ).and_return(config_json)
          runner.send(:load_config_from_file, config_file)
        end

        it "creates board with correct dimensions" do
          board, _coordinates, _lines =
            runner.send(:load_config_from_file, config_file)
          expect(board).to be_a(Board)
          expect(board.width).to eq(15)
          expect(board.height).to eq(12)
        end

        it "creates left_top_coordinate with correct values" do
          _board, coordinates, _lines =
            runner.send(:load_config_from_file, config_file)
          expect(coordinates).to be_a(Point)
          expect(coordinates.x).to eq(3)
          expect(coordinates.y).to eq(4)
        end

        it "creates lines from configuration" do
          _board, _coordinates, lines =
            runner.send(:load_config_from_file, config_file)
          expect(lines).to be_an(Array)
          expect(lines.length).to eq(2)

          first_line = lines[0]
          expect(first_line).to be_a(Line)
          expect(first_line.p1).to eq(Point.new(0, 0))
          expect(first_line.p2).to eq(Point.new(5, 5))

          second_line = lines[1]
          expect(second_line).to be_a(Line)
          expect(second_line.p1).to eq(Point.new(1, 1))
          expect(second_line.p2).to eq(Point.new(3, 3))
        end

        context "with minimal configuration" do
          let(:config_json) { {} }

          before do
            require "json"
            allow(File).to receive(:read).with(config_file).and_return(
              JSON.generate(config_json)
            )
            allow(runner).to receive(:ap) # Mock amazing_print
          end

          it "handles missing board configuration" do
            board, coordinates, lines =
              runner.send(:load_config_from_file, config_file)
            expect(board.width).to eq(20) # Default fallback
            expect(board.height).to eq(20) # Default fallback
            expect(coordinates.x).to eq(0)
            expect(coordinates.y).to eq(0)
            expect(lines).to eq([])
          end
        end

        context "with missing board dimensions" do
          let(:config_json) { { "board" => {} } }

          before do
            require "json"
            allow(File).to receive(:read).with(config_file).and_return(
              JSON.generate(config_json)
            )
            allow(runner).to receive(:ap) # Mock amazing_print
          end

          it "uses default dimensions" do
            board, _coordinates, _lines =
              runner.send(:load_config_from_file, config_file)
            expect(board.width).to eq(20)
            expect(board.height).to eq(20)
          end
        end

        context "with missing color in lines" do
          let(:config_json) do
            {
              "lines" => [
                { "line" => [{ "x" => 0, "y" => 0 }, { "x" => 5, "y" => 5 }] }
              ]
            }
          end

          before do
            require "json"
            allow(File).to receive(:read).with(config_file).and_return(
              JSON.generate(config_json)
            )
            allow(runner).to receive(:ap) # Mock amazing_print
          end

          it "defaults to white color" do
            _board, _coordinates, lines =
              runner.send(:load_config_from_file, config_file)
            line = lines[0]
            expect(line.instance_variable_get(:@color)).to eq("white")
          end
        end
      end

      describe "error handling" do
        context "when JSON parsing fails" do
          let(:config_file) { "invalid.json" }

          before do
            allow(File).to receive(:read).with(config_file).and_return(
              "invalid json"
            )
            allow(runner).to receive(:config_file).and_return(config_file)
            allow(File).to receive(:exist?).with(config_file).and_return(true)
          end

          it "raises JSON::ParserError" do
            expect {
              runner.send(:load_config_from_file, config_file)
            }.to raise_error(::JSON::ParserError)
          end
        end
      end
    end
  end
end
