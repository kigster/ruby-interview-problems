# frozen_string_literal: true

module Fractional
  module Ai
    # Error classes for the Fractional::Ai application
    #
    # This module contains all custom error classes used throughout
    # the application for handling various error conditions.
    #
    # @author Fractional AI
    # @since 0.1.0
    module Errors
      # Base error class for all Fractional::Ai related errors
      #
      # @example
      #   raise Errors::Error, "Something went wrong"
      class Error < StandardError
      end

      # Raised when invalid coordinates are provided
      #
      # This error is raised when coordinates are out of bounds,
      # not integers, or otherwise invalid.
      #
      # @example
      #   raise Errors::InvalidCoordinates, "Coordinates must be positive integers"
      class InvalidCoordinates < Error
      end

      # Raised when required arguments are missing
      #
      # This error is raised when required parameters are not provided
      # to methods that need them.
      #
      # @example
      #   raise Errors::MissingArguments, "Line points are required"
      class MissingArguments < Error
      end

      # This error is raised when the configuration is invalid.
      #
      # @example
      #   raise Errors::ConfigurationError, "Config file and Interactive mode are mutually exclusive."
      class ConfigurationError < Error
      end
    end
  end
end
