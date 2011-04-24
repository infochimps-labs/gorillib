Numeric.class_eval do
  def clamp min=nil, max=nil
    raise ArgumentError, "min must be <= max" if (min && max && (min > max))
    return min if min && (self < min)
    return max if max && (self > max)
    self
  end
end
