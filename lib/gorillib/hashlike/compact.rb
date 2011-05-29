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
    #
    # # delete all attributes where the value is blank?, and return self. Contrast with compact!
    # def compact_blank!
    #   delete_if{|k,v| v.blank? }
    # end
    # # delete all attributes where the value is nil?, and return self. Contrast with compact_blank!
    # def compact!
    #   delete_if{|k,v| v.nil? }
    # end
    # # returns a hash with key/value pairs having nil? values removed
    # def compact
    #   to_hash.delete_if{|k,v| v.nil? }
    # end
    # # returns a hash with key/value pairs having blank? values removed
    # def compact_blank
    #   to_hash.delete_if{|k,v| v.blank? }
    # end
    #
