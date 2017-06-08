require 'bunny_burrow'
require_relative 'constants.rb'

client =  BunnyBurrow::Client.new do |client|
  client.rabbitmq_url = RABBITMQ_URL
  client.rabbitmq_exchange =RABBITMQ_EXCHANGE
  client.logger = Logger.new(STDOUT)
end

result = client.publish 'booga', TEST_ROUTING_KEY

puts result

sleep(20000)