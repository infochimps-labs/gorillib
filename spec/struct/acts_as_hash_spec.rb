require File.dirname(__FILE__)+'/../spec_helper'
require File.dirname(__FILE__)+'/../support/hashlike_fuzzing_helper'
require 'gorillib/hashlike'
require 'gorillib/struct/acts_as_hash'

#
#
#
STRUCT_HASHLIKE_METHODS_TO_SKIP = [:each, :flatten, :clear, :values_at, :reject, :select] + HashlikeFuzzingHelper::ENUMERABLE_METHODS

module HashlikeFuzzingHelper
  SPECIAL_CASES_FOR_HASHLIKE_STRUCT = Hash.new({}).merge({
      :[]    => [
        [0], [1], [2], [100], [-1],                            # numeric keys are interpreted as positional args
        [:z], [:z, STRING_2X_PROC], [:z, 100, STRING_2X_PROC], # doesn't allow access to undefined keys
      ],
      :[]=   => [
        [:z, :a], [:z, 100, STRING_2X_PROC],                   # doesn't allow access to undefined keys
      ],
      :store => [
        [:z, :a], [:z, 100, STRING_2X_PROC],                   # doesn't allow access to undefined keys
      ],
      :each_pair => [
        [TOTAL_V_PROC],                                        # behaves differently on arity 1
      ],
    })
end

StructUsingHashlike = Struct.new(:a, :b, :c, :nil_val, :false_val, :true_val, :arr_val) do
  include Gorillib::Struct::ActsAsHash
  include Gorillib::Hashlike
  # include Gorillib::Hashlike::EnumerateFromKeys

  def to_s ; to_hash.to_s ; end
  def inspect ; to_s ; end
  # let nil key be same as missing key
  def ==(other_hash)
    each_pair{           |k,v| return false unless (v == other_hash[k]) }
    other_hash.each_pair{|k,v| return false unless (v == self[k]) }
    true
  end
end

describe Gorillib::Struct::ActsAsHash do
  include HashlikeFuzzingHelper

  describe "behaves same as for Hash (symbol keys)" do
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

end
