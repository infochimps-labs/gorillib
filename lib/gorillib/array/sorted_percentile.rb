class Array
  #
  # Returns the element at the position closest to the given
  # percentile. For example, sorted_percentile 0.0 will return the
  # first element and sorted_percentile 100.0 will return the last
  # element.
  #
  def sorted_percentile percentile
    return self[(size - 1) * percentile / 100.0]
  end
end
