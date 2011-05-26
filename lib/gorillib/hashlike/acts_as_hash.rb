require 'enumerator'
module Gorillib
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
  module ActsAsHash

    # Hashlike#==
    #
    # Equality -- Two hashes are equal if they contain the same number of keys,
    # and the value corresponding to each key in the first hash is equal (using
    # <tt>==</tt>) to the value for the same key in the second. If +obj+ is not a
    # Hashlike, attempt to convert it using +to_hash+ and return <tt>obj ==
    # hsh</tt>.
    #
    # Does not take a default value comparion into account.
    #
    # @example
    #     h1 = { :a => 1, :c => 2 }
    #     h2 = { 7 => 35, :c => 2, :a => 1 }
    #     h3 = { :a => 1, :c => 2, 7 => 35 }
    #     h4 = { :a => 1, :d => 2, :f => 35 }
    #     h1 == h2 # => false
    #     h2 == h3 # => true
    #     h3 == h4 # => false
    #
    def ==(name)
      raise 'hell'
    end

    # Hashlike#[]
    #
    # Element Reference -- Retrieves the value stored for +key+.
    #
    # In a normal hash, a default value can be set; none is provided here.
    #
    # Delegates to self.send(key)
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh[:a] # => 100
    #     hsh[:c] # => nil
    #
    # @param  key [Object] key to retrieve
    # @return [Object] the value stored for key, nil if missing
    #
    def [](name)
      self.send(name)
    end


    # Hashlike#[]=
    # Hashlike#store
    #
    # Element Assignment -- Associates the value given by +val+ with the key
    # given by +key+.
    #
    # key should not have its value changed while it is in use as a key. In a
    # normal hash, a String passed as a key will be duplicated and frozen. No such
    # guarantee is provided here
    #
    # Delegates to self.send("key=", val)
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh[:a] = 9
    #     hsh[:c] = 4
    #     hsh    # => { :a => 9, :b => 200, :c => 4 }
    #
    #     hsh[key] = val                         -> val
    #     hsh.store(key, val)                    -> val
    #
    # @param  key [Object] key to associate
    # @param  val [Object] value to associate it with
    # @return [Object]
    #
    def []=(name, val)
      self.send("#{name}=", val)
    end
    alias_method(:store, :[]=)


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
    def delete(key)
      val = self[key]
      self.send(:remove_instance_variable, "@#{attr}") if self.instance_variable_defined?("@#{attr}")
      val
    end

    if RUBY_VERSION < '1.9.0'

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
        instance_variables.map{|s| s.to_s.gsub(/^@/, "").to_sym  }
      end
    else

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
        instance_variables
      end
    end
  end
end


