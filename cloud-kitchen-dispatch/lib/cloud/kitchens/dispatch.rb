# frozen_string_literal: true

require 'pastel'
require 'stringio'

require 'cloud/kitchens/dispatch/kitchen_helpers'
require 'cloud/kitchens/dispatch/logging'

module Cloud
  module Kitchens
    module Dispatch
      class << self
        attr_accessor :launcher, :in_test, :stdout, :stderr
      end

      PASTEL = ::Pastel.new.freeze
      COLOR  = ::Pastel::Color.new(enabled: true).freeze

      GEM_ROOT = File.expand_path('../', __dir__).freeze
      BINARY   = "#{GEM_ROOT}/bin/kitchen-ctl"

      extend KitchenHelpers

      include Logging

      self.stderr = ::StringIO.new
      self.stdout = ::StringIO.new
      self.in_test = false
    end
  end
end

require 'cloud/kitchens/dispatch/identity'
require 'cloud/kitchens/dispatch/dispatcher'
