# frozen_string_literal: true

module OutputDebug
  class << self
    attr_accessor :enabled
  end

  self.enabled = true

  DEBUG           = !ENV['DEBUG'].nil?
  RUBY_HOME_REGEX = %r{(gems|site_ruby)/2\.}
  RUBY_HOME_PROC  = -> { Gem.path.each { |p| return p.split(RUBY_HOME_REGEX).first if p =~ RUBY_HOME_REGEX } }
  RUBY_HOME       = RUBY_HOME_PROC[]
  OUTPUT_MUTEX    = Mutex.new.freeze

  def log_debug(msg, argument = nil, *, prefix: ' [DEBUG] '.green, **)
    return unless DEBUG

    log(msg, argument, *, prefix: prefix)
  end

  def log_info(msg, argument = nil, *, prefix: ' [INFO ] '.blue, **)
    log(msg, argument, *, prefix: prefix)
  end

  def log_error(*args, e: nil, prefix: ' [ERROR] '.white.on.red, **)
    args.each { |line| warn "#{prefix} #{line.to_s.italic.red}" }
    log("ERROR: #{e.message}", prefix: prefix) if e

    return unless e&.backtrace

    log(*e&.backtrace&.map { |b| b.gsub(RUBY_HOME, '') },
        prefix: '         ')
  end

  def log_order_event(event, order, colors = [], **opts)
    order_id = ::Kitchen.order_id(order)
    event_name = event.to_s.downcase
    len = event_name.length
    padding = (20 - len) / 2
    padding = ' ' * padding
    event_name = "#{padding}#{event_name}#{padding}"[0...19]
    event_name = colors.reduce(event_name) { |memo, c| memo.send(c) }

    log_info(
      format(
        "Order [#{order_id.bold.yellow}] 〈 #{event_name} 〉 %-20.20s ",
        (order.is_a?(Kitchen::Order) ? order.name : '')
      ),
      (opts[:arg] ? " → #{opts[:arg]}" : ''),
      **opts
    )
  end

  private

  def ts
    Time.now.strftime('%T.%L')
  end

  def output(stream, ts, line, prefix = '')
    stream.print ts + prefix + line
  end

  def log(msg, argument = nil, *args, prefix: '')
    return unless OutputDebug.enabled

    OUTPUT_MUTEX.synchronize do
      output($stdout, ts.yellow, "#{msg} ", prefix)

      argument = argument.to_s.red if argument

      if argument&.include?("\n")
        $stdout.puts
        argument_lines = (argument || '').split("\n")
        argument_lines.each { |line| output($stdout, ts.yellow, line); $stdout.puts }
      else
        $stdout.puts(argument.to_s.yellow)
      end

      args.each { |line| output($stdout, line, prefix: prefix) }
    end
  end
end
# rubocop: enable Metrics/CyclomaticComplexity
