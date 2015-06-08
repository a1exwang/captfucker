require './processors/processor'
require './models/state'
require './models/graph'
require './models/adjacent_judges/same_color'
class ColorDivider < Processor

  class Manager < BaseManager
    # user thread
    def self.process_all(state, params, bundle_map)
      mgr = Manager.new(state, params)
      state.possible_states.each do |poss|
        poss.part_of_states.each do |part|
          mgr.schedule(ColorDivider, part, params, bundle_map)
        end
      end

      mgr.wait_until_all_done
      yield(mgr.result) if block_given?
      mgr.result
    end
  end

  class GraphHelper
    def initialize(graph)
      @graph = graph
      clear
    end
    def clear
      visited_matrix = []
      @graph.width.times do |x|
        this_col = []
        @graph.height.times do |y|
          this_col.push(false)
        end
        visited_matrix.push(this_col)
      end
      @visited = visited_matrix
    end
    def visit(pt)
      @visited[pt.first][pt.last] = true
    end
    def visited?(pt)
      @visited[pt.first][pt.last]
    end
    def next_unvisited
      @graph.width.times do |col|
        @graph.height.times do |row|
          return [col, row] unless visited?([col, row])
        end
      end
      nil
    end
    def unvisited_adjacents(pt, adj_judge)
      ret = []
      adjs = adj_judge ? adj_judge.call(@graph, pt) : @graph.adjacents(pt)
      adjs.each do |adj|
        ret.push(adj) unless visited?(adj)
      end
      ret
    end
  end

  # params:
  # :custom_adjacents Type: proc
  def self.process(part_of_state, params)
    p = ColorDivider.new(part_of_state, params)
    p.process
    p.result
  end
  def initialize(part_of_state, params)
    super
    @graph.adj_judge = AdjacentJudge::SameColor.new(@graph)
    @ghelper = GraphHelper.new(@graph)
  end

  def process
    divide
  end
  def result
    @new_state
  end
  private
  # 将区域按照颜色不同分成不同的小区域
  def divide
    ptss = []

    while pos = @ghelper.next_unvisited
      pts = traverse_sub_bfs(pos)
      if (@params[:mode] != :filter) || (pts.size >= @params[:filter_min])
        ptss.push(pts)
      end
    end

    final_pts = []
    ptss.each do |pts|
      if @graph.color_at(pts.first) == [0, 0, 0]
        final_pts += pts
      end
    end
    final_g = Graph.from_pts(final_pts)

    @new_state = State.new([State::PossibleState.new([State::PartOfState.new(final_g)])])
  end
  def traverse_sub_bfs(pos)
    q = Queue.new
    def q.enq_all(arr)
      arr.each { |item| enq(item) }
    end

    pts = []
    q.enq(pos)

    until q.empty?
      current = q.deq

      next if @ghelper.visited?(current)

      @ghelper.visit(current)
      pts.push(current)

      q.enq_all(@ghelper.unvisited_adjacents(current, @params[:custom_adjacents]))
    end
    pts
  end

  def graph_add(g1, g2)
    ret = Graph.new([g1.width, g2.width].max, [g1.height, g2.height].max)
    ret.width.times do |x|
      ret.height.times do |y|
        # the situation that x, y is out of bound is considered
        ret.color_at([x, y], [0, 0, 0]) if [g1.color_at([x,y]), g2.color_at([x, y])].include? [0, 0, 0]
      end
    end
    ret
  end
end