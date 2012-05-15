require 'spec_helper'
require 'enumerator'
require 'gorillib/hashlike'
require 'gorillib/enumerable/sum'

require 'gorillib/utils/capture_output'
RSpec.configure{|c| c.include Gorillib::TestHelpers }

require GORILLIB_ROOT_DIR('spec/support/hashlike_helper')
require GORILLIB_ROOT_DIR('spec/support/hashlike_fuzzing_helper')
require GORILLIB_ROOT_DIR('spec/support/hashlike_via_delegation')

class InternalHashWithEquality < InternalHash
  # Override these so we can compare exceptions.
  def to_s()             @myhsh.to_s          ; end
  def ==(other_hash)     @myhsh == other_hash ; end
end

describe Gorillib::Hashlike, :hashlike_spec => true do

  if ENV['FULL_SPECS']

    include HashlikeFuzzingHelper

    before do
      @total = 0
      @hsh      = HashlikeFuzzingHelper::HASH_TO_TEST_FULLY_HASHLIKE.dup
      @hshlike  = InternalHashWithEquality.new.merge(HashlikeFuzzingHelper::HASH_TO_TEST_FULLY_HASHLIKE)
    end

    it 'does everything a hash can do' do
      hsh_methods     = ({}.methods.map(&:to_sym) - HashlikeHelper::OMITTED_METHODS_FROM_HASH - HashlikeHelper::HASH_METHODS_MISSING_FROM_VERSION)
      hshlike_methods = (@hshlike.methods.map(&:to_sym) -
        ([:hash_eql?, :myhsh] + HashlikeHelper::HASH_METHODS_MISSING_FROM_VERSION))
      hsh_methods.sort_by(&:to_s).should == hshlike_methods.sort_by(&:to_s)
    end

    it 'has specs for every Hash method' do
      (@hshlike.methods.map(&:to_sym) -
        (Object.new.methods.map(&:to_sym) +
          HashlikeHelper::METHODS_TO_TEST +
          HashlikeHelper::HASH_METHODS_MISSING_FROM_VERSION +
          [:hash_eql?, :myhsh])
        ).should == []
    end

    ( HashlikeHelper::METHODS_TO_TEST -
      HashlikeHelper::HASH_METHODS_MISSING_FROM_VERSION
      ).each do |method_to_test|
      describe "##{method_to_test} same as for Hash" do
        HashlikeFuzzingHelper::INPUTS_WHEN_FULLY_HASHLIKE.each do |input|

          it "on #{input.inspect}" do
            behaves_the_same(@hsh, @hshlike, method_to_test, input)
          end
        end
      end
    end

    #
    # With a few exceptions (see HASHLIKE_DEPENDENT_METHODS), all hashlike methods go through only the following core methods:
    #
    HASHLIKE_CONTRACT_METHODS = [:[], :[]=, :delete, :keys, :each_pair, :has_key?] + Object.public_instance_methods.map(&:to_sym)
    #
    # With a few exceptions, all hashlike methods go through only the core methods
    # in HASHLIKE_CONTRACT_METHODS. The Enumerable methods go though :each, and
    # these exceptions call a tightly-bound peer:
    #
    HASHLIKE_DEPENDENT_METHODS = Hash.new([]).merge({
        :merge => [:update], :rassoc => [:key], :flatten => [:to_hash], :invert => [:to_hash], :sum => [:inject, :map],
        :keep_if => [:select!], :delete_if => [:reject!], :select => [:select!, :keep_if], :reject => [:reject!, :delete_if],
      })
    Enumerable.public_instance_methods.map(&:to_sym).each{|meth| HASHLIKE_DEPENDENT_METHODS[meth] << :each }

    include HashlikeFuzzingHelper
    before do
      @total = 0
      @hsh   = HashlikeFuzzingHelper::HASH_TO_TEST_FULLY_HASHLIKE.dup
    end

    def nuke_most_methods_except(klass, method_to_test)
      (klass.public_instance_methods.map(&:to_sym) -
        (HASHLIKE_CONTRACT_METHODS + HASHLIKE_DEPENDENT_METHODS[method_to_test] + [method_to_test])).each do |method|
        @hshlike_klass.send(:undef_method, method)
      end
    end

    ( HashlikeHelper::METHODS_TO_TEST
      ).each do |method_to_test|
      describe "##{method_to_test} same as for Hash" do
        before do
          @hshlike_klass = Class.new(InternalHashWithEquality)
          @hshlike = @hshlike_klass.new
          @hshlike.merge!(HashlikeFuzzingHelper::HASH_TO_TEST_FULLY_HASHLIKE)
          nuke_most_methods_except(@hshlike_klass, method_to_test)
        end
        HashlikeFuzzingHelper::INPUTS_WHEN_FULLY_HASHLIKE.each do |input|
          it "on #{input.inspect}" do
            behaves_the_same(@hsh, @hshlike, method_to_test, input)
          end
        end
      end
    end

  else
    it 'skipping lengthy example-based testing -- set environment variable FULL_SPECS=true to run all specs'
  end
end
