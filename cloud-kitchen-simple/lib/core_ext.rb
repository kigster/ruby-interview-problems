# frozen_string_literal: true

class ThreadSafeHash < Hash
  attr_reader :mutex

  def initialize(*)
    super

    @mutex = Mutex.new
  end

  %i([] []= delete key? keys values).each do |method|
    define_method method do |*args, &block|
      mutex.synchronize { super(*args, &block) }
    end
  end
end

class ThreadSafeArray < Array
  attr_reader :mutex

  def initialize(*)
    super

    @mutex = Mutex.new
  end

  %i(<< [] []= delete include? pop unshift).each do |method|
    define_method method do |*args, &block|
      mutex.synchronize { super(*args, &block) }
    end
  end
end
