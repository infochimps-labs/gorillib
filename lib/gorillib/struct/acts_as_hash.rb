module Gorillib
  module Struct
    #
    # Make a Struct behave mostly like a hash.
    #
    # By default, the hashlike methods iterate over the receiver attributes:
    # instance #keys delegates to self.class.keys which calls
    # receiver_attr_names. If you want to filter our add to the keys list, you
    # can just override the class-level keys method (and call super, or not):
    #
    #     def self.keys
    #       super + [:firstname, :lastname] - [:fullname]
    #     end
    #
    # in addition to the below, by including Enumerable, this also adds
    #
    #     :each_cons, :each_entry, :each_slice, :each_with_index, :each_with_object,
    #     :map, :collect, :collect_concat, :entries, :to_a, :flat_map, :inject, :reduce,
    #     :group_by, :chunk, :cycle, :partition, :reverse_each, :slice_before, :drop,
    #     :drop_while, :take, :take_while, :detect, :find, :find_all, :find_index, :grep,
    #     :all?, :any?, :none?, :one?, :first, :count, :zip :max, :max_by, :min, :min_by,
    #     :minmax, :minmax_by, :sort, :sort_by
    #
    # As opposed to hash, does *not* define
    #
    #   default, default=, default_proc, default_proc=, shift, flatten, compare_by_identity
    #   compare_by_identity? rehash
    #
    # @example
    #   StructUsingHashlike = Struct.new(:a, :b, :c, :z) do
    #     include Gorillib::Struct::ActsAsHash
    #     include Gorillib::Hashlike
    #   end
    #   foo = StructUsingHashlike.new(1,2,3)
    #   foo.to_hash  # => { :a => 1, :b => 2, :c => 3, :z => nil }
    #
    module ActsAsHash

      # Hashlike#delete
      #
      # Deletes and returns the value from +hsh+ whose key is equal to +key+. If the
      # optional code block is given and the key is not found, pass in the key and
      # return the result of +block+.
      #
      # In a normal hash, a default value can be set; none is provided here.
      #
      # @example
      #     hsh = { :a => 100, :b => 200 }
      #     hsh.delete(:a)                            # => 100
      #     hsh.delete(:z)                            # => nil
      #     hsh.delete(:z){|el| "#{el} not found" }   # => "z not found"
      #
      # @overload hsh.delete(key)                  -> val
      #   @param  key [Object] key to remove
      #   @return [Object, Nil] the removed object, nil if missing
      #
      # @overload hsh.delete(key){|key| block }    -> val
      #   @param  key [Object] key to remove
      #   @yield  [Object] called (with key) if key is missing
      #   @yieldparam key
      #   @return [Object, Nil] the removed object, or if missing, the return value
      #     of the block
      #
      def delete(key, &block)
        if has_key?(key)
          val = self[key]
          self[key] = nil
          self.send(:remove_instance_variable, "@#{key}") if instance_variables.include?("@#{key}")
          val
        elsif block_given?
          block.call(key)
        else
          nil
        end
      end

      # Hashlike#keys
      #
      # Returns a new array populated with the keys from this hashlike.
      #
      # @see Hashlike#values.
      #
      # @example
      #     hsh = { :a => 100, :b => 200, :c => 300, :d => 400 }
      #     hsh.keys   # => [:a, :b, :c, :d]
      #
      # @return [Array] list of keys
      #
      def keys
        members # .select{|k| not self[k].nil? }
      end

      def convert_key(key)
        return unless key.respond_to?(:to_sym)
        key.to_sym
      end

      def size
        length
      end

    end
  end
end
