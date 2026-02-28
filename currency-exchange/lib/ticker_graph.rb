# frozen_string_literal: false

require 'stringio'
require 'colored2'

class TickerGraph
  TickerTuple = Struct.new(:tuple, :amount) do
    attr_accessor :from, :to

    def initialize(*args)
      super
      self.from, self.to = args.first.split('-')
    end

    def ticker
      "#{from}-#{to}"
    end
  end

  attr_accessor :ticker_tuples, :currencies, :tuple_prices, :graph, :todo

  def initialize(ticker_tuple_hash = nil)
    self.currencies    = {}
    self.todo          = {}
    self.tuple_prices  = {}
    self.ticker_tuples = []
    self.graph         = {}

    ticker_tuple_hash&.each_pair do |tuple, amount|
      ticker_tuple = TickerTuple.new(tuple, amount)
      ticker_tuples << ticker_tuple
      tuple_prices[ticker_tuple.ticker] = ticker_tuple.amount
      register_edge(ticker_tuple)
    end
  end

  def resolve!
    populate_currencies!
    walk_edges!
    self
  end

  def to_s
    "\n#{as_string}"
  end

  private

  def walk_edges!(from = first_ticker, sub_graph = {})
    currencies[from]&.each_pair do |to, amount|
      next if from == to

      ticker = "#{from}-#{to}"
      next if sub_graph.key? ticker

      sub_graph[ticker] = amount
      walk_edges!(to, sub_graph)
    end

    graph.merge!(sub_graph)
  end

  def populate_currencies!(from_ticker = nil)
    keys = from_ticker.nil? ? currencies.keys : [from_ticker]
    keys.each do |from|
      currencies[from] ||= {}
      currencies.each_key do |to|
        next if to == from

        currencies[from][to] ||= nil

        next if currencies[from][to].nil?

        currencies[to].each_key do |transient_to|
          next if currencies[from].key?(transient_to) ||
                  currencies[from][to].nil? ||
                  currencies[to][transient_to].nil?

          currencies[from][transient_to] = (currencies[from][to] * currencies[to][transient_to]).to_f.round(4)
          populate_currencies!(to)
        end
      end
    end

    currencies.each_key do |from|
      tos = currencies[from].keys.select { |k| currencies[from][k].nil? }
      unless tos.empty?
        todo[from] ||= Set.new
        tos.each { |to| todo[from] << to }
      end
    end

    todo.each_key do |from|
      todo[from].each do |to|
        if currencies[to][from]
          currencies[from][to] = 1.0 / currencies[to][from]
        end
      end
    end
  end

  def first_ticker
    currencies.keys.first
  end

  def as_string
    out = StringIO.new
    conversions = []
    graph.each_pair do |ticker, amount|
      string = ticker

      if amount
        string += ' ————▶ '
        string += sprintf('%9.4f', amount).bold.yellow
      end

      conversions << string
    end

    out.puts conversions.sort.join("\n")
    out.string
  end

  def register_edge(tuple)
    currencies[tuple.from] ||= {}
    currencies[tuple.from][tuple.to] = tuple.amount

    currencies[tuple.to] ||= {}
    currencies[tuple.to][tuple.from] = 1.0 / tuple.amount
  end
end
