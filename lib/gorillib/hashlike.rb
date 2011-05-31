if (RUBY_VERSION < '1.9') && (not defined?(KeyError))
  class KeyError < IndexError ; end
end

module Gorillib
  #
  # Your class must provide #[], #[]=, #delete, and #keys --
  #
  # * hsh[key]             Element Reference  -- Retrieves the value stored for +key+.
  # * hsh[key] = val       Element Assignment -- Associates +val+ with +key+.
  # * hsh.delete(key)      Deletes & returns the value whose key is equal to +key+.
  # * hsh.keys             Returns a new array populated with the keys.
  #
  # (see Hashlike::HashlikeViaAccessors for example)
  #
  # Given the above, hashlike will provide the rest, defining the methods
  #
  #     :each_pair, :each, :each_key, :each_value, :values, :values_at, :size,
  #     :length, :has_key?, :include?, :key?, :member?, :has_value?, :value?,
  #     :fetch, :key, :assoc, :rassoc, :empty?, :merge, :update, :merge!,
  #     :reject!, :select!, :delete_if, :keep_if, :reject, :clear, :store,
  #     :to_hash, :invert, :flatten
  #
  # and these methods added by Enumerable:
  #
  #     :each_cons, :each_entry, :each_slice, :each_with_index,
  #     :each_with_object, :entries, :to_a, :map, :collect, :collect_concat,
  #     :group_by, :flat_map, :inject, :reduce, :chunk, :reverse_each,
  #     :slice_before, :drop, :drop_while, :take, :take_while, :detect, :find,
  #     :find_all, :select, :find_index, :grep, :all?, :any?, :none?, :one?,
  #     :first, :count, :zip, :max, :max_by, :min, :min_by, :minmax, :minmax_by,
  #     :sort, :sort_by, :cycle, :partition,
  #
  # It does not define these methods that do exist on hash:
  #
  #     :default, :default=, :default_proc, :default_proc=,
  #     :compare_by_identity, :compare_by_identity?,
  #     :replace, :rehash, :shift
  #
  # === Chinese wall
  #
  # With a few exceptions, all methods are defined only in terms of
  #
  #     #[], #[]=, #delete, #keys, #each_pair and #has_key?
  #
  # (exceptions: merge family depend on #update; the reject/select/xx_if family
  # depend on each other; #invert & #flatten call #to_hash; #rassoc calls #key)
  #
  # === custom iterators
  #
  # Hashlike typically defines the following fundamental iterators by including
  # Gorillib::Hashlike::EnumerateFromKeys:
  #
  #     :each_pair, :each, :values, :values_at, :length
  #
  # However, if the #each_pair method already exists on the class (as it does
  # for Struct), those methods will *not* be defined. The class is held
  # responsible for the implementation of all five. (Of these, #each_pair
  # is the only method called from elsewhere in Hashlike, while #each is the
  # only method called from Enumerable).
  #
  # === #convert_key (Indifferent Access)
  #
  # If you define #convert_key the #values_at, #has_key?, #fetch, and #assoc
  # methods will use it to sanitize keys coming in from the outside.  It's
  # assumed that you will do the same with #[], #[]= and #delete. (see
  # Gorillib::HashWithIndifferentAccess for an example).
  #
  module Hashlike

    #
    # Provides a natural default iteration behavior by iterating over #keys.
    # Since most classes will want this behaviour, it is included by default
    # *unless* the class has already defined an #each method.
    #
    # Classes that wish to define their own iteration behavior (Struct for
    # example, or a database facade) must define all of the methods within this
    # module.
    #
    module EnumerateFromKeys

      #
      # Calls +block+ once for each key in +hsh+, passing the key/value pair as
      # parameters.
      #
      # If no block is given, an enumerator is returned instead.
      #
      # @example
      #     hsh = { :a => 100, :b => 200 }
      #     hsh.each_pair{|key, value| puts "#{key} is #{value}" }
      #     # produces:
      #     a is 100
      #     b is 200
      #
      # @example with block arity:
      #     hsh = {[:a,:b] => 3, [:c, :d] => 4, :e => 5}
      #     seen_args = []
      #     hsh.each_pair{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      #     # => [[[:a, :b], 3, nil], [[:c, :d], 4, nil], [:e, 5, nil]]
      #
      #     seen_args = []
      #     hsh.each_pair{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      #     # => [[:a, :b, 3], [:c, :d, 4], [:e, nil, 5]]
      #
      # @overload hsh.each_pair{|key, val| block }      -> hsh
      #   Calls block once for each key in +hsh+
      #   @yield [key, val] in order, each key and its associated value
      #   @return [Hashlike]
      #
      # @overload hsh.each_pair                         -> an_enumerator
      #   with no block, returns a raw enumerator
      #   @return [Enumerator]
      #
      def each_pair
        return enum_for(:each_pair) unless block_given?
        keys.each do |key|
          yield([key, self[key]])
        end
        self
      end

      #
      # Calls +block+ once for each key in +hsh+, passing the key/value pair as
      # parameters.
      #
      # If no block is given, an enumerator is returned instead.
      #
      # @example
      #     hsh = { :a => 100, :b => 200 }
      #     hsh.each{|key, value| puts "#{key} is #{value}" }
      #     # produces:
      #     a is 100
      #     b is 200
      #
      # @example with block arity:
      #     hsh = {[:a,:b] => 3, [:c, :d] => 4, :e => 5}
      #     seen_args = []
      #     hsh.each{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
      #     # => [[[:a, :b], 3, nil], [[:c, :d], 4, nil], [:e, 5, nil]]
      #
      #     seen_args = []
      #     hsh.each{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
      #     # => [[:a, :b, 3], [:c, :d, 4], [:e, nil, 5]]
      #
      # @overload hsh.each{|key, val| block }      -> hsh
      #   Calls block once for each key in +hsh+
      #   @yield [key, val] in order, each key and its associated value
      #   @return [Hashlike]
      #
      # @overload hsh.each                         -> an_enumerator
      #   with no block, returns a raw enumerator
      #   @return [Enumerator]
      #
      def each(&block)
        return enum_for(:each) unless block_given?
        each_pair(&block)
      end

      #
      # Returns the number of key/value pairs in the hashlike.
      #
      # @example
      #     hsh = { :d => 100, :a => 200, :v => 300, :e => 400 }
      #     hsh.length       # => 4
      #     hsh.delete(:a)   # => 200
      #     hsh.length       # => 3
      #
      # @return [Fixnum] number of key-value pairs
      #
      def length
        keys.length
      end

      #
      # A new array populated with the values from +hsh+.
      #
      # @see Hashlike#keys.
      #
      # @example
      #     hsh = { :a => 100, :b => 200, :c => 300 }
      #     hsh.values   # => [100, 200, 300]
      #
      # @return [Array] the values, in order by their key.
      #
      def values
        [].tap{|arr| each_pair{|key, val| arr << val } }
      end

      #
      # Array containing the values associated with the given keys.
      #
      # @see Hashlike#select.
      #
      # @example
      #     hsh = { "cat" => "feline", "dog" => "canine", "cow" => "bovine" }
      #     hsh.values_at("cow", "cat")  # => ["bovine", "feline"]
      #
      # @example
      #     hsh = { :a => 100, :b => 200, :c => 300 }
      #     hsh.values_at(:c, :a, :c, :z, :a)
      #     # => [300, 100, 300, nil, 100]
      #
      # @param  *allowed_keys [Object] the keys to retrieve.
      # @return [Array] the values, in order according to allowed_keys.
      #
      def values_at(*allowed_keys)
        allowed_keys.map do |key|
          key = convert_key(key) if respond_to?(:convert_key)
          self[key] if has_key?(key)
        end
      end
    end

    # alias for #[]=
    def store(key, val)
      self[key] = val
    end

    # Hashlike#each_key
    #
    # Calls +block+ once for each key in +hsh+, passing the key as a parameter.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.each_key{|key| puts key }
    #     # produces:
    #     a
    #     b
    #
    # @example with block arity:
    #     hsh = {[:a,:b] => 3, [:c, :d] => 4, :e => 5}
    #     seen_args = []
    #     hsh.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
    #     # => [[:a, :b, nil], [:c, :d, nil], [:e, nil, nil]]
    #
    #     seen_args = []
    #     hsh.each_key{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
    #     # => [[:a, nil, :b], [:c, nil, :d], [:e, nil, nil]]
    #
    # @overload hsh.each_key{|key| block }       -> hsh
    #   Calls +block+ once for each key in +hsh+
    #   @yield [key] in order, each key
    #   @return [Hashlike]
    #
    # @overload hsh.each_key                     -> an_enumerator
    #   with no block, returns a raw enumerator
    #   @return [Enumerator]
    #
    def each_key
      return enum_for(:each_key) unless block_given?
      each_pair{|k,v| yield k }
      self
    end

    #
    # Calls +block+ once for each key in +hsh+, passing the value as a parameter.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.each_value{|value| puts value }
    #     # produces:
    #     100
    #     200
    #
    # @example with block arity:
    #     hsh = {:a => [300,333], :b => [400,444], :e => 500})
    #     seen_args = []
    #     hsh.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
    #     # => [[300, 333, nil], [400, 444, nil], [500, nil, nil]]
    #
    #     seen_args = []
    #     hsh.each_value{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
    #     # => [[300, nil, 333], [400, nil, 444], [500, nil, nil]]
    #
    # @overload hsh.each_value{|val| block }     -> hsh
    #   Calls +block+ once for each value in +hsh+
    #   @yield [val] in order by its key, each value
    #   @return [Hashlike]
    #
    # @overload hsh.each_value                   -> an_enumerator
    #   with no block, returns a raw enumerator
    #   @return [Enumerator]
    #
    def each_value
      return enum_for(:each_value) unless block_given?
      each_pair{|k,v| yield v }
      self
    end

    #
    # Returns true if the given key is present in +hsh+.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.has_key?(:a)   # => true
    #     hsh.has_key?(:z)   # => false
    #
    # @param key [Object] the key to check for.
    # @return [true, false] true if the key is present, false otherwise
    #
    def has_key?(key)
      key = convert_key(key) if respond_to?(:convert_key)
      keys.include?(key)
    end

    #
    # Returns true if the given value is present for some key in +hsh+.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.has_value?(100)   # => true
    #     hsh.has_value?(999)   # => false
    #
    # @param  target [Object] the value to query
    # @return [true, false] true if the value is present, false otherwise
    #
    def has_value?(target)
      # don't refactor this to any? -- Struct's #any is weird
      each_pair{|key, val| return true if (val == target) }
      false
    end

    #
    # Returns a value from the hashlike for the given key. If the key can't be
    # found, there are several options:
    # * With no other arguments, it will raise a +KeyError+ exception;
    # * if default is given, then that will be returned;
    # * if the optional code block is specified, then that will be run and its result returned.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.fetch(:a)                          # => 100
    #     hsh.fetch(:z, "go fish")               # => "go fish"
    #     hsh.fetch(:z){|el| "go fish, #{el}"}   # => "go fish, z"
    #
    # @example An exception is raised if the key is not found and a default value is not supplied.
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.fetch(:z)
    #     # produces:
    #     prog.rb:2:in `fetch': key not found (KeyError) from prog.rb:2
    #
    #     hsh.fetch(:z, 3)
    #     # => 3
    #
    #     hsh.fetch(:z){|key| key.to_s * 5 }
    #     # => "zzzzz"
    #
    # @param key     [Object]   the key to query
    # @param default [Object]   the value to use if the key is missing
    # @raise         [KeyError] raised if missing, and neither +default+ nor +block+ is supplied
    # @yield         [key]      if missing, block called with the key requested
    # @return        [Object]   the value; if missing, the default; if missing, the
    #                           block's return value
    #
    def fetch(key, default=nil, &block)
      key = convert_key(key) if respond_to?(:convert_key)
      warn "#{caller[0]}: warning: block supersedes default value argument" if default && block_given?
      if    has_key?(key) then self[key]
      elsif block_given?  then yield(key)
      elsif default       then default
      else  raise KeyError, "key not found: #{key.inspect}"
      end
    end

    #
    # Searches the hash for an entry whose value == +val+, returning the
    # corresponding key. If not found, returns +nil+.
    #
    # You are guaranteed that the first matching key in #keys will be the one
    # returned.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }
    #     hsh.key(200)   # => :b
    #     hsh.key(999)   # => nil
    #
    # @param  val [Object] the value to look up
    # @return [Object, nil] the key for the given val, or nil if missing
    #
    def key(val)
      keys.find{|key| self[key] == val }
    end

    #
    # Searches through the hashlike comparing obj with the key using ==.
    # Returns the key-value pair (two elements array) or nil if no match is
    # found.
    #
    # @see Array#assoc.
    #
    # @example
    #     hsh = { "colors"  => ["red", "blue", "green"],
    #             "letters" => [:a, :b, :c ]}
    #     hsh.assoc("letters")  # => ["letters", [:a, :b, :c]]
    #     hsh.assoc("foo")      # => nil
    #
    # @return [Array, nil] the key-value pair (two elements array) or nil if no
    #   match is found.
    #
    def assoc(key)
      key = convert_key(key) if respond_to?(:convert_key)
      return unless has_key?(key)
      [key, self[key]]
    end

    #
    # Searches through the hashlike comparing obj with the value using ==.
    # Returns the first key-value pair (two-element array) that matches, or nil
    # if no match is found.
    #
    # @see Array#rassoc.
    #
    # @example
    #     hsh = { 1 => "one", 2 => "two", 3 => "three", "ii" => "two"}
    #     hsh.rassoc("two")    # => [2, "two"]
    #     hsh.rassoc("four")   # => nil
    #
    # @return [Array, nil] The first key-value pair (two-element array) that
    #   matches, or nil if no match is found
    #
    def rassoc(val)
      key = key(val) or return
      [key, self[key]]
    end

    #
    # Returns true if the hashlike contains no key-value pairs, false otherwise.
    #
    # @example
    #     {}.empty?   # => true
    #
    # @return [true, false] true if +hsh+ contains no key-value pairs, false otherwise
    #
    def empty?
      keys.empty?
    end

    #
    # Adds the contents of +other_hash+ to +hsh+.  If no block is
    # specified, entries with duplicate keys are overwritten with the values from
    # +other_hash+, otherwise the value of each duplicate key is determined by
    # calling the block with the key, its value in +hsh+ and its value in
    # +other_hash+.
    #
    # @example
    #     h1 = { :a => 100, :b => 200 }
    #     h2 = { :b => 254, :c => 300 }
    #     h1.merge!(h2)
    #     # => { :a => 100, :b => 254, :c => 300 }
    #
    #     h1 = { :a => 100, :b => 200 }
    #     h2 = { :b => 254, :c => 300 }
    #     h1.merge!(h2){|key, v1, v2| v1 }
    #     # => { :a => 100, :b => 200, :c => 300 }
    #
    # @overload hsh.update(other_hash)                               -> hsh
    #   Adds the contents of +other_hash+ to +hsh+.  Entries with duplicate keys are
    #   overwritten with the values from +other_hash+
    #   @param  other_hash [Hash, Hashlike] the hash to merge (it wins)
    #   @return [Hashlike] this hashlike, updated
    #
    # @overload hsh.update(other_hash){|key, oldval, newval| block}  -> hsh
    #   Adds the contents of +other_hash+ to +hsh+.  The value of each duplicate key
    #   is determined by calling the block with the key, its value in +hsh+ and its
    #   value in +other_hash+.
    #   @param  other_hash [Hash, Hashlike] the hash to merge (it wins)
    #   @yield  [Object, Object, Object] called if key exists in each +hsh+
    #   @return [Hashlike] this hashlike, updated
    #
    def update(other_hash)
      raise TypeError, "can't convert #{other_hash.nil? ? 'nil' : other_hash.class} into Hash" unless other_hash.respond_to?(:each_pair)
      other_hash.each_pair do |key, val|
        if block_given? && has_key?(key)
          val = yield(key, val, self[key])
        end
        self[key] = val
      end
      self
    end

    #
    # Returns a new hashlike containing the contents of +other_hash+ and the
    # contents of +hsh+. If no block is specified, the value for entries with
    # duplicate keys will be that of +other_hash+. Otherwise the value for each
    # duplicate key is determined by calling the block with the key, its value in
    # +hsh+ and its value in +other_hash+.
    #
    # @example
    #     h1 = { :a => 100, :b => 200 }
    #     h2 = { :b => 254, :c => 300 }
    #     h1.merge(h2)
    #     # => { :a=>100, :b=>254, :c=>300 }
    #     h1.merge(h2){|key, oldval, newval| newval - oldval}
    #     # => { :a => 100, :b => 54,  :c => 300 }
    #     h1
    #     # => { :a => 100, :b => 200 }
    #
    # @overload hsh.merge(other_hash)                               -> hsh
    #   Adds the contents of +other_hash+ to +hsh+.  Entries with duplicate keys are
    #   overwritten with the values from +other_hash+
    #   @param  other_hash [Hash, Hashlike] the hash to merge (it wins)
    #   @return [Hashlike] a new merged hashlike
    #
    # @overload hsh.merge(other_hash){|key, oldval, newval| block}  -> hsh
    #   Adds the contents of +other_hash+ to +hsh+.  The value of each duplicate key
    #   is determined by calling the block with the key, its value in +hsh+ and its
    #   value in +other_hash+.
    #   @param  other_hash [Hash, Hashlike] the hash to merge (it wins)
    #   @yield  [Object, Object, Object] called if key exists in each +hsh+
    #   @return [Hashlike] a new merged hashlike
    #
    def merge(*args, &block)
      self.dup.update(*args, &block)
    end

    #
    # Deletes every key-value pair from +hsh+ for which +block+ evaluates truthy
    # (equivalent to Hashlike#delete_if), but returns nil if no changes were made.
    #
    # @example
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.delete_if{|key, val| key.to_s >= "b" }   # => { :a => 100 }
    #
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.delete_if{|key, val| key.to_s >= "z" }   # nil
    #
    # @overload hsh.reject!{|key, val| block }   -> hsh or nil
    #   Deletes every key-value pair from +hsh+ for which +block+ evaluates truthy.
    #   @return [Hashlike, nil]
    #
    # @overload hsh.reject!                      -> an_enumerator
    #   with no block, returns a raw enumerator
    #   @return [Enumerator]
    #
    def reject!(&block)
      return enum_for(:reject!) unless block_given?
      changed = false
      each_pair do |key, val|
        if yield(*[key, val].take(block.arity))
          changed = true
          delete(key)
        end
      end
      changed ? self : nil
    end

    #
    # Deletes every key-value pair from +hsh+ for which +block+ evaluates falsy
    # (equivalent to Hashlike#keep_if), but returns nil if no changes were made.
    #
    # @example
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.select!{|key, val| key.to_s >= "b" }   # => { :b => 200, :c => 300 }
    #
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.select!{|key, val| key.to_s >= "a" }   # => { :a => 100, :b => 200, :c => 300 }
    #
    # @overload hsh.select!{|key, val| block }   -> hsh or nil
    #   Deletes every key-value pair from +hsh+ for which +block+ evaluates falsy.
    #   @return [Hashlike]
    #
    # @overload hsh.select!                      -> an_enumerator
    #   with no block, returns a raw enumerator
    #   @return [Enumerator]
    #
    def select!(&block)
      return enum_for(:select!) unless block_given?
      changed = false
      each_pair do |key, val|
        if not yield(*[key, val].take(block.arity))
          changed = true
          delete(key)
        end
      end
      changed ? self : nil
    end

    #
    # Deletes every key-value pair from +hsh+ for which +block+ evaluates truthy.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # @example
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.delete_if{|key, val| key.to_s >= "b" }   # => { :a => 100 }
    #
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.delete_if{|key, val| key.to_s >= "z" }   # => { :a => 100, :b => 200, :c => 300 }
    #
    # @overload hsh.delete_if{|key, val| block } -> hsh
    #   Deletes every key-value pair from +hsh+ for which +block+ evaluates truthy.
    #   @return [Hashlike]
    #
    # @overload hsh.delete_if                    -> an_enumerator
    #   with no block, returns a raw enumerator
    #   @return [Enumerator]
    #
    def delete_if(&block)
      return enum_for(:delete_if) unless block_given?
      reject!(&block)
      self
    end

    #
    # Deletes every key-value pair from +hsh+ for which +block+ evaluates falsy.
    #
    # If no block is given, an enumerator is returned instead.
    #
    # @example
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.keep_if{|key, val| key.to_s >= "b" }   # => { :b => 200, :c => 300 }
    #
    #     hsh = { :a => 100, :b => 200, :c => 300 }
    #     hsh.keep_if{|key, val| key.to_s >= "a" }   # => { :a => 100, :b => 200, :c => 300 }
    #
    # @overload hsh.keep_if{|key, val| block }   -> hsh
    #   Deletes every key-value pair from +hsh+ for which +block+ evaluates falsy.
    #   @return [Hashlike]
    #
    # @overload hsh.keep_if                      -> an_enumerator
    #   with no block, returns a raw enumerator
    #   @return [Enumerator]
    #
    def keep_if(&block)
      return enum_for(:keep_if) unless block_given?
      select!(&block)
      self
    end

    #
    # Overrides the implementation in Enumerable, which iterates on keys, not
    # key/value pairs
    #
    module OverrideEnumerable
      #
      # Deletes every key-value pair from +hsh+ for which +block+ evaluates to
      # true (similar to Hashlike#delete_if), but works on (and returns) a copy of
      # the +hsh+. Equivalent to <tt>hsh.dup.delete_if</tt>.
      #
      # @example
      #     hsh = { :a => 100, :b => 200, :c => 300 }
      #     hsh.reject{|key, val| key.to_s >= "b" }   # => { :a => 100 }
      #     hsh # => { :a => 100, :b => 200, :c => 300 }
      #
      #     hsh = { :a => 100, :b => 200, :c => 300 }
      #     hsh.reject{|key, val| key.to_s >= "z" }   # => { :a => 100, :b => 200, :c => 300 }
      #     hsh # => { :a => 100, :b => 200, :c => 300 }
      #
      # @overload hsh.reject{|key, val| block }    -> new_hashlike
      #   Deletes every key-value pair from +hsh+ for which +block+ evaluates truthy.
      #   @return [Hashlike]
      #
      # @overload hsh.reject                       -> an_enumerator
      #   with no block, returns a raw enumerator
      #   @return [Enumerator]
      #
      # Overrides the implementation in Enumerable, which does the keys wrong.
      #
      def reject(&block)
        return enum_for(:reject) unless block_given?
        self.dup.delete_if(&block)
      end

      #
      # Deletes every key-value pair from +hsh+ for which +block+ evaluates to
      # false (similar to Hashlike#keep_if), but works on (and returns) a copy of
      # the +hsh+. Equivalent to <tt>hsh.dup.keep_if</tt>.
      #
      # @example
      #     hsh = { :a => 100, :b => 200, :c => 300 }
      #     hsh.select{|key, val| key.to_s >= "b" }   # => { :b => 200, :c => 300 }
      #     hsh # => { :a => 100, :b => 200, :c => 300 }
      #
      #     hsh = { :a => 100, :b => 200, :c => 300 }
      #     hsh.select{|key, val| key.to_s >= "z" }   # => { }
      #     hsh # => { :a => 100, :b => 200, :c => 300 }
      #
      # @overload hsh.select{|key, val| block }    -> new_hashlike
      #   Deletes every key-value pair from +hsh+ for which +block+ evaluates truthy.
      #   @return [Hashlike]
      #
      # @overload hsh.select                       -> an_enumerator
      #   with no block, returns a raw enumerator
      #   @return [Enumerator]
      #
      # Overrides the implementation in Enumerable, which does the keys wrong.
      #
      def select(&block)
        return enum_for(:select) unless block_given?
        self.dup.keep_if(&block)
      end
    end

    #
    # Removes all key-value pairs from +hsh+.
    #
    # @example
    #     hsh = { :a => 100, :b => 200 }   # => { :a => 100, :b => 200 }
    #     hsh.clear                        # => {}
    #
    # @return [Hashlike] this hashlike, emptied
    #
    def clear
      each_pair{|k,v| delete(k) }
    end

    #
    # Returns a hash with each key set to its associated value.
    #
    # @example
    #    my_hshlike = MyHashlike.new
    #    my_hshlike[:a] = 100; my_hshlike[:b] = 200
    #    my_hshlike.to_hash # => { :a => 100, :b => 200 }
    #
    # @return [Hash] a new Hash instance, with each key set to its associated value.
    #
    def to_hash
      {}.tap{|hsh| each_pair{|key, val| hsh[key] = val } }
    end

    #
    # Returns a new hash created by using +hsh+'s values as keys, and the keys as
    # values. If +hsh+ has duplicate values, the result will contain only one of
    # them as a key -- which one is not predictable.
    #
    # @example
    #     hsh = { :n => 100, :m => 100, :y => 300, :d => 200, :a => 0 }
    #     hsh.invert # => { 0 => :a, 100 => :m, 200 => :d, 300 => :y }
    #
    # @return [Hash] a new hash, with values for keys and vice-versa
    #
    def invert
      to_hash.invert
    end

    #
    # Returns a new array that is a one-dimensional flattening of this
    # hashlike. That is, for every key or value that is an array, extract its
    # elements into the new array.  Unlike Array#flatten, this method does not
    # flatten recursively by default; pass +nil+ explicitly to flatten
    # recursively.  The optional level argument determines the level of
    # recursion to flatten.
    #
    # @example
    #     hsh =  {1=> "one", 2 => [2,"two"], 3 => "three"}
    #     hsh.flatten    # => [1, "one", 2, [2, "two"], 3, "three"]
    #     hsh.flatten(2) # => [1, "one", 2, 2, "two", 3, "three"]
    #
    # @example with deep nesting
    #     hsh = { [1, 2, [3, 4]] => [1, [2, 3, [4, 5, 6]]] }
    #     hsh.flatten
    #     # =>   [[1, 2, [3, 4]],   [1, [2, 3, [4, 5, 6]]]]
    #     hsh.flatten(0)
    #     # =>  [[[1, 2, [3, 4]],   [1, [2, 3, [4, 5, 6]]]]]
    #     hsh.flatten(1)
    #     # =>   [[1, 2, [3, 4]],   [1, [2, 3, [4, 5, 6]]]]
    #     hsh.flatten(2)
    #     # =>    [1, 2, [3, 4],     1, [2, 3, [4, 5, 6]]]
    #     hsh.flatten(3)
    #     # =>    [1, 2,  3, 4,      1,  2, 3, [4, 5, 6]]
    #     hsh.flatten(4)
    #     # =>    [1, 2,  3, 4,      1,  2, 3,  4, 5, 6]
    #     hsh.flatten.flatten
    #     # =>    [1, 2,  3, 4,      1,  2, 3,  4, 5, 6]
    #
    # @example nil level means complete flattening
    #     hsh.flatten(nil)
    #     # =>    [1, 2,  3, 4,      1,  2, 3,  4, 5, 6]
    #
    # @param  level [Integer] the level of recursion to flatten, 0 by default.
    # @return [Array] the flattened key-value array.
    #
    def flatten(*args)
      to_hash.flatten(*args)
    end

    def self.included(base)
      base.class_eval do
        base.send(:include, EnumerateFromKeys) unless base.method_defined?(:each_pair)
        unless base.include?(Enumerable)
          base.send(:include, Enumerable)
          base.send(:include, OverrideEnumerable)
        end

        # included here so they win out over Enumerable
        alias_method :include?, :has_key?
        alias_method :key?,     :has_key?
        alias_method :member?,  :has_key?
        alias_method :value?,   :has_value?
        alias_method :merge!,   :update
        alias_method :size,     :length
      end
    end

  end
end

