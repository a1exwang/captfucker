require './processors/processor'
require './models/graph'

class WeightProcessor < Processor
  class Manager < BaseManager
    def self.process_all(state, params, bundle_map)
      mgr = Manager.new(state, params)
      state.possible_states.each do |poss|
        poss.part_of_states.each do |part|
          mgr.schedule(WeightProcessor, part, params, bundle_map)
        end
      end

      mgr.wait_until_all_done
      yield(mgr.result) if block_given?
      mgr.result
    end
  end

  def self.process(part_of_state, params)
    p = WeightProcessor.new(part_of_state, params)
    p.process
    p.result
  end
  def initialize(part_of_state, params)
    super
    @graph.adj_judge = AdjacentJudge::SameColor.new(@graph)
    @params[:min_adjs] = 4 unless @params[:min_adjs]
    @params[:direction] = :to_deep_color unless @params[:direction]
  end

  def process

    pts = []
    @graph.width.times do |x|
      @graph.height.times do |y|
        # 如果符合 最小邻接点个数的要求 和 颜色的要求
        if (@graph.adjacents([x, y]).size < @params[:min_adjs]) &&
            (@params[:strange_edge] || ((@params[:direction] == :thinner) == WeightProcessor.deep_color?(@graph.color_at([x, y]))))
          pts.push([x, y])
        end
      end
    end
    pts.each do |pt|
      @graph.color_at(pt, WeightProcessor.color_reverse(@graph.color_at(pt)))
    end

    @new_state = State.new([State::PossibleState.new([State::PartOfState.new(@graph)])])
  end
  def result
    @new_state
  end

  def self.color_reverse(color)
    return [1 - color[0], 1 - color[1], 1 - color[2]]
  end
  def self.deep_color?(color)
    return (color[0] + color[1] + color[2]) / 3.0 < 0.5
  end

end