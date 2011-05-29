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
