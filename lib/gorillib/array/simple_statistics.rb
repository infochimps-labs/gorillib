class Array

  #
  # The average of my elements.
  # precondition: Each element must be convertible to a float.
  #
  # @return [Float] average of all elements
  def average
    return nil if empty?
    inject(:+) / size.to_f
  end

  #
  # @return the element that fraction of the way along the indexes
  #
  # @example halfway point:
  #   [1,4,9,16,25].at_fraction(0.5)      #  9
  #
  # @example note that indexes are rounded down:
  #   [1,4,9,16,25].at_fraction(0.74999)  #  9
  #   [1,4,9,16,25].at_fraction(0.75)     # 16
  #
  # @example blank array:
  #   [].at_fraction(0.1)       # nil
  #
  def at_fraction(fraction)
    raise ArgumentError, "fraction should be between 0.0 and 1.0: got #{fraction.inspect}" unless (0.0 .. 1.0).include?(fraction)
    return nil if empty?
    self[ ((size - 1) * Float(fraction)).round ]
  end

  #
  # @return the 1/nth, 2/nth, ... n/nth (last) elements in the array.
  #
  # @example
  #   [1,4,9,16,25,36,49].take_nths(3)  # [4, 16, 36]
  #   [ 4,9,  16,  36,49].take_nths(3)  # [4, 16, 36]
  #   [1,4,9,16,25,36,49].take_nths(5)  # [1, 4, 16, 25, 36]
  #
  # @example edge cases
  #   [1,4,9,16,25,36,49].take_nths(99) # [1,4,9,16,25,36,49]
  #   [1,4,9,16,25,36,49].take_nths(1)  # [16]
  #   [1,4,9,16,25,36,49].take_nths(0)  # []
  #   [].take_nths(3)                   # []
  #
  # The array must be sorted for this to be useful.
  #
  def take_nths(num)
    return [] if empty?
    (0 .. num-1).map{|step| at_fraction( (step + 0.5)/(num)) }.uniq
  end

  #
  # Returns the middle element of odd-sized arrays. For even arrays,
  # it will return one of the two middle elements. Precisely which is
  # undefined, except that it will consistently return one or the
  # other.
  #
  # The array must be sorted for this to be useful.
  #
  def sorted_median
    at_fraction(0.5)
  end

  #
  # Returns the element at the position closest to the given
  # percentile. For example, sorted_percentile 0.0 will return the
  # first element and sorted_percentile 100.0 will return the last
  # element.
  #
  # The array must be sorted for this to be useful.
  #
  def sorted_percentile(percentile)
    at_fraction(percentile / 100.0)
  end
end
