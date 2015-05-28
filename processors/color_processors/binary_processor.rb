require './dispatcher/processor_thread_pool'
require './models/graph'
require './models/state'
require './processors/processor'

class BinaryProcessor < Processor
  def self.process(part_of_state, params)
    p = BinaryProcessor.new(part_of_state, params)
    p.process
    p.result
  end
  def process
    ps = nil
    case @params[:mode]
      when :gray_range
        ps = to_bin(@params[:gray_range], @params[:average_mode] || :mathimatical)
      when :custom
        ps = to_bin { |color| @params[:bin_lambda].call(color) }
      else
        throw ArgumentError
    end
    poss = State::PossibleState.new([ps], @probability)
    State.new([poss], @probability)
  end

  private
    def average(mode = :mathimatical)
      total = 0
      @graph.width.times do |x|
        @graph.height.times do |y|
          color = @graph.color_at([x, y])
          total += gray_of(color, mode)
        end
      end
      total / @graph.width / @graph.height
    end
    def to_gray(mode = :mathimatical)
      @graph.width.times do |x|
        @graph.height.times do |y|
          color = @graph.color_at([x, y])
          g = gray_of(color, mode)
          @graph.color_at([x, y], g)
        end
      end
    end
    def gray_of(color, mode = :mathimatical)
      throw ArgumentError unless Graph.is_color?(color)
      case mode
        when :ntsc
          0.11 * color[0] + 0.59 * color[1] + 0.3 * color[2]
        when :mathimatical
          (color[0] + color[1] + color[2]) / 3.0
        when :r
          color[0]
        when :g
          color[1]
        when :b
          color[2]
        else
          throw ArgumentError
      end
    end
    def to_bin(gray_range = (0..1.0), mode = :mathimatical)
      @graph.width.times do |x|
        @graph.height.times do |y|
          color = @graph.color_at([x, y])
          if block_given?
            g = yield(color)
            throw ArgumentError unless [0, 1].include? (g)
          else
            g = gray_range.include?(gray_of(color, mode)) ? 0 : 1
          end
          @graph.color_at([x, y], g)
        end
      end
    end
end
