# frozen_string_literal: true

require 'colored2'
require 'uri'
require 'net/http'
require 'json'
require_relative 'location_parser'

class LocationWeather
  class << self
    attr_accessor :api_url, :token
  end

  self.api_url = 'https://api.openweathermap.org/data/2.5/weather'
  self.token   = 'd7457467f2492af08b5aa255be8b2e2e'

  attr_accessor :line, :parser, :hash

  def initialize(line)
    self.line = line
    self.parser = LocationParser.parser(line)
    raise ArgumentError, "Unable to parse string: [#{line}]" if parser.nil?

    self.hash = get_weather!
  end

  def get_weather!
    uri = URI("#{self.class.api_url}?appid=#{self.class.token}&#{parser.query}")
    res = Net::HTTP.get_response(uri)
    JSON.parse res.body if res.is_a?(Net::HTTPSuccess)
  rescue StandardError => e
    warn "Error getting data for line:\n#{line}"
    warn e.inspect.bold.red
  end

  def temperature
    return nil if hash.nil?

    hash['main']['temp']
  end

  def location_name
    return nil if hash.nil?

    hash['name'] || parser.location
  end
end
