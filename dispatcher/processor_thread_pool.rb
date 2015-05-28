class ProcessorThreadPool
  @instance = nil
  def self.instance
    return @instance = ProcessorThreadPool.new unless @instance
    @instance
  end
  def initialize(size = 8)

  end
  def add_resource(res, state, params)
    res.process(state, params)
  end
  def start

  end
end