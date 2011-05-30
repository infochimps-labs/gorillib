require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/hashlike'

require File.dirname(__FILE__)+'/../support/hashlike_fuzzing_helper'
require File.dirname(__FILE__)+'/../support/hashlike_via_delegation'

class InternalHashWithEquality < InternalHash
  # Override these so we can compare exceptions.
  def to_s()             @myhsh.to_s          ; end
  def ==(other_hash)     @myhsh == other_hash ; end
end

describe Gorillib::Hashlike do
  include HashlikeFuzzingHelper

  before do
    @total = 0
    @hsh      = HashlikeFuzzingHelper::HASH_TO_TEST_FULLY_HASHLIKE.dup
    @hshlike  = InternalHashWithEquality.new.merge(HashlikeFuzzingHelper::HASH_TO_TEST_FULLY_HASHLIKE)
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

  HashlikeFuzzingHelper::METHODS_TO_TEST.each do |method_to_test|
    describe "##{method_to_test} same as for Hash" do
      HashlikeFuzzingHelper::INPUTS_WHEN_FULLY_HASHLIKE.each do |input|
        it "on #{input.inspect}" do
          behaves_the_same(@hsh, @hshlike, method_to_test, input)
        end
      end
    end
  end

end

