require './models/adjacent_judges/near'
module AdjacentJudge
  class SameColor
    def initialize(graph)
      @graph = graph
      @near = AdjacentJudge::Near.new(graph)
    end
    def adjacents(pt)
      return nil unless @graph.valid_pt?(pt)
      ret = []
      @near.adjacents(pt).each do |adj|
        ret.push(adj) if @graph.color_at(pt) == @graph.color_at(adj)
      end
      ret
    end
    def adjacent?(pt1, pt2)
      return nil unless @graph.valid_pt?(pt1) || @graph.valid_pt?(pt2)
      @near.adjacent?(pt1, pt2) && @graph.color_at(pt1) == @graph.color_at(pt2)
    end
  end
end
