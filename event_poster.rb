#!/usr/bin/env ruby

require 'bunny'

conn = Bunny.new
conn.start

ch = conn.create_channel

#create our exchange
x = ch.topic('POC_bus')

x.publish 'beetlebum', routing_key: 'fla.rdlife.event.application_complete'
