class Array
  #
  # Return the average of my elements.
  #
  # precondition: Each element must be convertible to a float.
  #
  def average
    return nil if empty?
    raise ArgumentError, "Couldn't convert all elements to float!" unless
      all?{|e| e.methods.index :to_f}
    return map(&:to_f).inject(:+) / size
  end
end
