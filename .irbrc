RABBITMQ_URL = 'amqp://direct:direct@queue.uat.vericity.net'
RABBITMQ_EXCHANGE = 'vericity'

require 'bunny'

$conn = Bunny.new
$conn.start
