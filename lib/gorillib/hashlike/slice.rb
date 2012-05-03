module Gorillib
  module Hashlike
    module Slice
      # Slice a hash to include only the given allowed_keys.
      #
      # @return the sliced hash
      #
      # @example limit an options hash to valid keys before passing to a method:
      #   def search(criteria = {})
      #     assert_valid_keys(:mass, :velocity, :time)
      #   end
      #   search(options.slice(:mass, :velocity, :time))
      #
      # If you have an array of keys you want to limit to, you should splat them:
      #
      #   valid_keys = [:mass, :velocity, :time]
      #   search(options.slice(*valid_keys))
      def slice(*allowed_keys)
        allowed_keys = allowed_keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
        hash = self.class.new
        allowed_keys.each{|k| hash[k] = self[k] if has_key?(k) }
        hash
      end unless method_defined?(:slice)

      # Replace the hash with only the given allowed_keys.
      #
      # @return a hash containing the removed key/value pairs
      #
      # @example
      #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
      #   hsh.slice!(:a, :b)
      #   # => {:c => 3, :d =>4}
      #   hsh
      #   # => {:a => 1, :b => 2}
      def slice!(*allowed_keys)
        allowed_keys = allowed_keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
        omit = slice(*self.keys - allowed_keys)
        hash = slice(*allowed_keys)
        replace(hash)
        omit
      end unless method_defined?(:slice!)

      # Removes the given allowed_keys from the hash
      #
      # @return a hash containing the removed key/value pairs
      #
      # @example
      #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
      #   hsh.extract!(:a, :b)
      #   # => {:a => 1, :b => 2}
      #   hsh
      #   # => {:c => 3, :d =>4}
      def extract!(*allowed_keys)
        slice!(*self.keys - allowed_keys)
      end unless method_defined?(:extract!)

      # Return a hash that includes everything but the given keys.
      #
      # @example Exclude a blacklist of parameters
      #   @person.update_attributes(params[:person].except(:admin))
      #
      # If the receiver responds to +convert_key+, the method is called on each of the
      # arguments. This allows +except+ to play nice with hashes with indifferent access
      # for instance:
      #
      # @example mash, hash, it does the right thing:
      #   {:a => 1}.to_mash.except(:a)  # => {}
      #   {:a => 1}.to_mash.except('a') # => {}
      #
      def except(*keys)
        dup.except!(*keys)
      end

      # Replaces the hash without the given keys.
      def except!(*keys)
        keys.each{|key| delete(key) }
        self
      end

      def only(*allowed)
        dup.only!(*allowed)
      end

      # Create a hash with *only* key/value pairs in receiver and +allowed+
      #
      # @example Limit a set of parameters to everything but a few known toggles:
      #   { :one => 1, :two => 2, :three => 3 }.only(:one)    #=> { :one => 1 }
      #
      # @param [Array[String, Symbol]] *allowed The hash keys to include.
      #
      # @return [Hash] A new hash with only the selected keys.
      #
      # @api public
      def only!(*allowed)
        allowed = allowed.to_set
        select!{|key, val| allowed.include?(key) }
      end

    end
  end
end
