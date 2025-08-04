# frozen_string_literal: true

require 'spec_helper'

module Fractional
  module Ai
    RSpec.describe Errors do
      describe 'Error' do
        subject { Errors::Error }

        it { is_expected.to be < StandardError }

        it 'can be raised with a message' do
          expect { raise subject, "test message" }.to raise_error(subject, "test message")
        end

        it 'can be raised without a message' do
          expect { raise subject }.to raise_error(subject)
        end
      end

      describe 'InvalidCoordinates' do
        subject { Errors::InvalidCoordinates }

        it { is_expected.to be < Errors::Error }

        it 'can be raised with a message' do
          message = "Coordinates must be positive integers"
          expect { raise subject, message }.to raise_error(subject, message)
        end

        it 'inherits from base Error class' do
          expect(subject.ancestors).to include(Errors::Error)
        end
      end

      describe 'MissingArguments' do
        subject { Errors::MissingArguments }

        it { is_expected.to be < Errors::Error }

        it 'can be raised with a message' do
          message = "Line points are required"
          expect { raise subject, message }.to raise_error(subject, message)
        end

        it 'inherits from base Error class' do
          expect(subject.ancestors).to include(Errors::Error)
        end
      end

      describe 'error hierarchy' do
        it 'maintains proper inheritance chain' do
          expect(Errors::InvalidCoordinates.ancestors).to include(
            Errors::Error, StandardError, Exception
          )
          expect(Errors::MissingArguments.ancestors).to include(
            Errors::Error, StandardError, Exception
          )
        end

        it 'allows catching all custom errors with base Error class' do
          expect do
            raise Errors::InvalidCoordinates, "invalid coords"
          rescue Errors::Error => e
            expect(e).to be_a(Errors::InvalidCoordinates)
            raise "caught successfully"
          end.to raise_error("caught successfully")
        end
      end
    end
  end
end
