class Array
  # Wraps its argument in an array unless it is already an array (or array-like).
  #
  # Specifically:
  #
  # * If the argument is +nil+ an empty list is returned.
  # * Otherwise, if the argument responds to +to_ary+ it is invoked, and its result returned.
  # * Otherwise, returns an array with the argument as its single element.
  #
  # @example nil: an empty list
  #     Array.wrap(nil)       # => []
  # @example an array: itself
  #     Array.wrap([1, 2, 3]) # => [1, 2, 3]
  # @example an atom: array of length 1
  #     Array.wrap(0)         # => [0]
  #
  # This method is similar in purpose to `Kernel#Array`, but there are some differences:
  #
  # * If the argument responds to +to_ary+ the method is invoked. `Kernel#Array`
  # moves on to try +to_a+ if the returned value is +nil+, but `Array.wrap` returns
  # such a +nil+ right away.
  # * If the returned value from +to_ary+ is neither +nil+ nor an +Array+ object, `Kernel#Array`
  # raises an exception, while `Array.wrap` does not, it just returns the value.
  # * It does not call +to_a+ on the argument, though special-cases +nil+ to return an empty array.
  #
  # The last point is particularly worth comparing for some enumerables:
  #
  # @example It does not molest hashes
  #     Array(:foo => :bar)      # => [[:foo, :bar]]
  #     Array.wrap(:foo => :bar) # => [{:foo => :bar}]
  #
  # @example It does not do insane things to strings
  #     Array("foo\nbar")        # => ["foo\n", "bar"], in Ruby 1.8
  #     Array.wrap("foo\nbar")   # => ["foo\nbar"]
  #
  # There's also a related idiom that uses the splat operator:
  #
  #     [*object]
  #
  # which returns `[nil]` for +nil+, and calls to `Array(object)` otherwise.
  #
  # Thus, in this case the behavior is different for +nil+, and the differences with
  # `Kernel#Array` explained above apply to the rest of +object+s.
  def self.wrap(object)
    if object.nil?
      []
    elsif object.respond_to?(:to_ary)
      object.to_ary || [object]
    else
      [object]
    end
  end
end
