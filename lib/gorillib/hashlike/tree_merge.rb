module Gorillib
  module Hashlike
    module TreeMerge

      # Recursively merges using receive
      #
      # Modifies the full receiver chain in-place.
      #
      # For each key in keys,
      # * if self's value is nil, receive the attribute.
      # * if self's attribute is an Array, append to it.
      # * if self's value responds to tree_merge!, tree merge it.
      # * if self's value responds_to merge!, merge! it.
      # * otherwise, receive the value from other_hash
      #
      def tree_merge!(other_hash)
        keys.each do |key|
          # get other's val if any
          if    other_hash.has_key?(key.to_sym) then other_val = other_hash[key.to_sym]
          elsif other_hash.has_key?(key.to_s)   then other_val = other_hash[key.to_s]
          else  next ; end
          #
          self_val  = self[key]
          # p ['receiver tree_merge', key, self_val.respond_to?(:tree_merge!), self[key], other_val]
          case
          when other_val.nil?                     then next
          when (not has_key?(key))                then _receive_attr(key, other_val)
          when receiver_attrs[key][:merge_as] == :hash_of_arrays
            self_val.merge!(other_val) do |k, v1, v2| case when v1.blank? then v2 when v2.blank? then v1 else v1 + v2 end end
          when self_val.is_a?(Array)              then self[key] += other_val
          when self_val.respond_to?(:tree_merge!) then self[key] = self_val.tree_merge!(other_val)
          when self_val.respond_to?(:merge!)      then self[key] = self_val.merge!(other_val)
          else                                         _receive_attr(key, other_val)
          end
        end
        run_after_receivers(other_hash)
        self
      end

    end
  end

  class Hash
    # Recursively merges using receive
    #
    # Modifies the full receiver chain in-place.
    #
    # For each key in keys,
    # * if self's value is nil, receive the attribute.
    # * if self's attribute is an Array, append to it.
    # * if self's value responds to tree_merge!, deep merge it.
    # * if self's value responds_to merge!, merge! it.
    # * otherwise, receive the value from other_hash
    #
    def tree_merge!(other_hash)
      [self.keys, other_hash.keys].flatten.uniq.each do |key|
        # get other's val if any
        if    other_hash.has_key?(key.to_sym) then other_val = other_hash[key.to_sym]
        elsif other_hash.has_key?(key.to_s)   then other_val = other_hash[key.to_s]
        else  next ; end
        #
        self_val  = self[key]
        # p ['hash tree_merge', key, self_val.respond_to?(:tree_merge!), self_val, other_val]
        case
        when other_val.nil?                     then next
        when (not has_key?(key))                then self[key] = other_val
        when self_val.is_a?(Array)              then self[key] += other_val
        when self_val.respond_to?(:tree_merge!) then self[key] = self_val.tree_merge!(other_val)
        when self_val.respond_to?(:merge!)      then self[key] = self_val.merge!(other_val)
        else                                         self[key] = other_val
        end
      end
      self
    end
  end
end
