# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/app/launcher'

module Cloud
  module Kitchens
    module Dispatch
      module App
        RSpec.describe Config, reset_config: true do
          subject { described_class.config }

          describe 'configure' do
            let(:orders_per_second) { 10 }
            let(:couriers) { 100 }
            let(:shelf_capacity) { 200 }

            before do
              ::Cloud::Kitchens::Dispatch.configure do |config|
                config.order.rate = orders_per_second
                config.total.couriers             = couriers
                config.total.shelf_capacity       = shelf_capacity
              end
            end

            its(:'order.rate') { is_expected.to eq orders_per_second }

            its(:'total.couriers') { is_expected.to eq couriers }

            its(:'total.shelf_capacity') { is_expected.to eq shelf_capacity }
          end
        end
      end
    end
  end
end
