require 'gorillib/object/blank'
module Gorillib
  module Hashlike
    module DeepCompact

      #
      # deep_compact! removes all keys with 'blank?' values in the hash, in place, recursively
      #
      def deep_compact!
        self.each do |key, val|
          val.deep_compact! if val.respond_to?(:deep_compact!)
          self.delete(key) if val.blank?
        end
        self
      end
    end
  end
end
