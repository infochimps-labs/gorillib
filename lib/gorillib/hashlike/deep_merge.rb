module Gorillib
  module Hashlike
    module DeepMerge
      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      def deep_merge(other_hash)
        dup.deep_merge!(other_hash)
      end unless method_defined?(:deep_merge)

      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      # Modifies the receiver in place.
      def deep_merge!(other_hash)
        other_hash.each_pair do |ok, ov|
          ov = convert_value(ov) if respond_to?(:convert_value)
          sv = self[ok]
          self[ok] = sv.is_a?(Hash) && ov.is_a?(Hash) ? sv.deep_merge(ov) : ov
        end
        self
      end unless method_defined?(:deep_merge!)
    end
  end
end
