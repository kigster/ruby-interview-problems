# frozen_string_literal: true

module CreditCardValidator
  # This class encapsulates number matching rules about a specific
  # credit card issuer.
  CardValidator = Struct.new(:issuer, :card_length, :prefixes) do
    def matches?(card)
      return false unless Array(card_length).include?(card.size)

      prefixes.any? do |prefix|
        if prefix.to_s.include?('-')
          from, to = prefix.split('-').map(&:to_i)
          (from...to).include?(card[0...(from.to_s.size)].to_i)
        else
          card.to_s.start_with?(prefix.to_s)
        end
      end
    end
  end

  # These rules are ordered, and will be checked in the order
  # they are provided here.
  VALIDATORS = [
    CardValidator.new('American Express', [15], [34, 37]),
    CardValidator.new('Diners Club', [14, 15], [36, 38]),
    CardValidator.new('Visa Electron', [16], [4026, 417_500, 4508, 4844, 4913, 4917]),
    CardValidator.new('Visa', [16], [4]),
    CardValidator.new('Discover Card', [16], [6011, '622126-622925', '644-649', 65])
  ].freeze

  class CardIssuer
    attr_accessor :number, :issuer

    def initialize(number)
      self.number = number

      VALIDATORS.each do |validator|
        if validator.matches?(number)
          self.issuer = validator.issuer
          break
        end
      end

      self.issuer ||= 'Unknown'
    end
  end
end
