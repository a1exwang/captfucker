require './processors/manager'
require './processors/color_processors/binary_processor'

class BinaryProcessManager
  def self.process_all(state)
     state.possible_states.each do |poss|
       poss.part_of_state.each do |part|
         schedule BinaryProcessor, part
       end
     end
  end

  def self.done
    # if all_done
    #   send!(:all_done)
    # else
    #
    # end
  end

end