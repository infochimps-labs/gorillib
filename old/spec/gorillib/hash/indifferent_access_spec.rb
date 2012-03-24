require 'gorillib/hash/indifferent_access'
require 'gorillib/hash/slice'
require 'gorillib/hash/reverse_merge'
require 'gorillib/hash/deep_merge'
require 'gorillib/hash/deep_dup'

describe Gorillib::HashWithIndifferentAccess, :hashlike_spec => true do
  class IndifferentHash < Gorillib::HashWithIndifferentAccess
  end

  class SubclassingArray < Array
  end

  class SubclassingHash < Hash
  end

  class NonIndifferentHash < Hash
    def nested_under_indifferent_access
      self
    end
  end

  before do
    @strings = { 'a' => 1, 'b' => 2 }
    @symbols = { :a  => 1, :b  => 2 }
    @mixed   = { :a  => 1, 'b' => 2 }
    @fixnums = {  0  => 1,  1  => 2 }
    if RUBY_VERSION < '1.9.0'
      @illegal_symbols = { "\0" => 1, "" => 2, [] => 3 }
    else
      @illegal_symbols = { [] => 3 }
    end
  end

  it 'symbolize_keys_for_hash_with_indifferent_access' do
    @symbols.with_indifferent_access.symbolize_keys.should be_an_instance_of(Hash)
    @symbols.with_indifferent_access.symbolize_keys.should == @symbols
    @strings.with_indifferent_access.symbolize_keys.should == @symbols
    @mixed.with_indifferent_access.symbolize_keys.should == @symbols
  end

  it 'symbolize_keys_bang_for_hash_with_indifferent_access' do
    lambda{ @symbols.with_indifferent_access.dup.symbolize_keys! }.should raise_error(NoMethodError)
    lambda{ @strings.with_indifferent_access.dup.symbolize_keys! }.should raise_error(NoMethodError)
    lambda{ @mixed.with_indifferent_access.dup.symbolize_keys! }.should raise_error(NoMethodError)
  end

  it 'symbolize_keys_preserves_keys_that_cant_be_symbolized_for_hash_with_indifferent_access' do
    @illegal_symbols.with_indifferent_access.symbolize_keys.should == @illegal_symbols
    lambda{ @illegal_symbols.with_indifferent_access.dup.symbolize_keys! }.should raise_error(NoMethodError)
  end

  it 'symbolize_keys_preserves_fixnum_keys_for_hash_with_indifferent_access' do
    @fixnums.with_indifferent_access.symbolize_keys.should == @fixnums
    lambda{ @fixnums.with_indifferent_access.dup.symbolize_keys! }.should raise_error(NoMethodError)
  end

  it 'stringify_keys_for_hash_with_indifferent_access' do
    @symbols.with_indifferent_access.stringify_keys.should be_an_instance_of(Gorillib::HashWithIndifferentAccess)
    @symbols.with_indifferent_access.stringify_keys.should == @strings
    @strings.with_indifferent_access.stringify_keys.should == @strings
    @mixed.with_indifferent_access.stringify_keys.should == @strings
  end

  it 'stringify_keys_bang_for_hash_with_indifferent_access' do
    @symbols.with_indifferent_access.dup.stringify_keys!.should be_an_instance_of(Gorillib::HashWithIndifferentAccess)
    @symbols.with_indifferent_access.dup.stringify_keys!.should == @strings
    @strings.with_indifferent_access.dup.stringify_keys!.should == @strings
    @mixed.with_indifferent_access.dup.stringify_keys!.should == @strings
  end

  it 'nested_under_indifferent_access' do
    foo = { "foo" => SubclassingHash.new.tap { |h| h["bar"] = "baz" } }.with_indifferent_access
    foo["foo"].should be_a(Gorillib::HashWithIndifferentAccess)

    foo = { "foo" => NonIndifferentHash.new.tap { |h| h["bar"] = "baz" } }.with_indifferent_access
    foo["foo"].should be_a(NonIndifferentHash)
  end

  it 'indifferent_assorted' do
    @strings = @strings.with_indifferent_access
    @symbols = @symbols.with_indifferent_access
    @mixed   = @mixed.with_indifferent_access

    @strings.__send__(:convert_key, :a).should == 'a'

    @strings.fetch('a').should == 1
    @strings.fetch(:a.to_s).should == 1
    @strings.fetch(:a).should == 1

    hashes = { :@strings => @strings, :@symbols => @symbols, :@mixed => @mixed }
    method_map = { :'[]' => 1, :fetch => 1, :values_at => [1],
      :has_key? => true, :include? => true, :key? => true,
      :member? => true }

    hashes.each do |name, hash|
      method_map.sort_by { |m| m.to_s }.each do |meth, expected|
        hash.__send__(meth, 'a').should == expected
        hash.__send__(meth, :a).should == expected
      end
    end

    @strings.values_at('a', 'b').should == [1, 2]
    @strings.values_at(:a, :b).should == [1, 2]
    @symbols.values_at('a', 'b').should == [1, 2]
    @symbols.values_at(:a, :b).should == [1, 2]
    @mixed.values_at('a', 'b').should == [1, 2]
    @mixed.values_at(:a, :b).should == [1, 2]
  end

  it 'indifferent_reading' do
    hash = Gorillib::HashWithIndifferentAccess.new
    hash["a"] = 1
    hash["b"] = true
    hash["c"] = false
    hash["d"] = nil

    hash[:a].should == 1
    hash[:b].should == true
    hash[:c].should == false
    hash[:d].should == nil
    hash[:e].should == nil
  end

  it 'indifferent_reading_with_nonnil_default' do
    hash = Gorillib::HashWithIndifferentAccess.new(1)
    hash["a"] = 1
    hash["b"] = true
    hash["c"] = false
    hash["d"] = nil

    hash[:a].should == 1
    hash[:b].should == true
    hash[:c].should == false
    hash[:d].should == nil
    hash[:e].should == 1
  end

  it 'indifferent_writing' do
    hash = Gorillib::HashWithIndifferentAccess.new
    hash[:a] = 1
    hash['b'] = 2
    hash[3] = 3

    1.should == hash['a']
    2.should == hash['b']
    1.should == hash[:a]
    2.should == hash[:b]
    3.should == hash[3]
  end

  it 'indifferent_update' do
    hash = Gorillib::HashWithIndifferentAccess.new
    hash[:a] = 'a'
    hash['b'] = 'b'

    updated_with_strings = hash.update(@strings)
    updated_with_symbols = hash.update(@symbols)
    updated_with_mixed = hash.update(@mixed)

    1.should == updated_with_strings[:a]
    1.should == updated_with_strings['a']
    2.should == updated_with_strings['b']

    1.should == updated_with_symbols[:a]
    2.should == updated_with_symbols['b']
    2.should == updated_with_symbols[:b]

    1.should == updated_with_mixed[:a]
    2.should == updated_with_mixed['b']

    [updated_with_strings, updated_with_symbols, updated_with_mixed].all?{ |h| h.keys.size == 2 }.should be_true
  end

  it 'indifferent_merging' do
    hash = Gorillib::HashWithIndifferentAccess.new
    hash[:a] = 'failure'
    hash['b'] = 'failure'

    other = { 'a' => 1, :b => 2 }

    merged = hash.merge(other)

    merged.class.should == Gorillib::HashWithIndifferentAccess
    merged[:a].should == 1
    merged['b'].should == 2

    hash.update(other)

    hash[:a].should == 1
    hash['b'].should == 2
  end

  it 'indifferent_reverse_merging' do
    hash = Gorillib::HashWithIndifferentAccess.new('some' => 'value', 'other' => 'value')
    hash.reverse_merge!(:some => 'noclobber', :another => 'clobber')
    hash[:some].should == 'value'
    hash[:another].should == 'clobber'
  end

  it 'indifferent_deleting' do
    get_hash = proc{ { :a => 'foo' }.with_indifferent_access }
    hash = get_hash.call
    'foo'.should == hash.delete(:a)
    nil.should == hash.delete(:a)
    hash = get_hash.call
    'foo'.should == hash.delete('a')
    nil.should == hash.delete('a')
  end

  it 'indifferent_to_hash' do
    # Should convert to a Hash with String keys.
    @mixed.with_indifferent_access.to_hash.should == @strings

    # Should preserve the default value.
    mixed_with_default = @mixed.dup
    mixed_with_default.default = '1234'
    roundtrip = mixed_with_default.with_indifferent_access.to_hash
    roundtrip.should == @strings
    roundtrip.default.should == '1234'
  end

  it 'indifferent_hash_with_array_of_hashes' do
    hash = { "urls" => { "url" => [ { "address" => "1" }, { "address" => "2" } ] }}.with_indifferent_access
    hash[:urls][:url].first[:address].should == "1"
  end

  it 'should_preserve_array_subclass_when_value_is_array' do
    array = SubclassingArray.new
    array << { "address" => "1" }
    hash = { "urls" => { "url" => array }}.with_indifferent_access
    hash[:urls][:url].class.should == SubclassingArray
  end

  it 'should_preserve_array_class_when_hash_value_is_frozen_array' do
    array = SubclassingArray.new
    array << { "address" => "1" }
    hash = { "urls" => { "url" => array.freeze }}.with_indifferent_access
    hash[:urls][:url].class.should == SubclassingArray
  end

  it 'stringify_and_symbolize_keys_on_indifferent_preserves_hash' do
    h = Gorillib::HashWithIndifferentAccess.new
    h[:first] = 1
    h = h.stringify_keys
    h['first'].should == 1
    h = Gorillib::HashWithIndifferentAccess.new
    h['first'] = 1
    h = h.symbolize_keys
    h[:first].should == 1
  end

  it 'to_options_on_indifferent_preserves_hash' do
    h = Gorillib::HashWithIndifferentAccess.new
    h['first'] = 1
    h.to_options!
    h['first'].should == 1
  end

  it 'indifferent_subhashes' do
    h = {'user' => {'id' => 5}}.with_indifferent_access
    ['user', :user].each{|user| [:id, 'id'].each{|id| h[user][id].should == 5 }}

    h = {:user => {:id => 5}}.with_indifferent_access
    ['user', :user].each{|user| [:id, 'id'].each{|id| h[user][id].should == 5 }}
  end

  it 'indifferent_duplication' do
    # Should preserve default value
    h = Gorillib::HashWithIndifferentAccess.new
    h.default = '1234'
    h.dup.default.should == h.default

    # Should preserve class for subclasses
    h = IndifferentHash.new
    h.dup.class.should == h.class
  end

  it 'assorted_keys_not_stringified' do
    original = {Object.new => 2, 1 => 2, [] => true}
    indiff = original.with_indifferent_access
    indiff.keys.any?{|k| k.kind_of? String }.should_not be_true
  end

  it 'deep_merge' do
    hash_1 = { :a => "a", :b => "b", :c => { :c1 => "c1", :c2 => "c2", :c3 => { :d1 => "d1" } } }
    hash_2 = { :a => 1, :c => { :c1 => 2, :c3 => { :d2 => "d2" } } }
    expected = { :a => 1, :b => "b", :c => { :c1 => 2, :c2 => "c2", :c3 => { :d1 => "d1", :d2 => "d2" } } }
    hash_1.deep_merge(hash_2).should == expected

    hash_1.deep_merge!(hash_2)
    hash_1.should == expected
  end

  it 'deep_merge_on_indifferent_access' do
    hash_1 = Gorillib::HashWithIndifferentAccess.new({ :a => "a", :b => "b", :c => { :c1 => "c1", :c2 => "c2", :c3 => { :d1 => "d1" } } })
    hash_2 = Gorillib::HashWithIndifferentAccess.new({ :a => 1, :c => { :c1 => 2, :c3 => { :d2 => "d2" } } })
    hash_3 = { :a => 1, :c => { :c1 => 2, :c3 => { :d2 => "d2" } } }
    expected = { "a" => 1, "b" => "b", "c" => { "c1" => 2, "c2" => "c2", "c3" => { "d1" => "d1", "d2" => "d2" } } }
    hash_1.deep_merge(hash_2).should == expected
    hash_1.deep_merge(hash_3).should == expected

    hash_1.deep_merge!(hash_2)
    hash_1.should == expected
  end

  it 'deep_dup' do
    hash = { :a => { :b => 'b' } }
    dup = hash.deep_dup
    dup[:a][:c] = 'c'
    hash[:a][:c].should == nil
    dup[:a][:c].should == 'c'
  end

  it 'deep_dup_initialize' do
    zero_hash = Hash.new 0
    hash = { :a => zero_hash }
    dup = hash.deep_dup
    dup[:a][44].should == 0
  end

  it 'store_on_indifferent_access' do
    hash = Gorillib::HashWithIndifferentAccess.new
    hash.store(:test1, 1)
    hash.store('test1', 11)
    hash[:test2] = 2
    hash['test2'] = 22
    expected = { "test1" => 11, "test2" => 22 }
    hash.should == expected
  end

  it 'indifferent_slice' do
    original = { :a => 'x', :b => 'y', :c => 10 }.with_indifferent_access
    expected = { :a => 'x', :b => 'y' }.with_indifferent_access

    [['a', 'b'], [:a, :b]].each do |keys|
      # Should return a new hash with only the given keys.
      original.slice(*keys).should == expected
      original.should_not == expected
    end
  end

  it 'indifferent_slice_inplace' do
    original = { :a => 'x', :b => 'y', :c => 10 }.with_indifferent_access
    expected = { :c => 10 }.with_indifferent_access

    [['a', 'b'], [:a, :b]].each do |keys|
      # Should replace the hash with only the given keys.
      copy = original.dup
      copy.slice!(*keys).should == expected
    end
  end

  it 'indifferent_slice_access_with_symbols' do
    original = {'login' => 'bender', 'password' => 'shiny', 'stuff' => 'foo'}
    original = original.with_indifferent_access

    slice = original.slice(:login, :password)

    slice[:login].should == 'bender'
    slice['login'].should == 'bender'
  end

  it 'should_use_default_value_for_unknown_key' do
    hash_wia = Gorillib::HashWithIndifferentAccess.new(3)
    hash_wia[:new_key].should == 3
  end

  it 'should_use_default_value_if_no_key_is_supplied' do
    hash_wia = Gorillib::HashWithIndifferentAccess.new(3)
    hash_wia.default.should == 3
  end

  it 'should_nil_if_no_default_value_is_supplied' do
    hash_wia = Gorillib::HashWithIndifferentAccess.new
    hash_wia.default.should be_nil
  end

  it 'should_return_dup_for_with_indifferent_access' do
    hash_wia = Gorillib::HashWithIndifferentAccess.new
    hash_wia.with_indifferent_access.should == hash_wia
    hash_wia.with_indifferent_access.should_not equal(hash_wia)
  end

  it 'should_copy_the_default_value_when_converting_to_hash_with_indifferent_access' do
    hash = Hash.new(3)
    hash_wia = hash.with_indifferent_access
    hash_wia.default.should == 3
  end

end
