require 'set'
module Gorillib
  module Hashlike
    module Slice

      # Returns a copy having only the given keys
      #
      # @example limit an options hash to valid keys before passing to a method:
      #   def search(criteria = {})
      #     assert_valid_keys(:mass, :velocity, :time) # gorillib/hash/keys
      #   end
      #   search(options.slice(:mass, :velocity, :time))
      #
      # If you have an array of keys you want to limit to, splat them:
      #
      #   valid_keys = [:mass, :velocity, :time]
      #   search(options.slice(*valid_keys))
      #
      # Note: Compatible with Rails 4.0 Active Support
      #
      # @return key/value pairs for keys in self and allowed
      def slice(*allowed)
        allowed.map!{|key| convert_key(key) } if respond_to?(:convert_key, true)
        hash = self.class.new
        allowed.each{|key| hash[key] = self[key] if has_key?(key) }
        hash
      end

      # Retains only the given keys.
      # Returns a copy containing the removed key/value pairs.
      #
      # @example
      #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
      #   hsh.slice!(:a, :b)
      #   # => {:c => 3, :d =>4}
      #   hsh
      #   # => {:a => 1, :b => 2}
      #
      # @return the removed key/value pairs
      def slice!(*allowed)
        allowed.map!{|key| convert_key(key) } if respond_to?(:convert_key, true)
        omit = slice(*self.keys - allowed)
        hash = slice(*allowed)
        replace(hash)
        omit
      end

      # Removes and returns the key/value pairs matching the given keys.
      #
      # @example
      #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
      #   hsh.extract!(:a, :b)
      #   # => {:a => 1, :b => 2}
      #   hsh
      #   # => {:c => 3, :d =>4}
      #
      # @return a copy containing the removed key/value pairs
      def extract!(*allowed)
        slice!(* self.keys-allowed)
      end

    # end
    # module ExceptOnly

      # Return a copy that excludes the given keys
      #
      # @example Exclude a blacklist of parameters
      #   @person.update_attributes(params[:person].except(:admin))
      #
      # If the receiver responds to +convert_key+, the method is called on each
      # of the arguments. This allows +except+ to play nice with hashes with
      # indifferent access for instance:
      #
      # @example mash, hash, it does the right thing:
      #   {:a => 1}.to_mash.except(:a)  # => {}
      #   {:a => 1}.to_mash.except('a') # => {}
      #
      def except(*rejected)
        dup.except!(*rejected)
      end

      # Modifies the hash to exclude the given keys
      # @see #except
      #
      # @return self
      def except!(*rejected)
        rejected.each{|key| delete(key) }
        self
      end

      # Return a copy having only the given keys
      #
      # @example Limit a set of parameters to everything but a few known toggles:
      #   { :one => 1, :two => 2, :three => 3 }.only(:one)    #=> { :one => 1 }
      #
      # @param [#include?] allowed keys to include.
      #
      # @return [Hash] a copy with only the selected keys.
      def only(*allowed)
        dup.only!(*allowed)
      end

      # Retain only the given keys; return self
      #
      # @example Limit a set of parameters to everything but a few known toggles:
      #   { :one => 1, :two => 2, :three => 3 }.only!(:one)    #=> { :one => 1 }
      #
      # @param [#include?] allowed keys to include.
      #
      # @return self
      def only!(*allowed)
        allowed.map!{|key| convert_key(key) } if respond_to?(:convert_key, true)
        keep_if{|key, val| allowed.include?(key) }
      end

    end
  end
end
