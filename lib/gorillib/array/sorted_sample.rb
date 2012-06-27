class Array
  #
  # Returns the middle element of odd-sized arrays. For even arrays,
  # it will return one of the two middle elements. Precisely which is
  # undefined, except that it will consistently return one or the
  # other.
  #
  def sorted_sample num
    return [] if empty?
    (1..num).map{|i| self[(size - 1) * i / (num)]}.uniq
  end
end
