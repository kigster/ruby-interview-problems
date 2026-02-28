# frozen_string_literal: true

require 'json'

module Pharmacy
  class MedicationsController
    class << self
      def medication(medication_id)
        Medication.find_by_id(medication_id).to_hash
      end

      def medications
        Medication.medications.values.map(&:to_hash)
      end
    end
  end
end
