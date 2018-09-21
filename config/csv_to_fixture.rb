#!/usr/bin/env ruby
#
# Usage: ruby csv_to_fixture.rb file.csv [--json]
#

require 'csv'
require 'json'
require 'yaml'

arr = Array.new
input = ARGV.shift
is_file = (input.nil? ? false : File.exist?(input))
file = is_file ? input : STDIN
doc = is_file ? CSV.read(file) : CSV.parse(file.read)
records = Array.new
num_sell = 0
num_buy = 0
doc.each_with_index do |row, i|
  if row[4] == 'sell'
    num_sell += 1
  elsif row[4] == 'buy'
    num_buy += 1
  end
    arr.append(row)
end
p num_sell
p num_buy

file = File.open("trading.yml", "w")
time_bid = time_ask = price_bid = price_ask = amount_bid = amount_ask = 0
avg_per_orders = Hash.new
result = 0
count = 0
num_of_asks = num_of_bids = 0
arr.each do |row|
  count += 1
  if row[4] == 'sell'
    time_bid += row[0].to_i
    price_bid += row[2].to_f
    amount_bid += row[3].to_f
    num_of_bids += 1
  elsif row[4] == 'buy'
    time_ask += row[0].to_i
    price_ask += row[2].to_f
    amount_ask += row[3].to_f
    num_of_asks += 1
  end
  settings = Hash.new
  settings1 = Hash.new
  if count%1000 == 0
    avg_time_bid = time_bid/num_of_bids if num_of_bids > 0
    avg_price_bid = price_bid/num_of_bids if num_of_bids > 0
    avg_amount_bid = amount_bid/num_of_bids if num_of_bids > 0
    avg_time_ask = time_ask/num_of_asks if num_of_asks > 0
    avg_price_ask = price_ask/num_of_asks if num_of_asks > 0
    avg_amount_ask = amount_ask/num_of_asks if num_of_asks > 0
    result += 20
    settings['type'] = 'bid'
    settings['min_volume'] = settings['max_volume'] = avg_amount_bid
    settings['min_price'] = settings['max_price'] = avg_price_bid
    settings['amount'] = 10
    settings['traders'] = 'admin@barong.io'
    settings['min_created_at'] = settings['max_created_at'] = Time.at(avg_time_bid).to_s

    settings1['type'] = 'ask'
    settings1['min_volume'] = settings1['max_volume'] = avg_amount_ask
    settings1['min_price'] = settings1['max_price'] = avg_price_ask
    settings1['amount'] = 10
    settings1['traders'] = 'admin@barong.io'
    settings1['min_created_at'] = settings1['max_created_at'] = Time.at(avg_time_ask).to_s

    records.append(settings)
    records.append(settings1)
    time_bid = time_ask = num_of_asks = num_of_bids = price_ask = price_bid = amount_bid = amount_ask = count = 0
    avg_per_orders['ethbtc'] = records
    file.write(avg_per_orders.to_yaml)
    records = []
  end
end
p result