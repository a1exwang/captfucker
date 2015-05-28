class DispatcherDelegate
  @instance = nil
  def self.instance
    @instance = DispatcherDelegate.new unless @instance
    @instance
  end

  def schedule(class_name, part_of_state, callback_class)
    callback_class.done(class_name.process(part_of_state))
  end

end