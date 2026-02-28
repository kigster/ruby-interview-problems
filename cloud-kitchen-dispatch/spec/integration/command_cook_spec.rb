# frozen_string_literal: true

require 'spec_helper'
require 'cloud/kitchens/dispatch/identity'

module Cloud
  module Kitchens
    module Dispatch
      module App
        module Commands
          RSpec.describe Cook, type: :aruba, reset_config: true do
            include_context 'aruba setup'

            describe 'output to stdout' do
              let(:args) { ['cook', Fixtures.file] }

              context 'printed to standard output' do
                subject { stdout }

                it { should match /Starting dispatcher/ }
              end
            end

            describe 'output to a file' do
              let(:args) { ['cook', Fixtures.file, '-L', log_path] }

              subject { log_file }

              context 'printed to standard output' do
                its(:filename) { is_expected.to be_an_existing_file }

                its(:content) { is_expected.to_not be_empty }
              end
            end
          end
        end
      end
    end
  end
end
