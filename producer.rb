# Crie no rabbitmq um exchange chamada "orders_exchange" e uma fila chamada "orders"
# depois faça o binding dessa fila com a exchange usando a routing_key: "pending"
# caso não saiba como fazer isso ou tenha dúvidas estude como funciona o rabbitmq antes

require "rubygems"
require "bunny"

STDOUT.sync = true

# Cria uma conexão no rabbitmq com user: rabbitmq e password: rabbitmq
conn = Bunny.new("amqp://rabbitmq:rabbitmq@localhost:5672")
# inicia a conexão
conn.start

# cria um canal
channel = conn.create_channel
# pega uma exchange chamada orders_exchange, como essa exchange foi criada manualmente é necessário passar
# a opção durable: true
# essa exchage é do tipo "direct"
exchange = channel.direct("orders_exchange", durable: true)

# enviando a mensagem para o rabbitmq com uma routing_key: pending
# é através da routing_key que a exchange vai saber para qual fila enviar a mensagem
(1..40000).each do |n|
  exchange.publish("{\"order_number\": #{n}}", :routing_key => "pending")
end

# fecha a conexão
conn.close
