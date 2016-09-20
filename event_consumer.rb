#!/usr/bin/env ruby

def generate_command_routing_key(event_key)
  components = event_key.split('.')
  "#{components[0]}.#{components[1]}.command.generate_documents"
end

def send_message_to_wait

end

require 'bunny'

LISTEN_ROUTING_KEY = 'fla.*.event.application_complete'

conn = Bunny.new
conn.start

ch = conn.create_channel

#create our exchange
event_exchange = ch.topic('POC_bus')
command_exchange = event_exchange
wait_exchange = ch.direct('POC_wait')

#create our queue
q = ch.queue '', :exclusive => true
q.bind event_exchange, routing_key: LISTEN_ROUTING_KEY

#create the wait queue
wq = ch.queue 'wait', :exclusive => true, :arguments => {"x-dead-letter-exchange" => event_exchange.name}
wq.bind wait_exchange, routing_key: LISTEN_ROUTING_KEY

begin
  q.subscribe block: true, manual_ack: true  do |delivery_info, properties, body|
    puts "received: #{delivery_info.routing_key} body: #{body}"
    headers = properties.headers || {}
    dead_headers = headers.fetch("x-death", []).last || {}

    retry_count = headers.fetch("x-retry-count", 0)
    expiration = dead_headers.fetch("original-expiration", 1000).to_i

    #uncomment this line and comment the next batch for RPC
    # command_exchange.publish body, routing_key: generate_command_routing_key(delivery_info.routing_key)

    #comment these lines and uncomment the previous chunk for RPC.
    new_expiration = expiration * 1.5
    puts "publishing body: #{body} to wait queue with expiration #{new_expiration} and retry count #{retry_count + 1}"
    wait_exchange.publish body, routing_key: LISTEN_ROUTING_KEY, expiration: new_expiration.to_i, headers: { "x-retry-count": retry_count + 1 }

    ch.ack delivery_info.delivery_tag, false
  end
rescue Interrupt => _
  ch.close
  conn.close
end

