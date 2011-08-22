module Gorillib
  module Hashlike
    module TreeMerge

      # Recursively merges hashlike objects
      #
      # For each key in keys,
      # * if block_given? and yield(key,self_val,other_val) returns non-nil, set that
      # * if self is missing value for key, receive the attribute.
      # * if self's attribute is an Array, append to it.
      # * if self's value responds to tree_merge!, deep merge it.
      # * if self's value responds_to merge!, merge! it.
      # * otherwise, receive the value from other_hash
      #
      def tree_merge!(other_hash)
        return self if other_hash.blank?
        [self.keys, other_hash.keys].flatten.uniq.each do |key|
          # get other's val if any
          if    other_hash.has_key?(key.to_sym) then other_val = other_hash[key.to_sym]
          elsif other_hash.has_key?(key.to_s)   then other_val = other_hash[key.to_s]
          else  next ; end
          # get self val if any
          self_val  = self[key]
          # get block resolved result if any
          if block_given? && yield(key, self_val, other_val)
            next
          end
          # p ['hash tree_merge', key, self_val.respond_to?(:tree_merge!), self_val, '***************', other_val]
          #
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
end


class Hash
  include Gorillib::Hashlike::TreeMerge
end
