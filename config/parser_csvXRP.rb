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
doc.each_with_index do |row, i|
  if i%2 == 1 && i%7 == 1 
    count += 1
    record = Array.new
    fields.each_with_index do |field, j|
      record.append(row[j])
    end
    records.append(record)
  end
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