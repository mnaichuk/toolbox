require 'yaml'

data = YAML.load_file('kek.yml')

data.each do |arr|
  p arr
end
