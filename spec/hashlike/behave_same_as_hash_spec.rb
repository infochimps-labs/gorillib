require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/hashlike'
require 'gorillib/hashlike/acts_as_hash'
require 'gorillib/struct/acts_as_hash'
require 'gorillib/hash/indifferent_access'

METHODS_TO_TEST = [
  :[],
  :[]=, :store,
  :delete, :keys,
  :each, :each_pair, :each_key, :each_value,
  :has_key?, :include?, :key?, :member?,
  :has_value?, :value?,
  :fetch, :length, :size, :empty?,
  :to_hash,
  :values,
  # :values_at, 
  :merge,
  :update, :merge!,
  :key,
  :invert,
  :reject!, :select!, :delete_if, :keep_if, :reject,
  # :clear,
  :flatten,
  :assoc,
  :rassoc,
  # #
  :each_cons, :each_entry, :each_slice, :each_with_index, :each_with_object, :entries,
  :to_a, :map, :collect, :collect_concat, :group_by, :flat_map, :inject, :reduce,
  :chunk,
  # :cycle,
  # :partition,
  :reverse_each, :slice_before,
  :drop, :drop_while, :take, :take_while,
  #
  :detect, :find, :find_all, :select, :find_index, :grep,
  :all?, :any?, :none?, :one?,
  :first, :count, :zip,
  #
  :max, :max_by, :min, :min_by, :minmax, :minmax_by, :sort, :sort_by,

]

STRING_5X_PROC   = Proc.new{|k|   k.to_s * 5 }
TOTAL_K_PROC     = Proc.new{|k|   @total += self[k].to_i }
TOTAL_V_PROC     = Proc.new{|v|   p ['blk', self, v] ; @total += v.to_i }
TOTAL_KV_PROC    = Proc.new{|k,v| @total += v.to_i }
VAL_GTE_4_PROC   = Proc.new{|k,v| v.to_i >= 4   }
VAL_GTE_0_PROC   = Proc.new{|k,v| v.to_i >= 0   }
VAL_GTE_1E6_PROC = Proc.new{|k,v| v.to_i >= 1e6 }

def send_to obj, meth, input
  if input.last.is_a?(Proc)
    input, block = [input[0..-2], input.last]
    obj.send(meth, *input, &block)
  else
    obj.send(meth, *input)
  end
end

def behaves_the_same obj_1, obj_2, method_to_test, input
  begin
    expected = send_to(obj_1, method_to_test, input)
  rescue Exception => e
    expected = e
  end
  
  case expected
  when Exception
    # workaround: some errors have different spacing before ( than others
    # err_str = Regexp.new(Regexp.escape(expected.to_s.gsub(/NilClass/, "nil")).gsub(/(\\ )?\\\(/, '\s*\('))
    err_str = expected.to_s.
      gsub(/arguments\s*\(\d* for ([\d\.]+)\)/, "arguments").
      gsub(/"a"|:a/, ':a')
    err_str = Regexp.new(Regexp.escape(err_str))
    lambda{ send_to(obj_2, method_to_test, input) }.should raise_error(expected.class, err_str)
  when Enumerator
    actual = send_to(obj_2, method_to_test, input)
    actual.should be_a(Enumerator)
    actual.inspect.gsub(/[\"\:]/, '').gsub(/0x[a-f\d]+/,'').should == expected.inspect.gsub(/[\"\:]/, '').gsub(/0x[a-f\d]+/,'')
  else
    actual = send_to(obj_2, method_to_test, input)
    expected.should == actual
  end 
end

class Foo
  include Enumerable
  include Gorillib::Hashlike::ActsAsHash
  include Gorillib::Hashlike

  attr_accessor :a, :b, :c, :nil_val, :false_val, :z

  def to_s
    to_hash.to_s
  end
  def ==(other_hash)
    (length == other_hash.length) &&
      all?{|k,v| v == other_hash[k] }
  end
end

MyStruct = Struct.new(:a, :b, :c, :nil_val, :false_val, :z) do
  include Gorillib::Struct::ActsAsHash
  include Gorillib::Hashlike

  def to_s
    to_hash.to_s
  end
  def inspect
    to_s
  end
  def ==(other_hash)
    (length == other_hash.length) &&
      all?{|k,v| v == other_hash[k] }
  end
end

describe Gorillib::Hashlike do
  before do
    @total = 0
    hsh = { :a  => 3,  :b  => 4, :c => nil, :nil_val => nil, :false_val => false, :z => nil }
    @hsh_symk = hsh.dup
    @hsh_strk = {} ; hsh.each{|k,v| @hsh_strk[k.to_s] = v }
    @hsh_wia   = hsh.with_indifferent_access
    @hshlike  = Foo.new.merge(@hsh_strk)
    # @hshlike = MyStruct.new(3, 4, nil, nil, false, nil) 
  end

  METHODS_TO_TEST.each do |method_to_test|
    # describe "##{method_to_test} same as for Hash" do
    #   [
    #     ['a'], ['b'], [nil], ['z'], [], ['a', 'b'], ['a', STRING_5X_PROC], ['z', STRING_5X_PROC],
    #     ['a', 30], ['b', 50], [nil, 60], [:c, 70],
    #     [TOTAL_KV_PROC], [ TOTAL_K_PROC], [ TOTAL_V_PROC],
    #     ['a', 'b', 'z'],
    #     ['a', 'b', 'a', :c, 'a'], ['z', 'a'],
    #     [VAL_GTE_4_PROC], [VAL_GTE_0_PROC], [VAL_GTE_1E6_PROC],
    #   ].each do |input|
    #     it "on #{input.inspect}" do
    #       behaves_the_same(@hsh_strk, @hshlike, method_to_test, input)
    #     end
    #   end
    # end

    describe "##{method_to_test} same as for Hash (symbol keys)" do
      [
        [:a], [:b], [nil], [:z], [], [:a, :b], [:a, STRING_5X_PROC], [:z, STRING_5X_PROC],
        [:a, 30], [:b, 50], [nil, 60], [:c, 70],
        [TOTAL_KV_PROC], [ TOTAL_K_PROC], [ TOTAL_V_PROC],
        [:a, :b, :z],
        [:a, :b, :a, :c, :a], [:z, :a],
        [VAL_GTE_4_PROC], [VAL_GTE_0_PROC], [VAL_GTE_1E6_PROC],
      ].each do |input|
        it "on #{input.inspect}" do
          behaves_the_same(@hsh_symk, @hshlike, method_to_test, input)
        end
      end
    end

    describe "##{method_to_test} same as for HashWithIndifferentAccess" do
      [
        ['b'], [:b], [:a, :b], [:a, 'b'], ['a', 'b'],
        [:b, 50], ['b', 50],
        [:a, 'b', :z],
      ].each do |input|
        it "on #{input.inspect}" do
          
          # behaves_the_same(@hsh_wia, @hshlike, method_to_test, input)
          
          # p ['reject', @hsh_symk, @hsh_symk.reject{|pr| p pr ; true }]
          # p ['reject', @hsh_wia, @hsh_wia.reject{|pr| p pr ; true }]
          # p ['reject', @hshlike, @hshlike.reject{|pr| p pr ; true }]
        end
      end
    end
  end 

  # it 'compares all methods with Hash' do
  #   (@hsh_symk.methods.sort - (Object.new.methods + METHODS_TO_TEST + [:clear, :cycle, :partition, :values_at])).should == [
  #     :assert_valid_keys, :compare_by_identity, :compare_by_identity?, :default,
  #     :default=, :default_proc, :default_proc=, :index,
  #     :nested_under_indifferent_access, :rehash, :replace, :shift,
  #     :stringify_keys, :stringify_keys!, :symbolize_keys, :symbolize_keys!,
  #     :with_indifferent_access
  #   ]
  # end
  # 
  # it 'does everything a hash can do' do
  #   (@hsh_symk.methods.sort - @hshlike.methods).should == [
  #     :assert_valid_keys, :compare_by_identity, :compare_by_identity?, :default,
  #     :default=, :default_proc, :default_proc=, :index,
  #     :nested_under_indifferent_access, :rehash, :replace, :shift,
  #     :stringify_keys, :stringify_keys!, :symbolize_keys, :symbolize_keys!,
  #     :with_indifferent_access
  #   ]
  # end
end

