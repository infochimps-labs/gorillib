Numeric.class_eval do
  #
  # Coerce a number to lie between min and max.
  #
  # @example
  #   5.clamp(6, 7)     # => 6
  #   5.clamp(6)        # => 6
  #   5.clamp(nil, 6)   # => 5
  #   5.clamp(nil, 4)   # => 4
  #
  def clamp min=nil, max=nil
    raise ArgumentError, "min must be <= max" if (min && max && (min > max))
    return min if min && (self < min)
    return max if max && (self > max)
    self
  end
end
