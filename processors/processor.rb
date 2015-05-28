require './models/state'
class Processor

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
    State::PossibleState.new [State::PartOfState.new(@graph, @text, @probability)]
  end

end