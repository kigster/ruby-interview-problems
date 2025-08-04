#!/usr/bin/env ruby
# frozen_string_literal: true

require "bundler/setup"
require "amazing_print"
require "fractional/ai"

module Fractional
  module Ai
    BoardParams = Struct.new(:board, :left_top_coordinate, :lines)

    class Runner
      extend Forwardable
      def_delegators :@launcher, :stdout, :stderr, :kernel, :config

      attr_reader :argv, :launcher
      attr_accessor :board, :board_params, :left_top_coordinate, :lines

      def initialize(launcher:)
        @argv = launcher.argv.dup
        @launcher = launcher
        @board_params = BoardParams.new
        @board = nil
        @left_top_coordinate = nil
        @lines = []
      end

      def run
        configure

        Fractional::Ai::Ui.new(
          board: board_params.board,
          left_top_coordinate: board_params.left_top_coordinate,
          lines: board_params.lines
        ).run
      end

      private

      def configure
        if config.config_file && File.exist?(launcher.config.config_file)
          board, coordinates, lines = load_config_from_file(launcher.config.config_file)
          board_params.board = board
          board_params.left_top_coordinate = coordinates
          board_params.lines = lines
        elsif config.interactive
          board_params.left_top_coordinate = Fractional::Ai::Point.new(5, 5)
          board_params.lines = []
          board_params.board = Fractional::Ai::Board.new(width: 20, height: 20)
        else
          raise Errors::ConfigurationError, "No configuration file provided"
        end
      end

      def load_config_from_file(config_file)
        require "json"
        config = JSON.parse(File.read(config_file))

        board_config = config["board"] || {}
        lines_config = config["lines"] || []
        board =
          Fractional::Ai::Board.new(
            width: board_config["width"].to_i || 20,
            height: board_config["height"].to_i || 20
          )

        left_top_coordinate =
          Fractional::Ai::Point.new(
            board_config["left"].to_i,
            board_config["top"].to_i
          )
        lines = []
        lines_config.each do |line_hash|
          p1 =
            Point.new(
              line_hash["line"][0]["x"].to_i,
              line_hash["line"][0]["y"].to_i
            )
          p2 =
            Point.new(
              line_hash["line"][1]["x"].to_i,
              line_hash["line"][1]["y"].to_i
            )
          color = line_hash["color"] || "white"
          lines << Fractional::Ai::Line.new(p1, p2, color: color)
        end

        [board, left_top_coordinate, lines]
      end
    end
  end
end
