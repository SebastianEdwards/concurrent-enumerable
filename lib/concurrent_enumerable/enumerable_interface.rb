module ConcurrentEnumerable
  module EnumerableInterface
    module_function

    def use(runner, methods)
      enumerable_methods = Enumerable.instance_methods.map(&:to_s)
      enumerable_methods << 'each'
      methods.each do |method|
        next unless enumerable_methods.include?(method)
        class_eval <<-RUBY
        def #{method}(*args, &block)
          #{runner}(:#{method}, *args, &block)
        end
        RUBY
      end
    end

    private :use

    use :run_in_threads, %w(
      all? any? count detect find find_index max_by min_by minmax_by none?
      one? partition
    )

    use :run_in_threads_return_original, %w(
      cycle each each_cons each_entry each_slice each_with_index enum_cons
      enum_slice enum_with_index reverse_each zip
    )

    use :run_in_threads_return_parallel, %w(
      collect collect_concat drop_while find_all flat_map grep group_by map
      reject select sort sort_by take_while zip
    )
  end
end
