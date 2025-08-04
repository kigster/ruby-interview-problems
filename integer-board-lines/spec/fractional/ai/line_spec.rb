# frozen_string_literal: true

require "spec_helper"

module Fractional
  module Ai
    RSpec.describe Line do
      let(:p1) { Point.new(0, 0) }
      let(:p2) { Point.new(5, 5) }
      let(:color) { :red }
      let(:line) { described_class.new(p1, p2, color:) }

      subject { line }

      describe "initialization" do
        its(:p1) { is_expected.to eq(p1) }
        its(:p2) { is_expected.to eq(p2) }

        context "with explicit color" do
          let(:color) { :blue }
          it "sets the color" do
            expect(line.instance_variable_get(:@color)).to eq(:blue)
          end
        end

        context "without color" do
          let(:line) { described_class.new(p1, p2) }
          it "defaults to white" do
            expect(line.instance_variable_get(:@color)).to eq(:white)
          end
        end
      end

      describe "coordinate boundaries" do
        let(:subject_with_bounds) { line }
        it_behaves_like "an object with coordinate boundaries"

        context "with diagonal line from (0,0) to (5,5)" do
          its(:min_x) { is_expected.to eq(0) }
          its(:max_x) { is_expected.to eq(5) }
          its(:min_y) { is_expected.to eq(0) }
          its(:max_y) { is_expected.to eq(5) }
        end

        context "with line from (10,5) to (2,8)" do
          let(:p1) { Point.new(10, 5) }
          let(:p2) { Point.new(2, 8) }

          its(:min_x) { is_expected.to eq(2) }
          its(:max_x) { is_expected.to eq(10) }
          its(:min_y) { is_expected.to eq(5) }
          its(:max_y) { is_expected.to eq(8) }
        end

        context "with vertical line" do
          let(:p1) { Point.new(3, 1) }
          let(:p2) { Point.new(3, 7) }

          its(:min_x) { is_expected.to eq(3) }
          its(:max_x) { is_expected.to eq(3) }
          its(:min_y) { is_expected.to eq(1) }
          its(:max_y) { is_expected.to eq(7) }
        end

        context "with horizontal line" do
          let(:p1) { Point.new(1, 4) }
          let(:p2) { Point.new(6, 4) }

          its(:min_x) { is_expected.to eq(1) }
          its(:max_x) { is_expected.to eq(6) }
          its(:min_y) { is_expected.to eq(4) }
          its(:max_y) { is_expected.to eq(4) }
        end
      end

      describe "#bounding_box" do
        subject { line.bounding_box }

        it { is_expected.to be_an(Array) }
        its(:length) { is_expected.to eq(2) }

        context "with line from (0,0) to (5,5)" do
          it "returns correct bounding box points" do
            expect(subject).to eq([Point.new(0, 0), Point.new(5, 5)])
          end
        end

        context "with line from (10,5) to (2,8)" do
          let(:p1) { Point.new(10, 5) }
          let(:p2) { Point.new(2, 8) }

          it "returns correct bounding box points" do
            expect(subject).to eq([Point.new(2, 5), Point.new(10, 8)])
          end
        end

        it "returns Point objects" do
          expect(subject.first).to be_a(Point)
          expect(subject.last).to be_a(Point)
        end
      end

      describe "#valid?" do
        subject { line.valid? }

        context "with valid points" do
          let(:valid_subject) do
            described_class.new(Point.new(0, 0), Point.new(5, 5))
          end
          let(:invalid_subject) do
            described_class.new(Point.new(-1, 0), Point.new(5, 5))
          end

          it_behaves_like "a validatable object"
        end

        context "with valid points" do
          it { is_expected.to be true }
        end

        context "with first point invalid" do
          let(:p1) { Point.new(-1, 0) }
          it { is_expected.to be false }
        end

        context "with second point invalid" do
          let(:p2) { Point.new(5, -1) }
          it { is_expected.to be false }
        end

        context "with both points invalid" do
          let(:p1) { Point.new(-1, -1) }
          let(:p2) { Point.new(-5, -5) }
          it { is_expected.to be false }
        end
      end

      describe "#initialize" do
        context "with non-Point objects" do
          let(:p1) { "not a point" }
          let(:p2) { Point.new(5, 5) }
          it "raises an error" do
            expect { line }.to raise_error(ArgumentError)
          end
        end

        context "with nil points" do
          let(:p1) { nil }
          let(:p2) { nil }
          it "raises an error" do
            expect { line }.to raise_error(ArgumentError)
          end
        end
      end

      describe "#length" do
        subject { line.length }

        context "with diagonal line (3-4-5 triangle)" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(3, 4) }
          it { is_expected.to eq(5.0) }
        end

        context "with horizontal line" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(5, 0) }
          it { is_expected.to eq(5.0) }
        end

        context "with vertical line" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(0, 3) }
          it { is_expected.to eq(3.0) }
        end

        context "with single point (zero length)" do
          let(:p1) { Point.new(5, 5) }
          let(:p2) { Point.new(5, 5) }
          it { is_expected.to eq(0.0) }
        end

        context "with diagonal line from (1,1) to (4,5)" do
          let(:p1) { Point.new(1, 1) }
          let(:p2) { Point.new(4, 5) }
          it { is_expected.to eq(5.0) } # sqrt((4-1)^2 + (5-1)^2) = sqrt(9+16) = 5
        end
      end

      describe "#coefficient" do
        subject { line.coefficient }

        context "with 45-degree diagonal line" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(5, 5) }
          it { is_expected.to eq(1.0) }
        end

        context "with horizontal line" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(5, 0) }
          it { is_expected.to eq(0.0) }
        end

        context "with vertical line" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(0, 5) }
          it { is_expected.to eq(Float::INFINITY) }
        end

        context "with negative slope" do
          let(:p1) { Point.new(0, 5) }
          let(:p2) { Point.new(5, 0) }
          it { is_expected.to eq(-1.0) }
        end

        context "with slope of 2" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(1, 2) }
          it { is_expected.to eq(2.0) }
        end

        context "with fractional slope" do
          let(:p1) { Point.new(0, 0) }
          let(:p2) { Point.new(2, 1) }
          it { is_expected.to eq(0.5) }
        end

        it "memoizes the result" do
          # Access coefficient twice to test memoization
          first_call = line.coefficient
          second_call = line.coefficient
          expect(first_call).to eq(second_call)
          expect(line.instance_variable_get(:@coefficient)).to eq(first_call)
        end
      end

      describe "edge cases" do
        context "with same point (zero-length line)" do
          let(:p1) { Point.new(5, 5) }
          let(:p2) { Point.new(5, 5) }

          its(:valid?) { is_expected.to be true }
          its(:length) { is_expected.to eq(0.0) }
          its(:coefficient) { is_expected.to eq(Float::INFINITY) }
          its(:min_x) { is_expected.to eq(5) }
          its(:max_x) { is_expected.to eq(5) }
          its(:min_y) { is_expected.to eq(5) }
          its(:max_y) { is_expected.to eq(5) }
        end

        context "with large coordinates" do
          let(:p1) { Point.new(1000, 1000) }
          let(:p2) { Point.new(2000, 2000) }

          its(:valid?) { is_expected.to be true }
          its(:coefficient) { is_expected.to eq(1.0) }
        end
      end

      describe "inclusion of Calc module" do
        it "includes Calc module" do
          expect(described_class.included_modules).to include(Calc)
        end

        it "can use min and max methods" do
          expect(line.min(5, 10)).to eq(5)
          expect(line.max(5, 10)).to eq(10)
        end
      end
    end
  end
end
