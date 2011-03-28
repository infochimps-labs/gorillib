require 'gorillib/object/blank'

class Array
  #
  # remove all key-value pairs where the value is blank
  #
  def compact_blank
    reject{|val| val.blank? }
  end unless method_defined?(:compact_blank)

  #
  # Replace the array with its compact_blank'ed self
  #
  def compact_blank!
    replace(compact_blank)
  end unless method_defined?(:compact_blank!)
end
