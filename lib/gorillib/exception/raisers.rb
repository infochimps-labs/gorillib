Exception.class_eval do
  # @return [Array] file, line, method_name
  def self.caller_parts(depth=1)
    caller_line = caller(depth).first
    mg = %r{\A([^:]+):(\d+):in \`([^\']+)\'\z}.match(caller_line) or return [caller_line, 1, '(unknown)']
    [mg[1], mg[2].to_i, mg[3]]
  rescue
    warn "problem in #{self}.caller_parts"
    return [__FILE__, __LINE__, '(unknown)']
  end

  #
  # Add context to the backtrace of exceptions ocurring downstream from caller.
  # This is expecially useful in metaprogramming. Follow the implementation in
  # the example.
  #
  # @note !! Be sure to rescue the call to this method; few things suck worse
  # than debugging your rescue blocks.
  #
  # @example
  #   define_method(:cromulate) do |level|
  #     begin
  #       adjust_cromulance(cromulator, level)
  #     rescue StandardError => err ; err.polish("setting cromulance #{level} for #{cromulator}") rescue nil ; raise ; end
  #   end
  #
  def polish(extra_info)
    filename, _, method_name = self.class.caller_parts(2)
    method_name.gsub!(/rescue in /, '')
    most_recent_line = backtrace.detect{|line|
      line.include?(filename) && line.include?(method_name) && line.end_with?("'") }
    most_recent_line.sub!(/'$/, "' for [#{extra_info.to_s[0..300]}]")
  end

end

ArgumentError.class_eval do
  # Raise an error if there are a different number of arguments than expected.
  # The message will have the same format used by Ruby internal methods.
  # @see #arity_at_least!
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

  # Raise an error if there are fewer arguments than expected.  The message will
  # have the same format used by Ruby internal methods.
  # @see #check_arity!
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

class TypeMismatchError < ArgumentError ; end

class ArgumentError
  #
  # @param [Array[Symbol,Class,Module]] types
  #
  # @example simple
  #   TypeMismatchError.mismatched!(:foo)
  #     #=> "TypeMismatchError: :foo has mismatched type
  #
  # @example Can supply the types or duck-types that are expected:
  #   TypeMismatchError.mismatched!(:foo, [:to_str, Integer])
  #     #=> "TypeMismatchError: :foo has mismatched type; expected #to_str or Integer"
  #
  def self.mismatched!(obj, types=[], msg=nil, *args)
    types = Array(types)
    message = (obj.inspect rescue '(uninspectable object)')
    message << " has mismatched type"
    message << ': ' << msg if msg
    unless types.empty?
      message << '; expected ' << types.map{|type| type.is_a?(Symbol) ? "##{type}" : type.to_s }.join(" or ")
    end
    raise self, message, *args
  end


  def self.block_required!(block)
    raise self.new("Block is required") unless block
  end

  #
  # @param obj    [Object] Object to check
  # @param types  [Array[Symbol,Class,Module]] Types or methods to compare
  #
  # @example simple
  #   TypeMismatchError.mismatched!(:foo)
  #     #=> "TypeMismatchError: :foo has mismatched type
  #
  # @example Can supply the types or duck-types that are expected:
  #   TypeMismatchError.mismatched!(:foo, [:to_str, Integer])
  #     #=> "TypeMismatchError: :foo has mismatched type; expected #to_str or Integer"
  #
  def self.check_type!(obj, types, *args)
    types = Array(types)
    return true if types.any? do |type|
      case type
      when Module then obj.is_a?(type)
      when Symbol then obj.respond_to?(type)
      else raise StandardError, "Can't check type #{type} -- this is an error in the call to the type-checker, not in the object the type-checker is checking"
      end
    end
    self.mismatched!(obj, types, *args)
  end

end

#
class AbstractMethodError      < NoMethodError ; end

NoMethodError.class_eval do
  MESSAGE_FMT = "undefined method `%s' for %s:%s"

  # Raise an error with the same format used by Ruby internal methods
  def self.undefined_method!(obj)
    file, line, meth = caller_parts
    raise self.new(MESSAGE_FMT % [meth, obj, obj.class])
  end

  def self.abstract_method!(obj)
    file, line, meth = caller_parts
    raise AbstractMethodError.new("#{MESSAGE} -- must be implemented by the subclass" % [meth, obj, obj.class])
  end

end
