# frozen_string_literal: true

require 'pharmacy/version'

module Pharmacy
  class Error < StandardError; end
end

require 'pharmacy/models/medication'
require 'pharmacy/models/upcoming_inventory'
require 'pharmacy/models/order'

require 'pharmacy/services/alignment_service'

require 'pharmacy/controllers/medications_controller'
require 'pharmacy/controllers/orders_controller'
