module Receiver

  #
  # Makes a Receiver thingie behave mostly like a hash.
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
  # All methods are defined naturally on [], []= and has_key? -- if you enjoy
  #
  #
  # in addition to the below, by including Enumerable, this also adds
  #
  #    #all?, #any?, #chunk, #collect, #collect_concat, #count, #cycle, #detect,
  #    #drop, #drop_while, #each_cons, #each_entry, #each_slice,
  #    #each_with_index, #each_with_object, #entries, #find, #find_all,
  #    #find_index, #first, #flat_map, #grep, #group_by, #inject, #map, #max,
  #    #max_by, #min, #min_by, #minmax, #minmax_by, #none?, #one?, #partition,
  #    #reduce, #reverse_each, #slice_before, #sort, #sort_by, #take,
  #    #take_while, #zip
  #
  # As opposed to hash, does *not* define
  #
  #   default, default=, default_proc, default_proc=, shift
  #   length, size, empty?, flatten, replace, keep_if, key(value)
  #   compare_by_identity compare_by_identity? rehash, select!
  #
  #   assoc rassoc
  #
  module ActsAsHash

    # Fake hash reader semantics: delegates to self.send(key)
    #
    # Note: indifferent access -- either of :foo or "foo" will work
    #
    def [](name)
      self.send(name) if keys.include?(name.to_sym)
    end

    # Fake hash writer semantics: delegates to self.send("key=", val)
    #
    # NOTE: this calls self.foo= 5, not self.receive_foo(5)
    # NOTE: indifferent access -- either of :foo or "foo" will work
    #
    def []=(name, val)
      self.send("#{name}=", val) if keys.include?(name)
    end
    alias_method(:store, :[]=)

    # @param key<Object> The key to check for.
    #
    # @return [Boolean] True if
    #   * the attribute is one of this object's keys, and
    #   * its value is non-nil OR the corresponding instance_variable is defined.
    #
    # For attributes that are virtual accessors, if its value is explicitly set
    # to nil then has_key? is true.
    #
    # @example
    #    class Foo
    #      include Receiver
    #      include Receiver::ActsAsHash
    #      rcvr_accessor :a, Integer
    #      rcvr_accessor :b, String
    #    end
    #    foo = Foo.receive({:a => 1})
    #    foo.has_key?(:b)               # false
    #    foo[:b]                        # nil
    #    foo.b = nil
    #    foo.has_key?(:b)               # true
    #    foo[:b]                        # nil
    #
    def has_key?(key)
      keys.include?(key) && ((not self[key].nil?) || attr_set?(key))
    end

    # @param key<Object> The key to remove
    #
    # @return [Object]
    #   returns the value of the given attribute, and sets its new value to nil.
    #   If there is a corresponding instance_variable, it is subsequently removed.
    def delete(key)
      val = self[key]
      self[key]= nil
      unset!(key)
      val
    end

    #
    # Convert to a hash
    #
    # Each key in #keys becomes an element in the new array if the value of its
    # attribute is non-nil OR the corresponding instance_variable is defined.
    def to_hash
      keys.inject({}) do |hsh, key|
        val = self[key]
        hsh[key] = val if (val || self.instance_variable_defined?("@#{key}"))
        hsh
      end
    end

    module ClassMethods
      # By default, the hashlike methods iterate over the receiver attributes.
      # If you want to filter our add to the keys list, override this method
      #
      # @example
      #     def self.keys
      #       super + [:firstname, :lastname] - [:fullname]
      #     end
      #
      def keys
        receiver_attr_names
      end
    end

    # ===========================================================================
    #
    # The below methods are natural extensions of the above
    #

    # delegates to the class method. Typically you'll want to override that one,
    # not the instance keys
    def keys
      self.class.keys
    end

    # Returns an array consisting of the value for each attribute in
    # #keys, guaranteed in same order
    def values
      values_at *keys
    end unless method_defined?(:values)

    # Returns an array consisting of the value for each attribute in
    # allowed_keys, guaranteed in same order
    def values_at *allowed_keys
      allowed_keys.map do |k|
        self[k]
      end
    end

    # a nested array of [ key, value ] pairs. Delegates to to_hash.to_a
    def to_a
      to_hash.to_a
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

    #
    # Return a Hash containing only values for the given keys where self.has_key?(k)
    #
    def slice *allowed_keys
      allowed_keys.inject({}){|h,k| h[k] = self[k] if self.has_key?(k) ; h }
    end

    # Calls block once for each key in #keys in order, passing the key and value as parameters.
    def each &block
      keys.each do |key|
        yield(key, self[key])
      end
    end
    alias_method :each_pair, :each

    # Calls block once for each key in #keys in order, passing the key as parameter.
    def each_key &block
      keys.each(&block)
    end

    # Calls block once for each key in #keys in order, passing the value as parameter.
    def each_value &block
      keys.each do |key|
        yield self[key]
      end
    end

    #
    # Analogous to Hash#merge: returns a duplicate of self where for each
    # element of self.keys, adopts the corresponding element of hsh if that key
    # is set in hsh.
    #
    # Returns a duplicate of self, but adopting the corresponding element of hsh
    # if that key is set in hsh. Only keys in self.keys are candidates for merging.
    #
    # With no block parameter, overwrites entries in hsh with duplicate keys
    # with those from other_hash.
    #
    # The block parameter semantics aren't implemented yet. If a block is
    # specified, it is called with each duplicate key and the values from the
    # two hashes. The value returned by the block is stored in the new hash.
    #
    # @example
    #   h1 = { "a" => 100, "b" => 200 }
    #   h2 = { "b" => 254, "c" => 300 }
    #   h1.merge(h2)                 -> {"a"=>100, "b"=>254, "c"=>300}
    #   h1.merge(h2){|k,o,n| o}      -> {"a"=>100, "b"=>200, "c"=>300}
    #   h1                           -> {"a"=>100, "b"=>200}
    #
    def merge *args, &block
      self.dup.merge!(*args, &block)
    end

    # For all keys that are in self.keys *and* other_hash.has_key?(key),
    # sets the value to that from other_hash
    #
    def update other_hash, &block
      raise "can't handle block arg yet" if block
      keys.each do |key|
        self[key] = other_hash[key] if other_hash.has_key?(key)
      end
      self
    end
    alias_method :merge!, :update

    # # Returns a new hash with +self+ and +other_hash+ merged recursively.
    # def deep_merge(other_hash)
    #   dup.deep_merge!(other_hash)
    # end

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

    # Searches the hash for an entry whose value == value, returning the
    # corresponding key. If multiple entries has this value, the key returned
    # will be that on one of the entries. If not found,returns nil.
    #
    # You are guaranteed that the first matching key in #keys will be the one
    # returned.
    #
    # @example
    #   foo = Foo.receive( "a" => 100, "b" => 200, "c" => 100 )
    #   foo.index(100) -> "a"
    #   foo.index(999) -> nil
    #
    def index val
      keys.find{|key| self[key] == val }
    end

    # Returns a new hash created by using inverting self.to_hash. If this new
    # hash has duplicate values, the result will contain only one of them as a
    # key -- which one is not predictable.
    def invert
      to_hash.invert
    end

    # Returns true if the given value is present for some attribute in #keys
    def has_value? val
      !! index(val)
    end
    alias_method :value?, :has_value?

    # def include? def key? def member?
    alias_method :include?, :has_key?
    alias_method :key?,     :has_key?
    alias_method :member?,  :has_key?

    # Deletes every attribute for which block is true.
    # Returns nil if no changes were made, self otherwise.
    def reject!(&block)
      changed = false
      each do |key, val|
        if yield(key, val)
          changed = true
          delete(key)
        end
      end
      changed ? self : nil
    end

    # Deletes every attribute for which block is true.
    # Similar to reject! but returns self.
    def delete_if(&block)
      reject!(&block)
      self
    end

    # Deletes every attribute for which block is true.
    # Equivalent to self.dup.delete_if.
    def reject(&block)
      self.dup.delete_if(&block)
    end

    # deletes all attributes
    def clear
      each_key{|k| delete(k) }
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

    def self.included base
      base.class_eval do
        extend  ClassMethods
        include Enumerable
      end
    end

    #
    # Not yet implemented
    #

    # # Returns true if has_key? is false for all attributes in #keys
    # def empty?
    #   keys.all?{|key| not has_key?(key) }
    # end
    #
    # # The number of keys where #has_key is true
    # def length
    #   keys.select{|key| has_key?(key) }.length
    # end
    # alias_method :size, :length

    # # @param key<Object> The key to fetch.
    # # @param *extras<Array> Default value.
    # #
    # # Returns a value for the given key. If the object doesn't has_key?(key),
    # # several options exist:
    # #
    # # * With no other arguments, it will raise an IndexError exception;
    # # * if default is given, then that will be returned;
    # # * if the optional code block is specified, then that will be run and its
    # #   result returned.
    # #
    # # fetch does not evaluate any default values supplied when
    # # the hash was created -- it only looks for keys in the hash.
    # #
    # # @return [Object] The value at key or the default value.
    # def fetch(key, default=nil, &block)
    #   raise ""
    # end


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

    def compact_blank!
      reject!{|k,v| v.blank? } ; self
    end

end
