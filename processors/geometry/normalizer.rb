require './processors/processor'
require './models/graph'

class Normalizer < Processor
  class Manager < BaseManager
    def self.process_all(state, params, bundle_map)
      mgr = Manager.new(state, params)
      state.possible_states.each do |poss|
        poss.part_of_states.each do |part|
          mgr.schedule(Normalizer, part, params, bundle_map)
        end
      end

      mgr.wait_until_all_done
      yield(mgr.result) if block_given?
      mgr.result
    end
  end

  def self.process(part_of_state, params)
    p = Normalizer.new(part_of_state, params)
    p.process
    p.result
  end
  def process
    if @params[:size]
      to_left_top!
      scale_to!(@params[:size])
    else
      throw ArgumentError
    end
  end

  private
  def initialize(_, __)
    super
    set_window_area
  end
  def to_left_top!
    size = [@attributes[:width], @attributes[:height]].max
    new_img = Graph.new(size, size)
    size.times do |x|
      size.times do |y|
        if @graph.valid_pt?([x + @attributes[:xleft], y + @attributes[:ytop]])
          color = @graph.color_at([x + @attributes[:xleft], y + @attributes[:ytop]])
          new_img.color_at([x, y], color)
        end
      end
    end
    @graph = new_img
  end
  def scale_to!(size)
    original_size = [@graph.width, @graph.height].max
    scale = size.to_f / original_size

    new_img = Graph.new(size, size)
    # 初始化为全白图片
    size.times do |x|
      size.times do |y|
        val = near_5_average([x/scale, y/scale]) < 0.5 ? 0 : 1
        new_img.color_at([x, y], [val, val, val])
      end
    end
    @graph = new_img
  end

  def set_window_area
    @pts = @graph.to_pts
    # 初始化属性
    xmin, xmax = @pts[0].first, @pts[0].first
    ymin, ymax = @pts[0].last, @pts[0].last
    @pts.each do |pt|
      xmin = pt.first if pt.first < xmin
      xmax = pt.first if pt.first > xmax
      ymin = pt.last if pt.last < ymin
      ymax = pt.last if pt.last > ymax
    end
    @attributes = { :width  => xmax - xmin,
                    :height => ymax - ymin,
                    :xleft  => xmin,
                    :ytop   => ymin }
  end

  def near_5_pts(pt)
    row = pt.first.to_i
    col = pt.last.to_i
    ret = []
    ret.push([row, col]) if @graph.valid_pt?([row, col])
    ret.push([row+1, col]) if @graph.valid_pt?([row+1, col])
    ret.push([row-1, col]) if @graph.valid_pt?([row-1, col])
    ret.push([row, col+1]) if @graph.valid_pt?([row, col+1])
    ret.push([row, col-1]) if @graph.valid_pt?([row, col-1])
    ret
  end
  # 从新的坐标转换为原来的坐标, 假如原来的坐标周围的5个像素点如果至少存在1个
  #   那么求四个点的平均值 小于0.5则为该点为黑色
  def near_5_average(pt)
    pts = near_5_pts(pt)
    return 1 if pts.size == 0
    total = 0.0
    pts.each do|this_pt|
      total += @graph.color_at(this_pt).inject{|sum, el| sum + el} / 3.0
    end
    total / pts.size
  end
end