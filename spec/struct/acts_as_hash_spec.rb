require File.dirname(__FILE__)+'/../spec_helper'
require File.dirname(__FILE__)+'/../support/hashlike_fuzzing_helper'
require 'gorillib/hashlike'
require 'gorillib/struct/acts_as_hash'

#
#
#
STRUCT_HASHLIKE_METHODS_TO_SKIP = [:each, :flatten, :clear, :values_at ] + HashlikeFuzzingHelper::ENUMERABLE_METHODS

StructUsingHashlike = Struct.new(:a, :b, :c, :nil_val, :false_val, :z) do
  include Gorillib::Struct::ActsAsHash
  include Gorillib::Hashlike
  include Gorillib::Hashlike::EnumerateFromKeys

  def to_s ; to_hash.to_s ; end
  def inspect ; to_s ; end
  def ==(other_hash) (length == other_hash.length) && all?{|k,v| v == other_hash[k] } ; end
end

describe Gorillib::Struct::ActsAsHash do
  include HashlikeFuzzingHelper

  before do
    @total = 0
    @hsh      = HashlikeFuzzingHelper::HASH_TO_TEST_WITH.dup
    @hshlike  = StructUsingHashlike.new.merge(HashlikeFuzzingHelper::HASH_TO_TEST_WITH)
  end

  it 'does everything a hash can do' do
    (@hsh.methods.sort -
      (@hshlike.methods + HashlikeFuzzingHelper::OMITTED_METHODS_FROM_HASH)
      ).should == []
  end

  it 'has specs for every Hash method' do
    (@hsh.methods.sort -
      (Object.new.methods + HashlikeFuzzingHelper::METHODS_TO_TEST + HashlikeFuzzingHelper::OMITTED_METHODS_FROM_HASH)
      ).should == []
  end

  ( HashlikeFuzzingHelper::METHODS_TO_TEST - STRUCT_HASHLIKE_METHODS_TO_SKIP ).each do |method_to_test|
    describe "##{method_to_test} same as for Hash" do
      (HashlikeFuzzingHelper::INPUTS_FOR_ALL_HASHLIKES).each do |input|
        it "on #{input.inspect}" do
          behaves_the_same(@hsh, @hshlike, method_to_test, input)
        end
      end
    end
  end

end
