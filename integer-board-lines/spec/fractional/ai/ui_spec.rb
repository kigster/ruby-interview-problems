# frozen_string_literal: true

require "spec_helper"

module Fractional
  module Ai
    RSpec.describe Ui do
      let(:board) { Board.new(width: 10, height: 8) }
      let(:left_top_coordinate) { Point.new(5, 4) }
      let(:lines) { [] }
      let(:ui) do
        described_class.new(
          board: board,
          left_top_coordinate: left_top_coordinate,
          lines: lines
        )
      end

      subject { ui }

      describe "initialization" do
        its(:board) { is_expected.to eq(board) }
        its(:left) { is_expected.to eq(5) }
        its(:top) { is_expected.to eq(4) }

        context "with default board coordinates" do
          let(:ui) { described_class.new(board: board, lines: lines) }

          its(:left) { is_expected.to eq(5) } # board.width / 2
          its(:top) { is_expected.to eq(4) } # board.height / 2
        end

        context "with specific board coordinates" do
          let(:left_top_coordinate) { Point.new(2, 3) }

          its(:left) { is_expected.to eq(2) }
          its(:top) { is_expected.to eq(3) }
        end

        context "with pre-loaded lines" do
          let(:lines) { [Line.new(Point.new(0, 0), Point.new(2, 2))] }

          it "stores the lines" do
            expect(ui.instance_variable_get(:@lines)).to eq(lines)
          end
        end
      end

      describe "delegation to board" do
        its(:width) { is_expected.to eq(board.width) }
        its(:height) { is_expected.to eq(board.height) }
        its(:rows) { is_expected.to eq(board.rows) }

        it "delegates width to board" do
          expect(ui.width).to eq(10)
        end

        it "delegates height to board" do
          expect(ui.height).to eq(8)
        end

        it "delegates rows to board" do
          expect(ui.rows).to be_a(Array)
          expect(ui.rows.length).to eq(8)
        end
      end

      describe "constants" do
        it "defines CELL_WIDTH" do
          expect(described_class::CELL_WIDTH).to eq(3)
        end

        it "defines CELL_HEIGHT" do
          expect(described_class::CELL_HEIGHT).to eq(1)
        end
      end

      describe "#size" do
        subject { ui.size }
        it { is_expected.to eq(ui.width * ui.height) }
        it { is_expected.to eq(80) } # 10 * 8
      end

      describe "cursor movement methods" do
        before do
          allow(ui).to receive(:print)
          allow(ui).to receive(:printf)
        end

        describe "#move_cursor_to" do
          it "prints ANSI escape sequence" do
            expect(ui).to receive(:print).with("\033[6;11H")
            ui.send(:move_cursor_to, 10, 5)
          end

          it "adjusts coordinates by adding 1" do
            expect(ui).to receive(:print).with("\033[1;1H")
            ui.send(:move_cursor_to, 0, 0)
          end
        end

        describe "#move_cursor_left" do
          it "prints correct ANSI sequence" do
            expect(ui).to receive(:printf).with("\033[5D")
            ui.send(:move_cursor_left, 5)
          end
        end

        describe "#move_cursor_right" do
          it "prints correct ANSI sequence" do
            expect(ui).to receive(:printf).with("\033[3C")
            ui.send(:move_cursor_right, 3)
          end
        end

        describe "#move_cursor_up" do
          it "prints correct ANSI sequence" do
            expect(ui).to receive(:printf).with("\033[2A")
            ui.send(:move_cursor_up, 2)
          end
        end

        describe "#move_cursor_down" do
          it "prints correct ANSI sequence" do
            expect(ui).to receive(:printf).with("\033[4B")
            ui.send(:move_cursor_down, 4)
          end
        end
      end

      describe "#clear!" do
        before { allow(ui).to receive(:system) }

        it "calls system clear command" do
          expect(ui).to receive(:system).with("clear")
          ui.send(:clear!)
        end
      end

      describe "#move_to_board_at" do
        before { allow(ui).to receive(:move_cursor_to) }

        it "calculates correct board position" do
          # For position (2, 3) on board:
          # x = left + (x * CELL_WIDTH) - 1 = 5 + (2 * 3) - 1 = 10
          # y = top + 1 + (y * CELL_HEIGHT) = 4 + 1 + (3 * 1) = 8
          expect(ui).to receive(:move_cursor_to).with(10, 8)
          ui.send(:move_to_board_at, 2, 3)
        end
      end

      describe "rendering methods" do
        before do
          allow(ui).to receive(:print)
          allow(ui).to receive(:puts)
          allow(ui).to receive(:move_cursor_to)
          allow(ui).to receive(:system)
        end

        describe "#render" do
          it "renders board rows" do
            expect(ui).to receive(:move_cursor_to).exactly(ui.height).times
            expect(ui).to receive(:puts).exactly(ui.height).times
            ui.send(:render, board)
          end
        end

        describe "#horizontal_border_top" do
          it "prints top border characters" do
            expect(ui).to receive(:print).with("┌")
            expect(ui).to receive(:print).with(
              "─" * ((described_class::CELL_WIDTH * ui.width) + 2)
            )
            expect(ui).to receive(:print).with("┐")
            ui.send(:horizontal_border_top)
          end
        end

        describe "#horizontal_border_bottom" do
          it "prints bottom border characters" do
            expect(ui).to receive(:print).with("└")
            expect(ui).to receive(:print).with(
              "─" * ((described_class::CELL_WIDTH * ui.width) + 2)
            )
            expect(ui).to receive(:print).with("┘")
            ui.send(:horizontal_border_bottom)
          end
        end

        describe "#vertical_border" do
          context "for left side" do
            it "prints left border" do
              expect(ui).to receive(:print).with("│ ")
              ui.send(:vertical_border, 0, side: :left)
            end
          end

          context "for right side" do
            it "prints right border" do
              expect(ui).to receive(:print).with("  │")
              ui.send(:vertical_border, 0, side: :right)
            end
          end
        end
      end

      describe "#check!" do
        before { allow(ui).to receive(:print) }

        it "prints check mark" do
          expect(ui).to receive(:print).with(" ✔︎ ".white.on.green)
          ui.send(:check!)
        end
      end

      describe "#highlight_board_at" do
        before do
          allow(ui).to receive(:move_to_board_at)
          allow(ui).to receive(:print)
          allow(ui).to receive(:sleep)
        end

        it "highlights position with color sequence" do
          expect(ui).to receive(:move_to_board_at).exactly(3).times.with(1, 2)
          expect(ui).to receive(:print).with(OCCUPIED.white.on.green)
          expect(ui).to receive(:print).with(OCCUPIED.white.on.yellow)
          expect(ui).to receive(:print).with(OCCUPIED.green)
          expect(ui).to receive(:sleep).twice.with(0.3)

          ui.send(:highlight_board_at, 0, 2)
        end
      end

      describe "input validation methods" do
        let(:valid_coordinates) { "5,3" }
        let(:invalid_coordinates) { "-1,5" }

        before do
          allow(ui).to receive(:move_cursor_to)
          allow(ui).to receive(:puts)
          allow(ui).to receive(:print)
          allow(ui).to receive(:move_cursor_left)
          allow(ui).to receive(:move_cursor_up)
          allow(ui).to receive(:move_cursor_right)
          allow(ui).to receive(:check!)
          allow(ui).to receive(:highlight_board_at)
          allow($stdin).to receive(:sync=)
        end

        describe "coordinate validation" do
          context "with valid coordinates" do
            before do
              allow($stdin).to receive(:gets).and_return(
                "#{valid_coordinates}\n"
              )
            end

            it "creates valid point" do
              point = ui.send(:get_next_point)
              expect(point).to be_a(Point)
              expect(point.x).to eq(5)
              expect(point.y).to eq(3)
            end
          end

          context "with quit command" do
            before { allow($stdin).to receive(:gets).and_return("q\n") }

            it "exits the application" do
              expect { ui.send(:get_next_point) }.to raise_error(SystemExit)
            end
          end

          context "with invalid coordinates" do
            before do
              call_count = 0
              allow($stdin).to receive(:gets) do
                call_count += 1
                if call_count == 1
                  "invalid\n"
                else
                  "5,3\n"
                end
              end
              allow(ui).to receive(:show_error)
            end

            it "shows error and retries" do
              expect(ui).to receive(:show_error).with(
                "Coordinates must be integers!"
              )
              point = ui.send(:get_next_point)
              expect(point.x).to eq(5)
              expect(point.y).to eq(3)
            end
          end
        end
      end

      describe "error handling" do
        before do
          allow(ui).to receive(:move_cursor_left)
          allow(ui).to receive(:move_cursor_to)
          allow(ui).to receive(:puts)
          allow(STDIN).to receive(:getch).and_return("x")
        end

        describe "#show_error" do
          it "displays error message and waits for input" do
            expect(ui).to receive(:puts).with(/ERROR:/)
            expect(ui).to receive(:puts).with(/test error/)
            expect(ui).to receive(:puts).with(/Press any key/)
            expect(STDIN).to receive(:getch)

            ui.send(:show_error, "test error")
          end
        end
      end

      describe "line creation" do
        before do
          allow(ui).to receive(:get_next_point).and_return(
            Point.new(1, 1),
            Point.new(3, 3)
          )
          allow(ui).to receive(:move_cursor_to)
          allow(ui).to receive(:print)
        end

        describe "#get_next_line" do
          it "creates line from two points" do
            line = ui.send(:get_next_line)
            expect(line).to be_a(Line)
            expect(line.p1).to eq(Point.new(1, 1))
            expect(line.p2).to eq(Point.new(3, 3))
          end

          it "prints confirmation message" do
            expect(ui).to receive(:print).with(
              /Adding the line with coordinates/
            )
            ui.send(:get_next_line)
          end
        end
      end

      describe "edge cases and error conditions" do
        context "with minimal board" do
          let(:board) { Board.new(width: 1, height: 1) }

          its(:width) { is_expected.to eq(1) }
          its(:height) { is_expected.to eq(1) }
          its(:size) { is_expected.to eq(1) }
        end

        context "with large board" do
          let(:board) { Board.new(width: 100, height: 50) }

          its(:width) { is_expected.to eq(100) }
          its(:height) { is_expected.to eq(50) }
          its(:size) { is_expected.to eq(5000) }
        end
      end
    end
  end
end
