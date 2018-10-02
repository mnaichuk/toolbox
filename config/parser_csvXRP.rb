#!/usr/bin/env ruby
#
# Usage: ruby csv_to_fixture.rb file.csv [--json]
#

require 'csv'
require 'json'
require 'yaml'

count = -1
input = ARGV.shift
is_file = (input.nil? ? false : File.exist?(input))
file = is_file ? input : STDIN

doc = is_file ? CSV.read(file) : CSV.parse(file.read)
fields = doc.shift
records = Array.new
last_order_time = 0
doc.each_with_index do |row, i|
  if (row[0].to_i - last_order_time).abs < 8*60
    next
  end
  last_order_time = row[0].to_i
  count += 1
  record = Array.new
  fields.each_with_index do |field, j|
    record.append(row[j])
  end
    records.append(record)
end

flag = ARGV.shift unless input.nil?
flag ||= input || '--yaml'

case flag
when '--json' then
  puts records.to_json
else
  File.open("trading_activity_seed_XRP.yml", "w") { |file| file.write(records.to_yaml) }
end

p count