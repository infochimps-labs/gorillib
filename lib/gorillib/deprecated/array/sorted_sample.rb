require 'gorillib/array/simple_statistics'

class Array

  #
  # DEPRECATED -- use #uniq_nths(num)
  # (#sample is already a method on Array, so this name is confusing)
  #
  def sorted_sample(num)
    sorted_nths(num)
  end

end
