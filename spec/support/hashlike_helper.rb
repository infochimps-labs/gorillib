class ::Hash
  alias_method(:key, :index) unless method_defined?(:key)
  alias_method(:values_of, :values_at) unless method_defined?(:values_of)
end

module HashlikeHelper

  BASE_HSH                     = { :a  => 100, :b  => 200, :c => 300, :nil_val => nil, :false_val => false }.freeze
  HASH_TO_TEST_HASHLIKE_STRUCT = { :a  => 100, :b  => 200, :c => 300, :nil_val => nil, :false_val => false, :new_key => nil, }.freeze
  BASE_HSH_WITH_ARRAY_VALS     = { :a => [100,111], :b => 200, :c => [1, [2, 3, [4, 5, 6]]] }.freeze
  BASE_HSH_WITH_ARRAY_KEYS     = {[:a,:aa] => 100,  :b => 200, [:c,:cc] => [300,333],  [1, 2, [3, 4]] => [1, [2, 3, [4, 5, 6]]] }.freeze

  HASH_TO_TEST_HL_V_A          = { :a  => 100, :b  => 200, :c => 300, :nil_val => nil, :false_val => false }.freeze

  #
  # Methods from Hash
  #

  # Test for all Hashlikes
  HASHLIKE_METHODS = [
    # defined by class
    :[], :[]=, :delete, :keys,
    # typically defined via EnumerateFromKeys, but Struct does its own thing
    :each, :each_pair, :values, :values_at, :values_of, :length,
    # defined by hashlike using above
    :each_key, :each_value, :has_key?, :has_value?, :fetch, :key, :assoc,
    :rassoc, :empty?, :update, :merge, :reject!, :reject, :select!, :select,
    :delete_if, :keep_if, :clear, :to_hash, :invert, :flatten,
    # aliases to the appropriate method
    :store, :include?, :key?, :member?, :size, :value?, :merge!,
  ]

  if RUBY_VERSION < '1.9'
    HASH_METHODS_MISSING_FROM_VERSION = [:flatten, :keep_if, :select!, :select, :rassoc, :assoc]
  else
    HASH_METHODS_MISSING_FROM_VERSION = []
  end

  # Should define specs for all of these
  METHODS_TO_TEST = HASHLIKE_METHODS + Enumerable.public_instance_methods.map(&:to_sym) - HASH_METHODS_MISSING_FROM_VERSION

  # *Only* these basic methods on hash should be missing from a Hashlike
  OMITTED_METHODS_FROM_HASH = [
    # not implemented in hashlike
    :compare_by_identity, :compare_by_identity?,
    :default, :default=, :default_proc, :default_proc=,
    :rehash, :replace, :shift,
    # obsolete
    :index, :indexes, :indices,
  ]

  # fancy hash methods possibly require'd in other specs
  FANCY_HASHLIKE_METHODS = [
    :assert_valid_keys,
    :nested_under_indifferent_access,
    :stringify_keys, :stringify_keys!, :symbolize_keys, :symbolize_keys!,
    :with_indifferent_access, :yaml_initialize
  ]
  FANCY_HASHLIKE_METHODS.each{|meth| OMITTED_METHODS_FROM_HASH << meth }

  # ENUMERABLE_METHODS = [
  #   :each_cons, :each_entry, :each_slice, :each_with_index, :each_with_object,
  #   :entries, :to_a, :map, :collect, :collect_concat, :group_by, :flat_map,
  #   :inject, :reduce, :chunk, :reverse_each, :slice_before, :drop, :drop_while,
  #   :take, :take_while, :detect, :find, :find_all, :find_index, :grep,
  #   :all?, :any?, :none?, :one?, :first, :count, :zip, :max, :max_by, :min,
  #   :min_by, :minmax, :minmax_by, :sort, :sort_by,
  #   :cycle, :partition,
  # ]
  #
  # p Enumerable.public_instance_methods.map(&:to_sym) - ENUMERABLE_METHODS
  # p ENUMERABLE_METHODS - Enumerable.public_instance_methods.map(&:to_sym)
  # extra:   [:member?, :enum_slice, :reject, :select, :include?, :enum_cons, :enum_with_index]
  # missing: [:each_entry, :each_with_object, :collect_concat, :flat_map, :chunk, :slice_before]
end
