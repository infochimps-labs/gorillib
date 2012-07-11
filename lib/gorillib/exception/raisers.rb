Exception.class_eval do
  # @return [Array] __FILE__, __LINE__, description
  def self.caller_parts
    caller_line = caller[1]
    mg = %r{\A([^:]+):(\d+):in \`([^\']+)\'\z}.match(caller_line) or return [caller_line, 1, 'unknown']
    [mg[1], mg[2].to_i, mg[3]]
  end

  #
  # @note !! Be sure to rescue the call to this method; few things suck worse than debugging your rescue blocks/
  def polish(extra_info)
    filename, _, method_name = self.class.caller_parts
    method_name.gsub!(/rescue in /, '')
    most_recent_line = backtrace.detect{|line| line.include?(filename) && line.include?(method_name) && line[-1] == "'" }
    most_recent_line.sub!(/'$/, "' for [#{extra_info.to_s[0..300]}]")
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
  def self.check_arity!(args, val, &block)
    allowed_arity = val.is_a?(Integer) ? (val..val) : val
    return true if allowed_arity.include?(args.length)
    info = " #{block.call}" rescue nil if block_given?
    raise self.new("wrong number of arguments (#{args.length} for #{val})#{info}")
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
