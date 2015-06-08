require './models/state'
require './config/ports'
require 'drb'
require 'digest/md5'
class Processor

  class BaseManager

    def initialize(state, params)
      @state = state
      @new_states = State.new
      @params = params
      @all_done_event = Queue.new
      @all_parts = []
    end

    def self.start_up_user_server
      user = Queue.new
      user
    end

    # user
    def self.start_up_user_wait_server(bundle_map)
      user_wait = Queue.new
      DRb.start_service("druby://localhost:#{USER_WAIT_PORT}", user_wait)
      # user wait thread
      Thread.new do
        # UserResultBundle
        loop do
          result_hash = Marshal.load(user_wait.deq)
          k = result_hash[:key]
          bundle_map[k][:manager].done(k, result_hash[:new_state])
          bundle_map.delete(k)
        end
      end
      user_wait
    end

    # user
    def schedule(class_name, part_of_state, params, bundle_map)
      key = Digest::MD5.new.hexdigest(Random.rand.to_s)
      bundle_map[key] = { manager: self }
      @all_parts.push(key)
      svr = DRbObject.new(nil, "druby://localhost:#{TASKS_PORT}")
      svr.enq Marshal.dump(processor_class_name: class_name.to_s, part_of_state: part_of_state, params: params, key: key)
    end

    # user wait thread
    def done(part_key, new_state)
      @new_states += new_state
      @all_parts.delete part_key
      all_done if @all_parts.empty?
    end

    # user
    def result
      @new_states
    end
    def all_done
      @all_done_event.enq ''
    end
    def wait_until_all_done
      @all_done_event.deq
    end

  end
  def self.process(part_of_state, params)
    nil
  end

  def initialize(part_of_state, params)
    @graph = part_of_state.graph
    @text = part_of_state.text
    @probability = part_of_state.probability
    @params = params
  end

  def result
    State.new([State::PossibleState.new([State::PartOfState.new(@graph, @text, @probability)])])
  end

end