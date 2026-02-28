# frozen_string_literal: true

require 'spec_helper'

require 'dry/configurable/test_interface'

require "cloud/kitchens/dispatch/app/config"

module Cloud
  module Kitchens
    module Dispatch
      RSpec.describe Dispatcher do
        let(:output) { StringIO.new }

        before(:each) { ::Cloud::Kitchens::Dispatch.stdout = output }

        subject(:dispatcher) { described_class.new }

        before(:each) { App::Config.reset_config }

        after(:each) { App::Config.reset_config }

        its(:kitchen) { is_expected.to be_a_kind_of(Kitchen) }
      end
    end
  end
end
