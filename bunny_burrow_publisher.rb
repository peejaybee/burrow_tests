require 'bunny_burrow'
require_relative 'constants.rb'

client =  BunnyBurrow::Client.new do |client|
  client.rabbitmq_url = RABBITMQ_URL
  client.rabbitmq_exchange =RABBITMQ_EXCHANGE
  client.logger = Logger.new(STDOUT)
end

1.times do |n|
  payload = "#{n}:#{ARGV[0]}"
  puts payload
  result = client.publish payload, TEST_ROUTING_KEY

  puts result
end
