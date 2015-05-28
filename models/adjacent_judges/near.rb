module AdjacentJudge
  class Near
    def initialize(graph)
      @graph = graph
    end
    def adjacents(pt)
      return nil unless @graph.valid_pt?(pt)
      x = pt.first
      y = pt.last
      ret = []
      ret.push([x, y + 1]) if y + 1 < @graph.height
      ret.push([x, y - 1]) if y - 1 >= 0
      ret.push([x + 1, y]) if x + 1 < @graph.width
      ret.push([x - 1, y]) if x - 1 >= 0
      ret
    end
    def adjacent?(pt1, pt2)
      adjacents(pt1).include?(pt2)
    end
  end
end