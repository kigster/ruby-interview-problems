# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'awesome_print'
require 'hash_diff'

RSpec.describe HashDiff do
  shared_examples :proper_hash_diff do
    let(:hash_diff) { HashDiff.new(actual, expected) }
    subject(:diff) { hash_diff.compare.diffs }

    before do
      puts '—' * 50
      puts use_case
      puts '.' * 20
      diff.each do |diff_component|
        puts diff_component.inspect
      end
    end

    it 'computes the correct diff' do
      expected_diff.each do |a_diff|
        expect(diff).to include(a_diff)
      end
    end

    its(:size) { should eq expected_diff_size }
  end

  describe 'Shallow Hashes' do
    it_behaves_like :proper_hash_diff do
      let(:use_case) { 'Shallow Hashes' }
      let(:actual) { { apples: 3, oranges: 4 } }
      let(:expected) { { apples: 3, grapes: 5 } }
      let(:expected_diff) {
        [
          ['-', 'grapes', 5],
          ['+', 'oranges', 4]
        ]
      }
      let(:expected_diff_size) { 2 }
    end
  end

  context 'Shallow Hashes, With Element Missing' do
    it_behaves_like :proper_hash_diff do
      let(:use_case) { 'Shallow Hashes, With Element Missing' }
      let(:actual) { { apples: 3, } }
      let(:expected) { { apples: 3, oranges: nil } }
      let(:expected_diff) {
        [
          ['-', 'oranges', nil]
        ]
      }
      let(:expected_diff_size) { 2 }
    end
  end

  context 'Shallow Hashes With a conflicting value' do
    it_behaves_like :proper_hash_diff do
      let(:use_case) { 'Shallow Hashes With a conflicting value' }
      let(:actual) { { apples: 3, oranges: 4 } }
      let(:expected) { { apples: 3, oranges: 5, } }
      let(:expected_diff) {
        [
          ['-', 'oranges', 5],
          ['+', 'oranges', 4]
        ]
      }
      let(:expected_diff_size) { 2 }
    end
  end

  context 'Nested JSON' do
    it_behaves_like :proper_hash_diff do
      let(:use_case) { 'Nested JSON' }
      let(:actual) { { apples: 3, oranges: { navel: 5 } } }
      let(:expected) { { apples: 3, oranges: { valencia: 4 } } }
      let(:expected_diff) {
        [
          ['-', 'oranges.valencia', 4],
          ['+', 'oranges.navel', 5]
        ]
      }
      let(:expected_diff_size) { 2 }
    end
  end

  context 'With Missing Keys' do
    it 'calculates the correct diff' do
      actual = {
        apples: 3,
        oranges: nil
      }

      expected = {
        apples: 3,
        oranges: {
          valencia: 4
        }
      }
      result = diff(actual, expected)
      expect(result).to include(
        ['+', 'oranges', nil],
        ['-', 'oranges.valencia', 4],
      )
    end
  end

  context 'doubly nested JSON' do
    it 'calculates the correct diff' do
      actual = {
        apples: 3,
        oranges: {
          bergamot: 3,
          navel: {
            peaches: 1,
            apples: 3
          }
        }
      }

      expected = {
        apples: 3,
        oranges: {
          bergamot: 3,
          valencia: {
            pears: 2,
            oranges: 4
          }
        }
      }

      result = diff(actual, expected)
      expect(result).to include(
        ['+', 'oranges.navel.peaches', 1],
        ['+', 'oranges.navel.apples', 3],
        ['-', 'oranges.valencia.pears', 2],
        ['-', 'oranges.valencia.oranges', 4]
      )
      expect(result.length).to eq 4
    end
  end

  context 'doubly nested JSON' do
    it 'calculates the correct diff' do
      actual = {
        apples: 3,
        oranges: 5
      }

      expected = {
        apples: 3,
        oranges: {
          bergamot: 3,
          valencia: {
            pears: 2,
            oranges: 4
          }
        }
      }

      result = diff(actual, expected)
      expect(result).to include(
        ['-', 'oranges.valencia.pears', 2],
        ['-', 'oranges.valencia.oranges', 4],
        ['-', 'oranges.bergamot', 3],
        ['+', 'oranges', 5],
      )
      expect(result.length).to eq 4
    end
  end
end
