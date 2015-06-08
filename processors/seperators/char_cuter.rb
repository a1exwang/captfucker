require './processors/processor'

class CharCuter < Processor
  class Manager < BaseManager
    # user thread
    def self.process_all(state, params, bundle_map)
      mgr = Manager.new(state, params)
      state.possible_states.each do |poss|
        poss.part_of_states.each do |part|
          mgr.schedule(CharCuter, part, params, bundle_map)
        end
      end

      mgr.wait_until_all_done
      yield(mgr.result) if block_given?
      mgr.result
    end
  end
  def self.process(part_of_state, params)
    p = CharCuter.new(part_of_state, params)
    p.process
    p.result
  end
  def initialize(part_of_state, params)
    super
    @graph.adj_judge = AdjacentJudge::SameColor.new(@graph)
  end

  def process

    # find all white columns in white_cols
    white_cols = []
    @graph.width.times do |x|
      white_cols.push(is_white_column(x))
    end

    # find all white ranges(continuous white lines) in white_ranges
    white_ranges = []
    in_char = false
    white_cols.size.times do |index|
      if in_char
        if white_cols[index]
          white_ranges.push(index)
          in_char = false
        else
          # do nothing, reading char
        end
      else
        if white_cols[index]
          # do nothing
        else
          in_char = true
        end
      end
    end

    # assume the column 0 is also white
    white_ranges.insert(0, 0)

    # get all cut char graphs
    ret = []
    (1...white_ranges.size).each do |white_x|
      this_char = []
      (white_ranges[white_x-1]..white_ranges[white_x]).each do |x|
        @graph.height.times do |y|
          this_char.push([x, y]) if @graph.color_at([x, y]) == [0, 0, 0]
        end
      end
      ret.push(State::PartOfState.new(Graph.from_pts(this_char)))
    end
    ret
    @new_state = State.new([State::PossibleState.new(ret)])
  end
  def result
    @new_state
  end

  private
  def is_white_column(x)
    @graph.height.times do |y|
      return false if @graph.color_at([x, y]) == [0, 0, 0]
    end
    true
  end
end