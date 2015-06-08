# This file starts thread pool service,
# message service and thread pool workers

require 'drb'
require './config/ports'

# thread pool server
tasks = Queue.new
DRb.start_service("druby://localhost:#{TASKS_PORT}", tasks)

# message server
msg = Queue.new
def msg.show(m)
  puts m
end
DRb.start_service("druby://localhost:#{SERVER_MSG_PORT}", msg)

# start workers
puts `sh dispatcher/start_workers.sh 8`

DRb.thread.join