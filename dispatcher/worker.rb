# This file is worker's file

# Thread pool worker is a new process which receives a
# processing task identifier and excute it.

require 'drb'
require './processors/all'
require './config/ports'

msg_svr = DRbObject.new(nil, "druby://localhost:#{SERVER_MSG_PORT}")
tasks = DRbObject.new(nil, "druby://localhost:#{TASKS_PORT}")
user_wait = DRbObject.new(nil, "druby://localhost:#{USER_WAIT_PORT}")

loop do
  bundle = Marshal.load(tasks.deq)
  new_state = eval(bundle[:processor_class_name]).process(bundle[:part_of_state], bundle[:params])
  user_wait.enq(Marshal.dump(new_state: new_state, key: bundle[:key]))

  msg_svr.show bundle[:processor_class_name].to_s
  msg_svr.show bundle[:params].to_s
end