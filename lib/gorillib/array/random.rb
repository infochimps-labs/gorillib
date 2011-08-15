class Array
  #
  # Choose a random element from the array
  #
  def random_element
    self[rand(length)]
  end unless method_defined?(:random_element)
end
