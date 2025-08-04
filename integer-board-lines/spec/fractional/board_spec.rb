# frozen_string_literal: true

require "spec_helper"

module Fractional
  module Ai
    RSpec.describe Board do
      let(:width) { 20 }
      let(:height) { 10 }
      let(:board) { described_class.new(width: width, height: height) }

      subject { board }

      describe "initialization" do
        its(:width) { is_expected.to eq(width) }
        its(:height) { is_expected.to eq(height) }
        its(:rows) { is_expected.to be_a(Array) }
        its(:lines) { is_expected.to be_a(Array) }
        its(:lines) { is_expected.to be_empty }

        context "with default dimensions" do
          let(:board) { described_class.new }
          its(:width) { is_expected.to eq(20) }
          its(:height) { is_expected.to eq(20) }
        end

        context "with custom dimensions" do
          let(:width) { 15 }
          let(:height) { 8 }
          its(:width) { is_expected.to eq(15) }
          its(:height) { is_expected.to eq(8) }
        end
      end

      describe "board structure" do
        it "initializes rows as 2D array" do
          expect(board.rows).to be_a(Array)
          expect(board.rows.length).to eq(height)
          board.rows.each do |row|
            expect(row).to be_a(Array)
            expect(row.length).to eq(width)
          end
        end

        it "fills cells with EMPTY constant" do
          board.rows.each do |row|
            row.each { |cell| expect(cell).to eq(EMPTY) }
          end
        end
      end

      describe "dimensions behavior" do
        let(:dimensional_subject) { board }
        it_behaves_like "an object with dimensions"
      end

      describe "#size" do
        subject { board.size }
        it { is_expected.to eq(width * height) }

        context "with different dimensions" do
          let(:width) { 5 }
          let(:height) { 4 }
          it { is_expected.to eq(20) }
        end

        context "with square board" do
          let(:width) { 10 }
          let(:height) { 10 }
          it { is_expected.to eq(100) }
        end
      end

      describe "#add_line" do
        let(:p1) { Point.new(1, 1) }
        let(:p2) { Point.new(3, 3) }
        let(:line) { Line.new(p1, p2) }

        context "with valid line" do
          it "adds line to lines array" do
            expect { board.add_line(line) }.to change {
              board.lines.count
            }.from(0).to(1)
          end

          it "stores the correct line" do
            board.add_line(line)
            expect(board.lines.first).to eq(line)
          end

          it "modifies the board rows" do
            original_state = board.rows.map(&:dup)
            board.add_line(line)
            expect(board.rows).not_to eq(original_state)
          end
        end

        context "with nil line" do
          let(:line) { nil }

          it "raises MissingArguments error" do
            expect { board.add_line(line) }.to raise_error(
              Errors::MissingArguments,
              "Either line or p1 and p2 must be provided"
            )
          end

          it "does not modify lines array" do
            expect do
              begin
                board.add_line(line)
              rescue StandardError
                nil
              end
            end.not_to(change { board.lines.count })
          end
        end

        context "with invalid line" do
          let(:line) { Line.new(Point.new(-1, 0), Point.new(5, 5)) }

          it "raises MissingArguments error" do
            expect { board.add_line(line) }.to raise_error(
              Errors::MissingArguments,
              "Line is not valid!"
            )
          end

          it "does not modify lines array" do
            expect do
              begin
                board.add_line(line)
              rescue StandardError
                nil
              end
            end.not_to(change { board.lines.count })
          end
        end
      end

      describe "line rendering" do
        context "with horizontal line" do
          let(:p1) { Point.new(1, 2) }
          let(:p2) { Point.new(4, 2) }
          let(:line) { Line.new(p1, p2) }

          before { board.add_line(line) }

          it "marks endpoints in cyan" do
            expect(board.rows[2][1]).to eq(OCCUPIED)
            expect(board.rows[2][4]).to eq(OCCUPIED)
          end

          it "fills horizontal line in yellow" do
            (1..4).each { |x| expect(board.rows[2][x]).to include(OCCUPIED) }
          end
        end

        context "with vertical line" do
          let(:p1) { Point.new(3, 1) }
          let(:p2) { Point.new(3, 4) }
          let(:line) { Line.new(p1, p2) }

          before { board.add_line(line) }

          it "marks endpoints in cyan" do
            expect(board.rows[1][3]).to eq(OCCUPIED)
            expect(board.rows[4][3]).to eq(OCCUPIED)
          end

          it "fills vertical line in green" do
            (1..4).each { |y| expect(board.rows[y][3]).to include(OCCUPIED) }
          end
        end

        context "with diagonal line" do
          let(:p1) { Point.new(1, 1) }
          let(:p2) { Point.new(3, 3) }
          let(:line) { Line.new(p1, p2) }

          before { board.add_line(line) }

          it "marks endpoints in cyan" do
            expect(board.rows[1][1]).to eq(OCCUPIED)
            expect(board.rows[3][3]).to eq(OCCUPIED)
          end

          it "renders diagonal points" do
            # Check that some points along the diagonal are marked
            expect(board.rows[2][2]).to include(OCCUPIED)
          end
        end

        context "with single point line" do
          let(:p1) { Point.new(5, 5) }
          let(:p2) { Point.new(5, 5) }
          let(:line) { Line.new(p1, p2) }

          before { board.add_line(line) }

          it "marks the single point" do
            expect(board.rows[5][5]).to eq(OCCUPIED)
          end
        end
      end

      describe "multiple lines" do
        let(:line1) { Line.new(Point.new(1, 1), Point.new(3, 1)) }
        let(:line2) { Line.new(Point.new(2, 0), Point.new(2, 4)) }

        before do
          board.add_line(line1)
          board.add_line(line2)
        end

        it "stores both lines" do
          expect(board.lines.count).to eq(2)
          expect(board.lines).to include(line1, line2)
        end

        it "renders both lines on the board" do
          # Check horizontal line
          expect(board.rows[1][1]).to include(OCCUPIED)
          expect(board.rows[1][2]).to include(OCCUPIED)
          expect(board.rows[1][3]).to include(OCCUPIED)

          # Check vertical line
          expect(board.rows[0][2]).to include(OCCUPIED)
          expect(board.rows[1][2]).to include(OCCUPIED)
          expect(board.rows[2][2]).to include(OCCUPIED)
          expect(board.rows[3][2]).to include(OCCUPIED)
          expect(board.rows[4][2]).to include(OCCUPIED)
        end
      end

      describe "inclusion of Calc module" do
        it "includes Calc module" do
          expect(described_class.included_modules).to include(Calc)
        end

        it "can use calculation methods" do
          expect(board.min(5, 10)).to eq(5)
          expect(board.max(5, 10)).to eq(10)
        end
      end

      describe "edge cases" do
        context "with large board" do
          let(:width) { 100 }
          let(:height) { 50 }

          its(:size) { is_expected.to eq(5000) }
          its(:width) { is_expected.to eq(100) }
          its(:height) { is_expected.to eq(50) }
        end

        context "with minimal board" do
          let(:width) { 1 }
          let(:height) { 1 }

          its(:size) { is_expected.to eq(1) }
          it "has one row" do
            expect(subject.rows.length).to eq(1)
          end

          it "has single cell initialized to EMPTY" do
            expect(board.rows[0][0]).to eq(EMPTY)
          end
        end
      end
    end
  end
end
