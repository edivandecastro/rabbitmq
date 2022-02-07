require "rubygems"
require "bunny"

STDOUT.sync = true

conn = Bunny.new("amqp://rabbitmq:rabbitmq@localhost:5672")
conn.start

channel = conn.create_channel
queue = channel.queue("orders", durable: true)

queue.subscribe do |delivery_info, metadata, payload|
  puts "Received #{payload}"
end

conn.close
