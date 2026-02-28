# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      module App
        module Commands
          RSpec.describe Help, type: :aruba do
            include_context 'aruba setup'

            let(:args) { %w(help) }

            context 'printed to standard output' do
              subject { stderr }

              it { should match /Commands:/ }
            end

            context 'printed to standard error' do
              subject { stderr }

              it { should match /cook \[ORDERS\]/ }
            end
          end
        end
      end
    end
  end
end
