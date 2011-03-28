require 'gorillib/object/blank'

class Hash
  #
  # remove all key-value pairs where the value is nil
  #
  def compact
    reject{|key,val| val.nil? }
  end unless method_defined?(:compact)

  #
  # Replace the hash with its compacted self
  #
  def compact!
    replace(compact)
  end unless method_defined?(:compact!)

  #
  # remove all key-value pairs where the value is blank
  #
  def compact_blank
    reject{|key,val| val.blank? }
  end unless method_defined?(:compact_blank)

  #
  # Replace the hash with its compact_blank'ed self
  #
  def compact_blank!
    replace(compact_blank)
  end unless method_defined?(:compact_blank!)
end
