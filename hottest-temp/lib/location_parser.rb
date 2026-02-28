# frozen_string_literal: true

class LocationParser
  attr_accessor :line, :location

  class << self
    attr_accessor :parsers

    def parser(line)
      parsers.map{ |p| p.new(line) }.find(&:matches?)
    end
  end

  def initialize(line)
    self.line     = line
    self.location = line
  end

  def query
    raise InvalidArgument, 'Abstract class #query called'
  end

  def matches?
    raise InvalidArgument, 'Abstract class #matches? called'
  end
end

class ZipParser < LocationParser
  def matches?
    line =~ /\d{5}/
  end

  def query
    zip = line.scan(/(\d{5})/)&.first&.first
    "zip=#{zip}" if zip
  end
end

LocationParser.parsers = [ZipParser]
