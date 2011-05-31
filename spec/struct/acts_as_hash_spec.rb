require File.dirname(__FILE__)+'/../spec_helper'
require File.dirname(__FILE__)+'/../support/hashlike_fuzzing_helper'
require 'gorillib/hashlike'
require 'gorillib/struct/acts_as_hash'
require 'gorillib/hash/indifferent_access'

#
# Don't test the built-in Struct methods.
#
# Also, all the enumerable methods behave differently -- they build off each
# (which iterates like an array), not each_pair (which iterates like a hash)
#
STRUCT_HASHLIKE_METHODS_TO_SKIP = [:each, :flatten, :clear, :values_at] +
  Enumerable.public_instance_methods.map(&:to_sym) +
  HashlikeFuzzingHelper::HASH_METHODS_MISSING_FROM_VERSION

module HashlikeFuzzingHelper
  SPECIAL_CASES_FOR_HASHLIKE_STRUCT = Hash.new({}).merge({
      :[]    => [
        [0], [1], [2], [100], [-1], # numeric keys are interpreted as positional args
        [:z], ['z'],                # Struct doesn't allow access to undefined keys
        [:z,  STRING_2X_PROC],
        ['z', STRING_2X_PROC],
        [:z, 100, STRING_2X_PROC],
      ],
      :[]=   => [
        [:z, :a], ['z', :a],        # Struct doesn't allow access to undefined keys
        [:z, 100, STRING_2X_PROC],
      ],
      :store => [
        [:z, :a], ['z', :a],        # Struct doesn't allow access to undefined keys
        [:z, 100, STRING_2X_PROC],
      ],
      :each_pair => [
        [TOTAL_V_PROC],             # Struct behaves differently on arity 1
      ],
    })
end

StructUsingHashlike = Struct.new(:a, :b, :c, :nil_val, :false_val, :true_val, :arr_val) do
  include Gorillib::Struct::ActsAsHash
  include Gorillib::Hashlike

  def to_s ; to_hash.to_s ; end
  def inspect ; to_s ; end

  # compares so nil key is same as missing key
  def ==(othr)
    self.each_pair{|k,v| return false unless (v == othr[k]) }
    othr.each_pair{|k,v| return false unless (v == self[k]) }
    true
  end
end

include HashlikeFuzzingHelper

describe "Hash vs Gorillib::Struct::ActsAsHash" do
  before do
    @total = 0
    @hsh      = HashlikeFuzzingHelper::HASH_TO_TEST_HASHLIKE_STRUCT.dup
    @hshlike  = StructUsingHashlike.new.merge(HashlikeFuzzingHelper::HASH_TO_TEST_HASHLIKE_STRUCT)
  end

  ( HashlikeFuzzingHelper::METHODS_TO_TEST - STRUCT_HASHLIKE_METHODS_TO_SKIP ).each do |method_to_test|
    describe "##{method_to_test}" do

      (HashlikeFuzzingHelper::INPUTS_FOR_ALL_HASHLIKES).each do |input|
        next if HashlikeFuzzingHelper::SPECIAL_CASES_FOR_HASHLIKE_STRUCT[method_to_test].include?(input)

        it "on #{input.inspect}" do
          behaves_the_same(@hsh, @hshlike, method_to_test, input)
        end
      end
    end
  end
end

describe "Gorillib::HashWithIndifferentSymbolKeys vs Gorillib::Struct::ActsAsHash" do
  before do
    @total = 0
    @hsh      = Gorillib::HashWithIndifferentSymbolKeys.new_from_hash_copying_default(
      HashlikeFuzzingHelper::HASH_TO_TEST_HASHLIKE_STRUCT)
    @hshlike  = StructUsingHashlike.new.merge(
      HashlikeFuzzingHelper::HASH_TO_TEST_HASHLIKE_STRUCT)
  end

  ( HashlikeFuzzingHelper::METHODS_TO_TEST - STRUCT_HASHLIKE_METHODS_TO_SKIP
    ).each do |method_to_test|
    describe "##{method_to_test}" do

      ( HashlikeFuzzingHelper::INPUTS_WHEN_INDIFFERENT_ACCESS +
        HashlikeFuzzingHelper::INPUTS_FOR_ALL_HASHLIKES
        ).each do |input|
        next if HashlikeFuzzingHelper::SPECIAL_CASES_FOR_HASHLIKE_STRUCT[method_to_test].include?(input)

        it "on #{input.inspect}" do
          behaves_the_same(@hsh, @hshlike, method_to_test, input)
        end

      end
    end
  end
end
