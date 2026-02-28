#!/usr/bin/env ruby
# frozen_string_literal: true

# STATUS: UNFINISHED

# The aim of the kata is to decomposeose n! (factorial n) into its prime factors.
#
#   Examples:
#
#   n = 12; decompose(12) -> "2^10 * 3^5 * 5^2 * 7 * 11"
#
# since 12! is divisible by 2 ten times, by 3 five times, by 5 two times and by 7 and 11 only once.
#
#   n = 22; decompose(22) -> "2^19 * 3^9 * 5^4 * 7^3 * 11^2 * 13 * 17 * 19"
#
# n = 25; decompose(25) -> 2^22 * 3^10 * 5^6 * 7^3 * 11^2 * 13 * 17 * 19 * 23
#
# Prime numbers should be in increasing order. When the exponent `of a prime is 1 don't put the exponent.
#
# Notes
#
# the function is decompose(n) and should return the decomposition of n! into its prime factors in
# increasing order of the primes, as a string.
#
# factorial can be a very big number (4000! has 12674 digits, n can go from 300 to 4000).
#
# In Fortran - as in any other language - the returned string is not permitted to contain any
# redundant trailing whitespace: you can use dynamically allocated character strings.

require 'bigdecimal'

class Integer
  def factorial
    raise ArgumentError, "Can't not compute factorial for n > 4000" if self > 4000

    BigDecimal((1..self).inject(:*) || 1).to_i
  end
end

require 'rspec'
require 'rspec/its'

RSpec.describe Integer do
  FACTORIALS = {
    3 => 6,
    4 => 24,
    5 => 120,
    10 => 3_628_800,
    13 => 6_227_020_800
  }.freeze

  FACTORIALS.each_pair do |number, factorial|
    describe "#{number}! should eq #{factorial}" do
      subject { number }
      its(:factorial) { should eq factorial }
    end
  end
end

module PrimeDecomposition
  # @param [Integer] number to decompose
  # @return [String] result of the form "prime1^factor1 * prime2^factor2 ..."
  def self.decompose(input)
    fact    = input.factorial
    factors = []

    ::Prime.each(4000) do |prime|
      factor = prime_factor(fact, prime)
      next if factor.nil?

      factors << sprintf("%d^%d", prime, factor)
    end

    factors.compact.join(' * ')
  end

  def self.prime_factor(divisible, prime)
    exponent = 0

    until (prime**exponent) > divisible
      exponent += 1
    end

    exponent -= 1
    result = divisible.to_f / (prime**exponent)
    puts result
    return unless result - result.to_i == 0

    result
  end
end

def fixtures
  @fixtures ||= [[17, '2^15 * 3^6 * 5^3 * 7^2 * 11 * 13 * 17'],
                 [5, '2^3 * 3 * 5'],
                 [22, '2^19 * 3^9 * 5^4 * 7^3 * 11^2 * 13 * 17 * 19']]
end

RSpec.describe 'PrimeDecomposition.decompose' do
  describe '#prime_factor', focus: true do
    let(:divisible) { (2**7) * (3**4) }
    subject { PrimeDecomposition.prime_factor(divisible, prime) }

    describe 'correctly computes power 7 for 2' do
      let(:prime) { 2 }
      it { is_expected.to eq 7 }
    end

    describe 'correctly computes power 4 for 3' do
      let(:prime) { 3 }
      it { is_expected.to eq 4 }
    end
  end

  fixtures.each do |number, result|
    it "should decompose #{number} into #{result}" do
      actual = PrimeDecomposition.decompose(number)
      expect(actual).to eq(result)
    end
  end
end

require 'rspec/autorun'
