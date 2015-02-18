module Enumerable
  def parallel(opts = {})
    ConcurrentEnumerable::Parallel.new(self, opts)
  end

  def serial
    self
  end
end
