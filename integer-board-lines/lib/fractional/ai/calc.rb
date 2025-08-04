# frozen_string_literal: true

module Fractional
  module Ai
    # Calculation utilities module providing basic mathematical operations
    #
    # This module provides utility methods for mathematical calculations
    # used throughout the application, particularly for coordinate operations.
    #
    # @author Fractional AI
    # @since 0.1.0
    module Calc
      # Returns the minimum value between two numbers
      #
      # @param a [Numeric] first number
      # @param b [Numeric] second number
      # @return [Numeric] the smaller of the two values
      # @example
      #   min(5, 10)  # => 5
      #   min(10, 5)  # => 5
      def min(a, b)
        a < b ? a : b
      end

      # Returns the maximum value between two numbers
      #
      # @param a [Numeric] first number
      # @param b [Numeric] second number
      # @return [Numeric] the larger of the two values
      # @example
      #   max(5, 10)  # => 10
      #   max(10, 5)  # => 10
      def max(a, b)
        a > b ? a : b
      end
    end
  end
end
