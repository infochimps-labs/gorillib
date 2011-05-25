module Gorillib
  module Hashlike

    # ===========================================================================
    #
    # The below methods are natural extensions of the above
    #

    # Calls block once for each key in #keys in order, passing the key and value as parameters.
    def each
      return enum_for(:each) unless block_given?
      keys.each do |key|
        yield(key, self[key])
      end
      self
    end
    alias_method :each_pair, :each

    # Calls block once for each key in #keys in order, passing the key as parameter.
    def each_key
      return enum_for(:each_key) unless block_given?
      keys.each{|k| yield k }
      self
    end

    # Calls block once for each key in #keys in order, passing the value as parameter.
    def each_value &block
      return enum_for(:each_value) unless block_given?
      each{|k,v| yield v }
      self
    end

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
      keys.include?(key)
    end

    # Returns true if the given value is present for some attribute in #keys
    def has_value? val
      !! key(val)
    end
    alias_method :value?, :has_value?

    # def include? def key? def member?
    alias_method :include?, :has_key?
    alias_method :key?,     :has_key?
    alias_method :member?,  :has_key?

    # @param key<Object> The key to fetch.
    # @param *extras<Array> Default value.
    #
    # Returns a value for the given key. If the object doesn't has_key?(key),
    # several options exist:
    #
    # * With no other arguments, it will raise a KeyError exception;
    # * if default is given, then that will be returned;
    # * if the optional code block is specified, then that will be run and its
    #   result returned.
    #
    # fetch does not evaluate any default values supplied when
    # the hash was created -- it only looks for keys in the hash.
    #
    # @return [Object] The value at key or the default value.
    def fetch(key, default=nil, &block)
      if    has_key?(key) then self[key]
      elsif default       then default
      elsif block_given?  then yield(key)
      else  raise KeyError, "key not found: #{key.inspect}"
      end
    end

    # The number of keys where #has_key is true
    def length
      keys.length
    end
    alias_method :size, :length

    # Returns true if has_key? is false for all attributes in #keys
    def empty?
      keys.empty?
    end

    #
    # Convert to a hash
    #
    # Each key in #keys becomes an element in the new array if the value of its
    # attribute is non-nil OR the corresponding instance_variable is defined.
    def to_hash
      {}.tap{|hsh| each{|key, val| hsh[key] = val } }
    end

    # # a nested array of [ key, value ] pairs. Delegates to to_hash.to_a
    # def to_a
    #   [].tap{|arr| each{|key, val| arr << [key, val] } }
    # end

    # Returns an array consisting of the value for each attribute in
    # #keys, guaranteed in same order
    def values
      [].tap{|arr| each{|key, val| arr << val } }
    end unless method_defined?(:values)

    # Returns an array consisting of the value for each attribute in
    # allowed_keys, guaranteed in same order
    def values_at *allowed_keys
      allowed_keys.map{|key| self[key] if has_key?(key) }
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
      other_hash.each do |key, val|
        if block_given? && has_key?(key)
          val = yield(key, val, self[key])
        end
        self[other_key] = val
      end
      self
    end
    alias_method :merge!, :update

    # Searches the hash for an entry whose value == value, returning the
    # corresponding key. If multiple entries has this value, the key returned
    # will be that on one of the entries. If not found,returns nil.
    #
    # You are guaranteed that the first matching key in #keys will be the one
    # returned.
    #
    # @example
    #   foo = Foo.receive( "a" => 100, "b" => 200, "c" => 100 )
    #   foo.key(100) -> "a"
    #   foo.key(999) -> nil
    #
    def key val
      keys.find{|key| self[key] == val }
    end

    # Searches through the hash comparing obj with the key using ==.
    # Returns the key-value pair (two elements array) or nil if no match is
    # found.  See Array#assoc.
    #
    # @param  obj [Object] object to look up
    # @return [Array, nil]
    #
    # @example
    #     h = {"colors"  => ["red", "blue", "green"],
    #          "letters" => ["a", "b", "c" ]}
    #     h.assoc("letters")  #=> ["letters", ["a", "b", "c"]]
    #     h.assoc("foo")      #=> nil
    #
    def assoc key
      [key, self[key]]
    end

    # Searches through the hash comparing obj with the value using ==.
    # Returns the first key-value pair (two-element array) that
    # matches. See also Array#rassoc.
    #
    # @param  obj [Object] object to look up
    # @return [Array, nil]
    #
    # @example
    #     a = {1=> "one", 2 => "two", 3 => "three", "ii" => "two"}
    #     a.rassoc("two")    #=> [2, "two"]
    #     a.rassoc("four")   #=> nil
    def rassoc val
      key = key(val)
      [key, self[key]]
    end

    # Returns a new hash created by inverting self.to_hash. If this new hash has
    # duplicate values, the result will contain only one of them as a key --
    # which one is not predictable.
    def invert
      to_hash.invert
    end

    # Deletes every attribute for which block is true.
    # Returns nil if no changes were made, self otherwise.
    def reject!
      return enum_for(:reject!) unless block_given?
      changed = false
      each do |key, val|
        if yield(key, val)
          changed = true
          delete(key)
        end
      end
      changed ? self : nil
    end

    # Deletes every attribute for which block is false.
    # Returns nil if no changes were made, self otherwise.
    def select!
      return enum_for(:select!) unless block_given?
      changed = false
      each do |key, val|
        if not yield(key, val)
          changed = true
          delete(key)
        end
      end
      changed ? self : nil
    end

    # Deletes every attribute for which block is true.
    # Similar to reject! but returns self.
    def delete_if(&block)
      return enum_for(:delete_if) unless block_given?
      reject!(&block)
      self
    end

    # Deletes every attribute for which block is false.
    # Similar to select! but returns self.
    def keep_if(&block)
      return enum_for(:keep_if) unless block_given?
      select!(&block)
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

    def self.included base
      base.class_eval do
        extend  ClassMethods
        include Enumerable
      end
    end

  end
end
