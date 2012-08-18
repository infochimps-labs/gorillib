class Array
  #
  # Choose a random element from the array
  #
  def random_element
    warn "Deprecated; use built-in #sample instead"
    sample
  end unless method_defined?(:random_element)
end
