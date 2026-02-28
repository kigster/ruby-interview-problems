# frozen_string_literal: true

class LocationFinder
  attr_accessor :found_location

  def initialize(*data)
    data.each do |datum|
      datum.split("\n").each do |line|
        find(parse(line))
      end
    end
  end

  def parse(line)
    LocationWeather.new(line)
  end

  def find(_weather)
    raise ArgumentError, 'Abstract method called'
  end
end

class HottestLocation < LocationFinder
  attr_accessor :hottest_temperature

  def initialize(*, &)
    self.hottest_temperature = 0
    super
  end

  def find(weather)
    kelvins = weather.temperature
    return unless kelvins > hottest_temperature

    self.found_location = weather.location_name
    self.hottest_temperature = kelvins
  end
end
