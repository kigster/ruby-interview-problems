#!/usr/bin/env ruby
# frozen_string_literal: true

lib_path = File.expand_path("#{File.dirname(__FILE__)}/../lib")
$LOAD_PATH << lib_path if File.exist?(lib_path) && !$LOAD_PATH.include?(lib_path)

require 'location_parser'
require 'location_weather'

class HighestTemperature
  class << self
    attr_accessor :api_url, :token=
  end

  self.api_url = 'https://api.openweathermap.org/data/2.5/weather'
  self.token   = 'd7457467f2492af08b5aa255be8b2e2e'

  attr_accessor :hottest_location, :hottest_temp

  def initialize(data)
    @hottest_location = nil
    @hottest_temp     = 0

    data.split("\n").each do |line|
      parser = LocationParser.new(line)
      compare_temp(get_data(parser), parser)
    rescue ArgumentError
      puts "unknown format: #{line}"
    end
  end

  def get_data(parser)
    uri = URI("#{self.class.api_url}?#{parser.query}")
    res = Net::HTTP.get_response(uri)
    JSON.parse(res.body) if res.is_a?(Net::HTTPSuccess)
  end

  def compare_temp(hash, parser)
    temp = hash['main']['temp']
    @hottest_location = hash['name'] || parser.location if temp > @hottest_temp
  end
end
