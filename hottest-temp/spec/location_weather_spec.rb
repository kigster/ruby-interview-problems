# frozen_string_literal: true

require_relative '../lib/location_weather'
require 'rspec/its'
RSpec.describe LocationWeather do
  subject(:weather) { described_class.new(line) }

  before do
    allow_any_instance_of(described_class).to receive(:get_weather!).and_return(hash)
  end

  context 'by city' do
    let(:hash) { '{"coord":{"lon":-122.42,"lat":37.78},"weather":[{"id":803,"main":"Clouds","description":"broken clouds","icon":"04d"}],"base":"stations","main":{"temp":288.08,"pressure":1013,"humidity":63,"temp_min":285.93,"temp_max":290.93},"visibility":16093,"wind":{"speed":7.7,"deg":230,"gust":10.3},"clouds":{"all":75},"dt":1557186063,"sys":{"type":1,"id":5817,"message":0.0098,"country":"US","sunrise":1557148109,"sunset":1557198244},"id":5391959,"name":"San Francisco","cod":200}' }
    let(:line) { 'San Francisco' }

    it { should_not be_nil }
    its(:parser) { should be_a_kind_of CityParser }
    its(:location_name) { should eq line }
    its(:temperature) { should be > 272 }
  end

  context 'by zip' do
    let(:hash) { '{"coord":{"lon":-122.42,"lat":37.78},"weather":[{"id":804,"main":"Clouds","description":"overcast clouds","icon":"04d"}],"base":"stations","main":{"temp":287.89,"pressure":1015,"humidity":82,"temp_min":285.37,"temp_max":290.37},"visibility":12874,"wind":{"speed":3.6,"deg":240},"clouds":{"all":90},"dt":1557186823,"sys":{"type":1,"id":4322,"message":0.0115,"country":"US","sunrise":1557148109,"sunset":1557198244},"id":420008446,"name":"San Francisco","cod":200}' }
    let(:line) { '94107' }

    it { should_not be_nil }
    its(:parser) { should be_a_kind_of ZipParser }
    its(:location_name) { should eq 'San Francisco' }
    its(:temperature) { should be > 272 }
  end

  context 'by long lat' do
    let(:lat) { 61.210841 }
    let(:lon) { -149.88873 }
    let(:line) { "#{lat},#{lon}" }

    it { should_not be_nil }

    its(:parser) { should be_a_kind_of LatLonParser }
    its('parser.lon') { should be_within(0.001).of lon }
    its('parser.lat') { should be_within(0.001).of lat }
    its('parser.query') { should eq 'lat=61.210841&lon=-149.88873' }
    its(:temperature) { should be > 272 }
  end
end
