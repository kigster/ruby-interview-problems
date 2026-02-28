# frozen_string_literal: true

require 'spec_helper'

require 'cloud/kitchens/dispatch/app/config'

module Cloud
  module Kitchens
    module Dispatch
      class TestClass
        include KitchenHelpers
      end

      RSpec.describe Logging do
        it { is_expected.to respond_to(:logger) }

        context 'class methods' do
          subject(:logger) { TestClass.logger }

          it { is_expected.to respond_to(:debug) }
        end

        context 'instance methods' do
          subject(:logger) { TestClass.new.logger }

          it { is_expected.to respond_to(:debug) }
        end
      end
    end
  end
end
