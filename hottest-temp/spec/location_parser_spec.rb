# frozen_string_literal: true

require 'rspec/its'
require_relative '../lib/location_parser'
RSpec.describe LocationParser do
  subject(:parser) { described_class.parser(line) }

  context 'by city' do
    let(:line) { 'San Francisco' }

    it { should_not be_nil }
    it { should be_a_kind_of CityParser }
    its(:location) { should eq line }
    its(:query) { should eq 'q=San%20Francisco' }
  end

  context 'by zip' do
    let(:line) { '94107' }
    it { should_not be_nil }
    it { should be_a_kind_of ZipParser }
    its(:location) { should eq line }
    its(:query) { should eq 'zip=94107' }
  end

  context 'by long lat' do
    let(:lat) { 61.210841 }
    let(:lon) { -149.88873 }
    let(:line) { "#{lat},#{lon}" }

    it { should_not be_nil }

    it { should be_a_kind_of LatLonParser }
    its(:lon) { should be_within(0.001).of lon }
    its(:lat) { should be_within(0.001).of lat }
    its(:query) { should eq 'lat=61.210841&lon=-149.88873' }
  end
end
