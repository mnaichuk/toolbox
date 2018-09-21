#!/usr/bin/env ruby

# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')
require 'csv'

def build_order(market_id, order_row, options={})
  market  = Market.find_by_id(market_id)
  traders = Member.where(email: options[:traders].split(',').map(&:squish)).pluck(:id)
  {
      ord_type:   :limit,
      bid:        market.quote_unit,
      ask:        market.base_unit,
      type:       order_row[4] == 'sell' ? 'OrderBid' : 'OrderAsk',
      member_id:  traders.sample,
      market_id:  market.id,
      state:      ::Order::WAIT,
      price:      order_row[2],
      volume:     order_row[3],
      created_at: Time.at(order_row[0].to_i)
  }
end

def update_dependant_trades_timestamp(orders_ids)
  Trade.where(ask_id: orders_ids) + Trade.where(bid_id: orders_ids).each do |trade|
    trade.created_at = trade.updated_at = [trade.bid.created_at,trade.ask.created_at].max
    trade.save!
  end
end

def wait_for_execution
  sleep_time = 2
  sleep sleep_time
  trade_count = Trade.count
  loop do
    Kernel.puts("Wait additional #{sleep_time} sec for orders matching and trades execution.")
    sleep sleep_time
    break if trade_count - Trade.count == 0
    trade_count = Trade.count
  end
end

def trading_activity_seed
  orders_ids = []
  market = 'ethbtc'
  traders = 'mykola.kuvshynnikov@gmail.com'

  yml_data = YAML.load_file('config/trading_activity_seed_ETH.yml')
  # Create orders in reverse because we timestamp should be asc.
  yml_data.reverse_each do |row|
    order_obj = build_order(market, row, traders: traders)
                    .yield_self { |order_hash| Order.new(order_hash) }
    # Skip invalid orders.
    next if order_obj.invalid?
    Ordering.new(order_obj).submit
    orders_ids << order_obj.id
  end

  wait_for_execution
  update_dependant_trades_timestamp(orders_ids)
  # TODO: output seeding results.
end

trading_activity_seed
