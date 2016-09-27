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
q = ch.queue 'work', :exclusive => true,  :arguments => {"x-dead-letter-exchange" => wait_exchange.name, "x-dead-letter-routing-key"=> LISTEN_ROUTING_KEY}
q.bind event_exchange, routing_key: LISTEN_ROUTING_KEY

#create the wait queue
wq = ch.queue 'wait', :exclusive => true, :arguments => {"x-dead-letter-exchange" => event_exchange.name, "x-message-ttl" => 1000}
wq.bind wait_exchange, routing_key: LISTEN_ROUTING_KEY

begin
  q.subscribe block: true, manual_ack: true  do |delivery_info, properties, body|
    headers = properties.headers || {}
    dead_headers = headers.fetch("x-death", []).last || {}

    count = dead_headers.fetch("count", 0).to_i
    puts "received: #{delivery_info.routing_key} body: #{body}, count: #{count}"

    ch.basic_reject delivery_info.delivery_tag, false
  end
rescue Interrupt => _
  ch.close
  conn.close
end

