#!/usr/bin/env ruby

# encoding: UTF-8
# frozen_string_literal: true

require File.join(ENV.fetch('RAILS_ROOT'), 'config', 'environment')
require 'csv'

def update_dependant_trades_timestamp(orders_ids)
  Trade.where(market_id: 'xrpbtc').each do |trade|
    trade.created_at = trade.updated_at = [trade.bid.created_at,trade.ask.created_at].max
    trade.save!
  end
end

def update_first
  first_trade_created = Trade.where(market_id: :xrpbtc).pluck(:created_at).min
  Trade.where(market_id: :xrpbtc).first.update(created_at: first_trade_created, updated_at: first_trade_created)
end

def wait_for_execution
  sleep_time = 4
  sleep sleep_time
  trade_count = Trade.count
  loop do
    Kernel.puts("Wait additional #{sleep_time} sec for orders matching and trades execution.")
    sleep 4
    break if trade_count - Trade.count == 0
    trade_count = Trade.count
  end
end

def trading_activity_seed
  wait_for_execution
  update_dependant_trades_timestamp(orders_ids)
  puts "Update first"
  update_first
  # TODO: output seeding results.
end

trading_activity_seed
