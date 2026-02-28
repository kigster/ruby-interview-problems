# frozen_string_literal: true

require 'rspec'
require 'rspec/its'
require 'json'

require 'bundler/setup'
require 'pharmacy'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

module Pharmacy
  FIXTURE_DIR               = File.expand_path('fixtures', __dir__)
  MEDICATION_HASHES         = JSON.parse(File.read("#{FIXTURE_DIR}/medications.json"))
  MEDICATIONS               = MEDICATION_HASHES.map do |h|
    Medication.new(id: h['id'],
                   name: h['name'],
                   price: h['price'])
  end
  INVENTORY_HASHES          = JSON.parse(File.read("#{FIXTURE_DIR}/inventory.json"))
  INVENTORY                 = INVENTORY_HASHES.map do |h|
    Inventory.new(medication_id: h['medication_id'],
                  quantity: h['quantity'])
  end
  UPCOMING_INVENTORY_HASHES = JSON.parse(File.read("#{FIXTURE_DIR}/upcoming_inventory.json"))
  UPCOMING_INVENTORY        = UPCOMING_INVENTORY_HASHES.map do |h|
    UpcomingInventory.new(medication_id: h['medication_id'],
                          quantity: h['quantity'],
                          date: h['date'])
  end

  PRESCRIPTIONS = -> do
    [{
      medication: Medication.new(id: 100, name: 'Aspirin', price: 25.0),
      last_dispense_date: 7,
      next_billable_date: 15,
      days_supply: 21,
    }, {
      medication: Medication.new(id: 101, name: 'Benadryl', price: 20.0),
      last_dispense_date: 0,
      next_billable_date: 10,
      days_supply: 14,
    }]
  end
  #
  # HARD_PRESCRIPTIONS = ->() do
  #   [{
  #        medication:         Medication.new(id: 100, name: 'Aspirin', price: 40.0),
  #        last_dispense_date: 0,
  #        next_billable_date: 45,
  #        days_supply:        60,
  #    }, {
  #        medication:         Medication.new(id: 101, name: 'Benadryl', price: 25.0),
  #        last_dispense_date: 40,
  #        next_billable_date: 62,
  #        days_supply:        30,
  #    }, {
  #        medication:         Medication.new(id: 102, name: 'Crestor', price: 20.0),
  #        last_dispense_date: 48,
  #        next_billable_date: 70,
  #        days_supply:        30,
  #    }]
  # end
end
