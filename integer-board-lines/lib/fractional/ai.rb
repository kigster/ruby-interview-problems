# frozen_string_literal: true

require "colored2"

require_relative "ai/version"
require_relative "ai/calc"
require_relative "ai/errors"
require_relative "ai/point"
require_relative "ai/line"
require_relative "ai/board"
require_relative "ai/ui"
require_relative "ai/cli_parser"
require_relative "ai/launcher"
require_relative "ai/runner"

# Main namespace for the Fractional library
module Fractional
  # ASCII Art Line Drawing Library
  #
  # This module provides functionality for creating terminal-based
  # ASCII art drawing applications. Users can draw lines on a canvas
  # in both interactive and non-interactive modes.
  #
  # @example Basic usage
  #   board = Fractional::Ai::Board.new(width: 20, height: 10)
  #   line = Fractional::Ai::Line.new(
  #     Fractional::Ai::Point.new(0, 0),
  #     Fractional::Ai::Point.new(5, 5)
  #   )
  #   board.add_line(line)
  #
  # @author Fractional AI
  # @since 0.1.0
  module Ai
    # Character representation for empty board cells
    EMPTY = " • ".bold.black

    # Character representation for occupied board cells
    OCCUPIED = " ◉ "

    class << self
      attr_accessor :test_mode, :configuration
    end

    self.test_mode = false
  end
end
