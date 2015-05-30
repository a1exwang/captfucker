require './models/state'
class ProcessList
  class Helper
    attr_accessor :procs
    def initialize
      self.procs = []
    end
    def add(class_name, params)
      self.procs.push(class_name: class_name, params: params)
    end
  end
  def self.process(graph)
    helper = Helper.new
    state = State.new(State::PossibleState.new(State::PartOfState.new(graph, '', 0)))
    proc = ProcessList.new(helper, state)
    yield(helper)
    proc.start
  end
  def initialize(helper, state)
    @helper = helper
    @bundle_map = {}
    @start_state = state
  end

  def start
    result = @start_state
    @helper.procs.keys.each do |key|
      proc = @helper.procs[key]
      result = proc[:class_name].process_all(result, proc[:params], @bundle_map)
    end
    result
  end
end