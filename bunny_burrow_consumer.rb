require 'bunny_burrow'
require_relative 'constants.rb'

rpc_server = BunnyBurrow::Server.new do |server|
  server.rabbitmq_url = RABBITMQ_URL
  server.rabbitmq_exchange = RABBITMQ_EXCHANGE
  server.logger = Logger.new(STDOUT)
end

rpc_server.subscribe(TEST_ROUTING_KEY) do |payload|
  response = BunnyBurrow::Server.create_response
  response[:data] = "Got your payload #{payload}"
  rpc_server.logger.info response[:data]

  # return the response
  response
end

rpc_server.wait