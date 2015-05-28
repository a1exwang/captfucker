
require './models/graph'
require './models/state'
require './processors/color_processors/binary_processor'

g = Graph.from_file('./test_imgs/src/desktop.png')
pstate = State::PartOfState.new(g, '', 0)
states = BinaryProcessor.process(pstate, mode: :gray_range, average_mode: :ntsc, gray_range: (0.65..0.9))
states.part_of_states[0].graph.draw_to_file('./test_imgs/binary_processor/desktop.png')
