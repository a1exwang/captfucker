require './processors/color_processors/binary_processor'
require './models/graph'
require './models/state'
require 'test/unit'
class TestBinaryProcessor < Test::Unit::TestCase
  def test_gray
    g = Graph.from_file('./test_imgs/src/desktop.png')
    pstate = State::PartOfState.new(g, '', 0)
    nps = BinaryProcessor.process(pstate, mode: :gray_range, gray_range: (0.5..0.8))
    nps.graph.draw_to_file('./test_imgs/binary_processor/desktop.png')
    true
  end
end