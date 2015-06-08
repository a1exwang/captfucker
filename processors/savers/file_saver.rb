require './processors/processor'
class FileSaver < Processor
  class Manager < BaseManager
    def self.process_all(state, params, bundle_map)
      mgr = Manager.new(state, params)

      i = 0
      state.possible_states.each do |poss|
        j = 0
        poss.part_of_states.each do |part|
          mgr.schedule(FileSaver, part, params.merge(my_file_name: "#{i}_#{j}.png"), bundle_map)
          j += 1
        end
        i += 1
      end

      mgr.wait_until_all_done
      yield(mgr.result) if block_given?
      mgr.result
    end
    # user wait thread
    def done(part_key, new_state)
      @new_states += new_state
      @all_parts.delete part_key
      all_done if @all_parts.empty?
    end

  end
  def self.process(part_of_state, params)
    p = FileSaver.new(part_of_state, params)
    p.process
    p.result
  end
  def process
    Dir.mkdir(@params[:path] + '/') unless Dir.exists?(@params[:path] + '/')
    @graph.draw_to_file(@params[:path] + '/' + @params[:my_file_name])
  end
end