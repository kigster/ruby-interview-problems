# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      module App
        module Commands
          RSpec.describe Version type: :aruba do
            include_context 'aruba setup'
            let(:args) { %w(version) }

            context 'printed to standard output' do
              subject { stderr }

              it { should include Identity::VERSION }
            end
          end
        end
      end
    end
  end
end
