require File.dirname(__FILE__)+'/spec_helper'
require 'gorillib/hashlike'
require File.dirname(__FILE__)+'/support/hashlike_via_delegation'

describe Gorillib::Hashlike do
  before do
    @total = 0
    @hshlike  = InternalHash.new.merge({ :a  => 100,  :b  => 200, 'c' => 300, :nil_val => nil, :false_val => false, :z => nil })
  end

  describe '#[] and #[]= and #store' do
    it 'stores and retrieves values' do
      @hshlike[:a].should == 100
      @hshlike[:a] = 999
      @hshlike[:a].should == 999
    end

    it 'treats string and symbol keys as distinct' do
      @hshlike['c'].should == 300
      @hshlike[:c].should be_nil
      @hshlike[:c] = 400
      @hshlike['c'].should == 300
      @hshlike[:c].should  == 400
    end

    it 'allows nil, Object, and other non-stringy keys' do
      @hshlike[300] = :i_haz_num ; @hshlike[300].should == :i_haz_num
      @hshlike[nil] = :i_haz_nil ; @hshlike[nil].should == :i_haz_nil
      obj = Object.new
      @hshlike[obj] = :i_haz_obj ; @hshlike[obj].should == :i_haz_obj
    end

    it 'returns nil on a missing key' do
      @hshlike[:missing_key].should == nil
    end
  end

  describe '#delete' do
    it 'removes the key/value association'
    it 'does not include? key after deleting'
  end

  describe '#keys' do
    it 'lists keys, even where values are nil'
    it 'does not include a deleted key'
  end

  describe '#each' do
    it 'calls block once for each key/value pair in hsh'
    it 'with no block, returns an enumerator'
  end

  describe '#each_pair' do
    it 'calls block once for each key/value pair in hsh'
    it 'with no block, returns an enumerator'
  end

  describe '#each_key' do
    it 'calls block once for each key in hsh'
    it 'with no block, returns an enumerator'
  end

  describe '#each_value' do
    it 'calls block once for each key in hsh, passing the value as parameter'
    it 'calls block on each value even when nil, false, empty or duplicate'
    it 'with no block, returns an enumerator'
  end

  describe '#values' do
    it 'returns a new array populated with the values from hsh'
  end

  describe '#values_at' do
    it 'returns an array containing the values associated with the given keys'
    it 'returns duplicate keys or missing keys in given slot'
  end

  describe '#length' do
    it 'returns the number of key/value pairs in the hashlike'
  end

  describe '#size' do
    it 'returns the number of key/value pairs in the hashlike'
  end

  [:has_key?, :include?, :key?, :member?].each do |method_to_test|
    describe method_to_test do
      it 'returns true if the given key is present, false otherwise'
      it 'treats symbol and string keys as distinct'
      it 'is true for nil, empty or false keys'
      it 'something something convert_key'
    end
  end

  [:has_value?, :value?].each do |method_to_test|
    describe method_to_test do
      it 'returns true if the given value is present, false otherwise'
      it 'is true for nil, empty or false values'
    end
  end

  describe '#fetch' do
    it 'returns a value from the hashlike for the given key'
    describe 'on a missing key' do
      it 'with no other arguments, raises a +KeyError+ exception'
      it 'if block given, runs the block with the given key and returns its value'
      it 'if default given, returns the default arg'
      it 'if block and default are both given, issues a warning and runs the block'
    end
  end

  describe '#key' do
    it 'searches for an entry with the given val, returning the corresponding key; if not found, returns nil'
    it 'returns the first matching key/value pair'
  end

  describe '#assoc' do
    it 'searches for an entry with the given key, returning the corresponding key/value pair; if not found, returns nil'
  end

  describe '#rassoc' do
    it 'searches for an entry with the given val, returning the corresponding key/value pair; if not found, returns nil'
  end

  describe '#empty?' do
    it 'returns true if the hashlike contains no key-value pairs, false otherwise'
  end

  [:update, :merge!, :merge].each do |method_to_test|
  describe method_to_test do
    it 'adds the contents of another hash'
    describe 'with no block' do
      it 'overwrites entries in this hash with those from the other hash'
    end
    describe 'with a block' do
      it 'sets the valu'
      it 'passes params in the order key, current val, other hash val'
    end
    it 'raises a type error unless given hash responds to each_pair'
  end
  end

  describe 'update' do
    it 'updates in-place, returning self'
  end
  describe '#merge!' do
    it 'updates in-place, returning self'
  end

  describe '#merge' do
    it 'does not alter state, returning a new object'
  end

  describe '#reject!' do
    it 'deletes every key-value pair for which the +block+ evaluates truthy'
    it 'modifies in-place ; returns self (if changes were made) or nil (if unchanged)'
    it 'adapts to the arity of the block'
    it 'with no block, returns an enumerator'
  end

  describe '#select!' do
    it 'deletes every key-value pair for which the +block+ evaluates falsy'
    it 'modifies in-place ; returns self (if changes were made) or nil (if unchanged)'
    it 'adapts to the arity of the block'
    it 'with no block, returns an enumerator'
  end

  describe '#delete_if' do
    it 'deletes every key-value pair for which the +block+ evaluates falsy'
    it 'modifies in-place and returns self'
    it 'adapts to the arity of the block'
    it 'with no block, returns an enumerator'
  end

  describe '#keep_if' do
    it 'deletes every key-value pair for which the +block+ evaluates falsy'
    it 'modifies in-place and returns self'
    it 'adapts to the arity of the block'
    it 'with no block, returns an enumerator'
  end

  describe '#reject' do
    it 'returns a new hshlike that excludes every key-value pair for which the +block+ evaluates truthy'
    it 'returns same class as original'
    it 'adapts to the arity of the block'
    it 'with no block, returns an enumerator'
  end

  describe '#select' do
    it 'returns a new hshlike that excludes every key-value pair for which the +block+ evaluates falsy'
    it 'returns same class as original'
    it 'adapts to the arity of the block'
    it 'with no block, returns an enumerator'
  end

  describe '#clear' do
    it 'removes all key/value pairs'
  end

  describe '#to_hash' do
    it 'returns a hash with each key set to its associated value'
  end

  describe '#invert' do
    it 'returns a new hash using the values as keys, and the keys as values'
    it 'with duplicate values, the result will contain only one of them as a key'
    it 'returns a Hash, not a self.class'
  end

  describe '#flatten' do
    it 'needs specs'
  end

  it 'includes enumerable by default'
  it 'does not include enumerable if already included'
  it 'defines iterator by default'
  it 'does not define iterators if #each is already defined'

  it 'does not implement the default, rehash, replace, compare_by or shift families of methods'

end
