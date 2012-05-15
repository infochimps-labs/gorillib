Exception.class_eval do
  def self.caller_parts
    p caller[1]
    mg = %r{\A([^:]+):(\d+):in \`([^\']+)\'\z}.match(caller[1]) or return [caller[1], 1, 'unknown']
    [mg[1], mg[2].to_i, mg[3]]
  end
end

ArgumentError.class_eval do
  # Raise an error just like Ruby's native message if the array of arguments
  # doesn't match the expected length or range of lengths.
  #
  # @example want `getset(:foo)` to be different from `getset(:foo, nil)`
  #   def getset(key, *args)
  #     ArgumentError.check_arity!(args, 0..1)
  #     return self[key] if args.empty?
  #     self[key] = args.first
  #   end
  #
  # @overload check_arity!(args, n)
  #   @param [Array]     args splat args as handed to the caller
  #   @param [Integer]   val  expected length
  # @overload check_arity!(args, x..y)
  #   @param [Array]     args splat args as handed to the caller
  #   @param [#include?] val  expected range/list/set of lengths
  # @raise ArgumentError when there are
  def self.check_arity!(args, val)
    allowed_arity = val.is_a?(Integer) ? (val..val) : val
    return true if allowed_arity.include?(args.length)
    raise self.new("wrong number of arguments (#{args.length} for #{val})")
  end

  # Raise an error just like Ruby's native message if there are fewer arguments
  # than expected
  #
  # @example want to use splat args, requiring at least one
  #   def assemble_path(*pathsegs)
  #     ArgumentError.arity_at_least!(pathsegs, 1)
  #     # ...
  #   end
  #
  # @param [Array]     args splat args as handed to the caller
  # @param [Integer]   val  minimum expected length
  def self.arity_at_least!(args, min_arity)
    check_arity!(args, min_arity .. Float::INFINITY)
  end
end

NoMethodError.class_eval do
  MESSAGE = "undefined method `%s' for %s:%s"

  def self.undefined_method(obj)
    file, line, meth = caller_parts
    self.new(MESSAGE % [meth, obj, obj.class])
  end

  def self.unimplemented_method(obj)
    file, line, meth = caller_parts
    self.new("#{MESSAGE} -- not implemented yet" % [meth, obj, obj.class])
  end

  def self.abstract(obj)
    file, line, meth = caller_parts
    self.new("#{MESSAGE} -- must be implemented by the subclass" % [meth, obj, obj.class])
  end

end
