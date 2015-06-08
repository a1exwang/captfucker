require './processors/processor'
require './models/graph'
class PictureFontIdentifyProcessor < Processor
  class Manager < BaseManager
    def self.process_all(state, params, bundle_map)
      mgr = Manager.new(state, params)
      state.possible_states.each do |poss|
        poss.part_of_states.each do |part|
          mgr.schedule(PictureFontIdentifyProcessor, part, params, bundle_map)
        end
      end

      mgr.wait_until_all_done
      yield(mgr.result) if block_given?
      mgr.result
    end
  end

  def self.process(part_of_state, params)
    p = PictureFontIdentifyProcessor.new(part_of_state, params)
    p.process
    p.result
  end

  def process
    PictureFontIdentifyProcessor.init_fonts

    max_score = 0
    max_char = nil
    @fonts.each do |font|
      font[:score] = PictureFontIdentifyProcessor.compare(font[:image], @graph)
      if font[:score] > max_score
        max_score = font[:score]
        max_char = font[:char]
      end
    end

    @new_state = State.new([State::PossibleState.new([State::PartOfState.new(@graph, max_char, max_score)])])
  end

  private
  def self.init_fonts
    folder = params[:path]
    char_capture = /\A(.*)\.[a-zA-Z0-9]+\z/
    Dir.entries(folder).each do |entry|
      match = char_capture.match(entry)
      if match
        font[:char] = match[1]
        font[:graph] = Graph.new(folder + '/' + entry)
        @fonts.push(font)
      end
    end
    @fonts = []
  end

  def self.compare_graph(g1, g2)
    return 0 unless g1.width == g2.width && g1.height == g2.height
    score = 0.0
    g1.width.times do |x|
      g1.height.times do |y|
        score += 1 if g1.color_at([x,y]) == g2.color_at([x, y])
      end
    end
    return score / (g1.width * g1.height)
  end

end