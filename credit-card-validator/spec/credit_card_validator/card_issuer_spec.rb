# frozen_string_literal: true

require 'spec_helper'

module CreditCardValidator
  TEST_CARDS = {
    '341235468923456' => 'American Express',
    '36123546892345' => 'Diners Club',
    '123112354689234' => 'Unknown',
    '4026000344333445' => 'Visa Electron',
    '4175000344313144' => 'Visa Electron',
    '4111111111111111' => 'Visa',
    '6221260093242444' => 'Discover Card',
    '6011445043324444' => 'Discover Card',
    '6479033344322121' => 'Discover Card',
  }.freeze

  RSpec.describe CardIssuer do
    TEST_CARDS.each_pair do |card, issuer|
      describe "card number [#{card}]" do
        subject(:card_issuer) { described_class.new(card) }
        it "should match #{issuer}" do
          expect(card_issuer.issuer).to eq issuer
        end
      end
    end
  end
end
