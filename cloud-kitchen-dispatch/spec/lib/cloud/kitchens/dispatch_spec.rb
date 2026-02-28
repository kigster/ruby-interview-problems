# frozen_string_literal: true

require 'spec_helper'

module Cloud
  module Kitchens
    RSpec.describe Dispatch, reset_config: true do
      context '.config' do
        subject { described_class.app_config }

        its(:'order.rate') { is_expected.to eq 2 }
        its(:'logging.log_level') { is_expected.to eq :debug }
      end
    end
  end
end
