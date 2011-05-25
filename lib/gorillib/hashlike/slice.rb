    end

    # ===========================================================================

    #
    # Return a Hash containing only values for the given keys where self.has_key?(k)
    #
    def slice *allowed_keys
      allowed_keys.inject({}){|h,k| h[k] = self[k] if self.has_key?(k) ; h }
    end

    # delete all attributes where the value is blank?, and return self. Contrast with compact!
    def compact_blank!
      delete_if{|k,v| v.blank? }
    end
    # delete all attributes where the value is nil?, and return self. Contrast with compact_blank!
    def compact!
      delete_if{|k,v| v.nil? }
    end
    # returns a hash with key/value pairs having nil? values removed
    def compact
      to_hash.delete_if{|k,v| v.nil? }
    end
    # returns a hash with key/value pairs having blank? values removed
    def compact_blank
      to_hash.delete_if{|k,v| v.blank? }
    end

    # @return [Hash] the object as a Hash with symbolized keys.
    def symbolize_keys() to_hash ; end
    # @return [Hash] the object as a Hash with string keys.
    def stringify_keys() to_hash.stringify_keys ; end

    # Used to provide the same interface as Hash.
    # @return This object unchanged.
    def symbolize_keys!; self end

    # Used to provide the same interface as Hash.
    # @return This object unchanged.
    def stringify_keys!; self end

    # # Returns a new hash with +self+ and +other_hash+ merged recursively.
    # def deep_merge(other_hash)
    #   dup.deep_merge!(other_hash)
    # end
