#!/usr/bin/env ruby

require 'bunny'

LISTEN_ROUTING_KEY = 'fla.rdlife.command.generate_documents'

conn = Bunny.new
conn.start

ch = conn.create_channel

#create our exchange
command_exchange = ch.topic('POC_bus')

#create our queue
q = ch.queue '', :exclusive => true

q.bind command_exchange, routing_key: LISTEN_ROUTING_KEY

begin
  q.subscribe block: true do |delivery_info, properties, body|
    puts "received: #{delivery_info.routing_key} body: #{body}"
  end
rescue Interrupt => _
  ch.close
  conn.close
end
