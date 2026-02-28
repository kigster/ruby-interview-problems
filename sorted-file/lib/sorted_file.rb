# frozen_string_literal: true

class SortedFile
  class << self
    attr_reader :sort_extensions

    def sort_extensions=(extensions)
      @sort_extensions = extensions.map.with_index.to_h
    end

    def extension_index(extension)
      @sort_extensions[extension]
    end
  end

  attr_accessor :file_name

  def initialize(file_name)
    self.file_name = file_name
  end

  def extension
    file_name.split('.').last
  end

  def <=>(other)
    return nil unless other.is_a?(SortedFile)
    return nil if self.class.sort_extensions.empty?

    our_index   = self.class.extension_index(extension)
    other_index = self.class.extension_index(other.extension)
    if our_index && other_index
      our_index <=> other_index
    elsif our_index
      -1
    elsif other_index
      1
    else
      0
    end
  end

  def ==(other)
    return false unless other.is_a?(SortedFile)

    file_name == other.file_name
  end
end
