require './processors/processor'
require './models/state'
class ColorDivider < Processor

  # params:
  # :custom_adjacents Type: proc
  def self.process(part_of_state, params)
    p = ColorDivider.new(part_of_state, params)
    p.process
    p.result
  end
  def initialize(part_of_state, params)
    super
    def @graph.clear
      visited_matrix = []
      self.width.times do |x|
        this_col = []
        self.height.times do |y|
          this_col.push(false)
        end
        visited_matrix.push(this_col)
      end
      @visited = visited_matrix
    end
    def @graph.visit(pt)
      @visited[pt.first][pt.last] = true
    end
    def @graph.visited?(pt)
      @visited[pt.first][pt.last]
    end
    def @graph.next_unvisited
      self.count.times do |col|
        self.first.count.times do |row|
          return [col, row] unless visited?([col, row])
        end
      end
      nil
    end
    def @graph.unvisited_adjacents(pt)
      ret = []
      adjs = @params[:custom_adjacent] ? @params[:custom_adjacent].call(self, pt) : adjacents(pt)
      adjs.each do |adj|
        ret.push(adj) unless @graph.visited?(adj)
      end
      ret
    end

    @graph.clear
  end
  def result
    part_of_states = []
    @graphs.each do |g|
      part_of_states.push(State::PartOfState.new(g, '', 0))
    end
    State::PossibleState.new(part_of_states)
  end

  def process
    divide
  end

  # 将区域按照颜色不同分成不同的小区域
  def divide
    @graphs = []
    while pos = @graph.next_unvisited
      pts = traverse_sub_bfs(pos)
      @graphs.push(pts_to_graph(pts, ColorDivider.pts_size(pts)))
    end
    @graphs
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

      next if @graph.visited?(current)

      @graph.visit(current)
      pts.push(current)

      #if pts.size % 10000 == 0 || pts.size < 6
      #  puts "Area Size: #{pts.size}"
      #end

      q.enq_all(@graph.unvisited_adjacents(current))
    end
    pts
  end

  private
  def self.pts_size(pts)
    xmax, ymax = 0, 0
    pts.each do |pt|
      xmax = pt.first if pt.first > xmax
      ymax = pt.last if pt.last > ymax
    end
    [xmax + 1, ymax + 1]
  end
  def self.pts_to_graph(pts, size, color = 0)
    graph = Graph.new(size.first, size.last)
    pts.each do |pt|
      graph.color_at(pt, color)
    end
    graph
  end
end