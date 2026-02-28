# frozen_string_literal: true

RSpec.describe Pharmacy do
  it "has a version number" do
    expect(Pharmacy::VERSION).not_to be nil
  end
end
