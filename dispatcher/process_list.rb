require './models/state'
require './models/graph'
require './processors/processor'
class ProcessList
  class Helper
    attr_accessor :procs
    def initialize
      self.procs = []
    end
    def add(class_name, params = {})
      self.procs.push(class_name: eval(class_name.to_s + '::Manager'), params: params)
    end
  end

  # graph is a filename of a Graph object
  def self.process(graph, params)
    parts = nil
    if params
      case params[:from]
        when :obj
          parts = [State::PartOfState.new(graph, '', 0)]
        when :file
        parts = [State::PartOfState.new(Graph.from_file(graph), '', 0)]
        when :folder
          parts = []
          if params[:size]
            i = 0
            Dir.open(graph).entries.each do |entry|
              full_path = graph + '/' + entry
              parts.push(State::PartOfState.new(Graph.from_file(full_path))) if File.file?(full_path)
              i += 1
              break if i >= params[:size]
            end
          else
            Dir.open(graph).entries.each do |entry|
              full_path = graph + '/' + entry
              parts.push(State::PartOfState.new(Graph.from_file(full_path))) if File.file?(full_path)
            end
          end

        else
          throw ArgumentError
        end
    else
      throw ArgumentError
    end

    helper = Helper.new
    state = State.new([State::PossibleState.new(parts)])
    proc = ProcessList.new(helper, state)
    yield(helper)
    proc.start
  end
  def initialize(helper, state)
    @helper = helper
    @bundle_map = {}
    Processor::BaseManager.start_up_user_server
    Processor::BaseManager.start_up_user_wait_server(@bundle_map)
    @start_state = state
  end

  def start
    result = @start_state
    @helper.procs.each do |proc|
      result = proc[:class_name].process_all(result, proc[:params], @bundle_map)
    end
    result
  end
end