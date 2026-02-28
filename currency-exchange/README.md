# Currency Conversions

Here we are given some number of Currency ticker pairs and their corresponding exchange rate.

Not all tickers exchange directly to every other ticker, so we have to figure out how to make several exchanges to convert X to Y. This requires walking the graph and populating it for each ticker to ticker combination.

While we are using a simplified algorithm here, without choosing the most optimal path, much more sophisticated algorithms exist.

## Optimized Algorithms

In reality, this currency conversion problem has several mathematically correct solutions, one of which can be read on the [Currency Arbitrage using Bellman Ford Algorithm](https://medium.com/@anilpai/currency-arbitrage-using-bellman-ford-algorithm-8938dcea56ea) blog post.

For more in-depth information, please see [this Stack Overflow Question — An algorithm for arbitrage in currency exchange](https://math.stackexchange.com/questions/94414/an-algorithm-for-arbitrage-in-currency-exchange).


## Concrete Example

Let's assume we are dealing with three currencies: US, Australian and Canadian dollar, but we are given only two exchange rates: from USD to CAN and from CAN to AUS:

```ruby
exchange_rates = {
  'USD-CAN' => 1.5,
  'CAN-AUS' => 1.1
}
```

Our job is to compute exchange rate from `USD` to `AUS`, which we can compute it by going through `CAN`.

In this case we want to see the following output after the ticker code analyzed all possible paths:

```ruby
USD-CAN  —▶  1.5000
CAN-AUS  —▶  1.1000
USD-AUS  —▶  1.6500
```

## Solution

Provided solution offers a class `TickerGraph` that can be used as follows:

```ruby
TickerGraph.new({
                    'USD-CAN' => 1.5,
                    'CAN-AUS' => 1.1
                }).resolve!
=>
USD-CAN ————▶    1.5000
CAN-AUS ————▶    1.1000
USD-AUS ————▶    1.6500
```
