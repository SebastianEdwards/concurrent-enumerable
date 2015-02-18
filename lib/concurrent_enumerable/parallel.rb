module ConcurrentEnumerable
  class Parallel < SimpleDelegator
    include EnumerableInterface

    protected :__getobj__, :__setobj__

    def initialize(list, opts = {})
      super list
      @opts = opts
      @executor = Concurrent::OptionsParser.get_executor_from(opts) || \
                  Concurrent.configuration.global_task_pool
    end

    def parallel
      self
    end

    def serial
      __getobj__
    end

    protected

    def run_in_threads(method, *args, &block)
      if block
        latch = Concurrent::CountDownLatch.new(size)

        results = Array.new(size)

        index = Concurrent::AtomicFixnum.new(-1)

        __getobj__.each do |item|
          i = index.increment

          @executor.post do
            results[i] = yield(item)
            latch.count_down
          end
        end

        latch.wait
        results.send(method, *args) { |value| value }
      else
        send method, *args
      end
    end

    def run_in_threads_return_original(method, *args, &block)
      run_in_threads(method, *args, &block)

      self
    end

    def run_in_threads_return_parallel(method, *args, &block)
      Parallel.new run_in_threads(method, *args, &block), @opts
    end
  end
end
