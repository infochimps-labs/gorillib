require 'enumerator'
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

    # Fake hash reader semantics: delegates to self.send(key)
    #
    # Note: indifferent access -- either of :foo or "foo" will work
    #
    def [](name)
      self.send(name) if members.include?(name.to_sym)
    end

    # Fake hash writer semantics: delegates to self.send("key=", val)
    #
    # NOTE: this calls self.foo= 5, not self.receive_foo(5)
    # NOTE: indifferent access -- either of :foo or "foo" will work
    #
    def []=(name, val)
      self.send("#{name}=", val) if members.include?(name.to_sym)
    end
    alias_method(:store, :[]=)

    # @param key<Object> The key to remove
    #
    # @return [Object]
    #   returns the value of the given attribute, and sets its new value to nil.
    #   If there is a corresponding instance_variable, it is subsequently removed.
    def delete(key)
      val = self[key]
      unset!(key)
      val
    end

    if RUBY_VERSION < '1.9.0'
      def keys
        members & instance_variables.map{|s| s.gsub(/^@/, "").to_sym  }
      end
    else
      def keys
        members & instance_variables
      end
    end
  end
end

