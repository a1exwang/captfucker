class State
  class PartOfState
    attr_accessor :graph, :text, :probability
    def initialize(graph, text = '', probability = 0)
      self.graph = graph
      self.text = text
      self.probability = probability
    end
  end
  class PossibleState
    attr_accessor :part_of_states, :text, :probability
    def initialize(part_of_states = nil, probability = 0)
      self.part_of_states = part_of_states || []
      self.text = ''
      self.part_of_states.each do |part|
        self.text += part.text
      end
      self.probability = probability
    end
    def +(other)
      PossibleState.new(self.part_of_states + other.possible_states)
    end
  end

  attr_accessor :possible_states, :text, :probability
  def initialize(possible_states = [], probability = 0)
    self.possible_states = possible_states
    self.text = ''
    possible_states.each do |ps|
      self.text += ps.text
    end
    self.probability = probability
  end
  def +(other)
    State.new(possible_states + other.possible_states)
  end

end
