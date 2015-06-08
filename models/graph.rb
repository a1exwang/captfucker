require 'rmagick'
require './models/adjacent_judges/same_color'

class Graph
  DEFAULT_WIDTH = 80
  DEFAULT_HEIGHT = 80
  MAGICK_COLOR_MAX = 65535.0

  attr_accessor :width, :height, :adj_judge
  def self.from_file(file_path)
    Graph.new(file_path)
  end
  def self.from_pts(pts, size = nil, foreground = [0, 0, 0], back_ground = [1, 1, 1])
    size = pts_size(pts) unless size
    graph = Graph.new(size.first, size.last)
    pts.each do |pt|
      graph.color_at(pt, foreground)
    end
    graph
  end
  def self.pts_size(pts)
    xmax, ymax = 0, 0
    pts.each do |pt|
      xmax = pt.first if pt.first > xmax
      ymax = pt.last if pt.last > ymax
    end
    [xmax + 1, ymax + 1]
  end

  # two params: width, height
  # one param: file
  # no param: empty graph with default size
  def initialize(*args)
    case args.size
      when 0, 2
        self.width = args[0] || DEFAULT_WIDTH
        self.height = args[1] || DEFAULT_HEIGHT
        @matrix = Graph.img_to_matrix(Magick::Image.new(self.width, self.height))
      when 1
        img = Magick::ImageList.new(args[0])
        @matrix = Graph.img_to_matrix(img)
        self.height = img.rows
        self.width = img.columns
      else
        throw ArgumentError
    end
    self.adj_judge = AdjacentJudge::Near.new(self)
  end
  def color_at(pt, color = nil)
    return nil unless valid_pt?(pt) && pt.first >= 0 && pt.first < @matrix.size && pt.last >= 0 && pt.last < @matrix.first.size
    if Graph.is_color?(color)
      return @matrix[pt.first][pt.last] = color
    elsif color.is_a?(Numeric)
      return @matrix[pt.first][pt.last] = [color, color, color]
    else
      return @matrix[pt.first][pt.last]
    end
  end
  def draw_to_file(file_path)
    to_img.write(file_path)
  end
  def valid_pt?(pt)
    x = pt[0]
    y = pt[1]
    x >= 0 && x < self.width && y >= 0 && y < self.height
  end
  def adjacent?(pt1, pt2)
    self.adj_judge.adjacent?(pt1, pt2)
  end
  def adjacents(pt)
    self.adj_judge.adjacents(pt)
  end
  def edge(pt1, pt2)
    return nil unless adjacent?(pt1, pt2)
    [pt1, pt2]
  end
  def self.is_color?(color)
    color && color.is_a?(Array) && color.size == 3 && (0..1).include?(color[0]) && (0..1).include?(color[1]) && (0..1).include?(color[2])
  end
  def to_pts(color = [0, 0, 0])
    pts = []
    self.width.times do |x|
      self.height.times do |y|
        pts.push([x, y]) if color_at([x, y]) == color
      end
    end
    pts
  end
  private
  def self.pixel_to_color(pix)
    throw ArgumentError unless pix.is_a?(Magick::Pixel)
    [pix.red / MAGICK_COLOR_MAX, pix.green / MAGICK_COLOR_MAX, pix.blue / MAGICK_COLOR_MAX]
  end
  def self.color_to_pixel(color)
    throw ArgumentError unless Graph.is_color?(color)
    Magick::Pixel.new(color[0] * MAGICK_COLOR_MAX, color[1] * MAGICK_COLOR_MAX, color[2] * MAGICK_COLOR_MAX)
  end
  def self.img_to_matrix(img)
    matrix = []
    img.columns.times do |x|
      this_col = []
      img.rows.times do |y|
        this_col.push(pixel_to_color(img.pixel_color(x, y)))
      end
      matrix.push(this_col)
    end
    matrix
  end
  def to_img
    img = Magick::ImageList.new
    img.new_image(self.width, self.height)
    self.width.times do |x|
      self.height.times do |y|
        img.pixel_color(x, y, Graph.color_to_pixel(color_at([x, y])))
      end
    end
    img
  end
end