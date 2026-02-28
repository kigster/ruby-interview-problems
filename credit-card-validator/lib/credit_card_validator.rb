# frozen_string_literal: true

require "credit_card_validator/version"

module CreditCardValidator
  class Error < StandardError; end
  # Your code goes here...
end

require_relative 'credit_card_validator/card_issuer'
