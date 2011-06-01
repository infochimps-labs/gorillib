require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/hashlike'
require 'gorillib/struct/acts_as_hash'
require GORILLIB_ROOT_DIR('spec/support/hashlike_via_delegation')
require GORILLIB_ROOT_DIR('spec/support/hashlike_fuzzing_helper')
require GORILLIB_ROOT_DIR('spec/support/hashlike_struct_helper')

describe Gorillib::Struct::ActsAsHash do

  before do
    @total = 0
    @base_hsh
    @hshlike                 = StructUsingHashlike.new.merge(HashlikeHelper::BASE_HSH.dup)
    @empty_hshlike           = StructUsingHashlike.new
    @hshlike_with_array_vals = StructUsingHashlike.new.merge(HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.dup)
    #
    @hshlike_subklass        = Class.new(StructUsingHashlike)
    @hshlike_subklass_inst   = @hshlike_subklass.new.merge(HashlikeHelper::BASE_HSH.dup)
  end

  it 'built test objects correctly' do
    @hshlike_subklass      .should     <  @hshlike.class
    @hshlike_subklass      .should_not == @hshlike.class
    @hshlike_subklass_inst .should     be_a(StructUsingHashlike)
    @hshlike_subklass_inst .should     be_a(@hshlike_subklass)
    @hshlike_subklass_inst .should_not be_an_instance_of(StructUsingHashlike)
    @hshlike               .should_not be_a(@hshlike_subklass)
    @hshlike               .should     be_an_instance_of(StructUsingHashlike)
  end

  # ===========================================================================
  #
  # Fundamental behavior

  describe '#[] and #[]= and #store' do
    it 'stores and retrieves values' do
      @hshlike[:a].should == 100
      @hshlike[:a] = 999
      @hshlike[:a].should == 999
    end

    it 'treats string and symbol keys as interchangeable' do
      @hshlike['c'].should  == 300
      @hshlike[:c].should   == 300
      @hshlike['c'] = 999
      @hshlike['c'].should == 999
      @hshlike[:c].should  == 999
    end

    it 'does not allow nil, Object, and other non-stringy keys' do
      lambda{ @hshlike[300] = :i_haz_num  }.should raise_error(IndexError, /offset 300 too large for struct/)
      lambda{ @hshlike[nil] = :i_haz_nil  }.should raise_error(TypeError, "no implicit conversion from nil to integer")
      obj = Object.new
      lambda{ @hshlike[obj] = :i_haz_obj  }.should raise_error(TypeError, "can't convert Object into Integer")
    end

    it 'raises an error on a missing key' do
      lambda{ @hshlike[:missing_key] }.should raise_error(NameError, "no member 'missing_key' in struct")
    end
  end

  describe '#delete' do
    it 'removes the key/value association and returns the value' do
      @hshlike.delete(:a).should == 100
      @hshlike.delete(:is_missing).should be_nil
      @hshlike.delete(:false_val).should == false
      @hshlike.should be_hash_eql({ :b  => 200, :c => 300, :nil_val => nil })
    end
    describe 'with optional code block' do
      it 'returns the value of executing the block (passing in the key)' do
        set_in_block = nil
        ret_val = @hshlike.delete(:is_missing){|k| set_in_block = "got: #{k}" ; "hello!" }
        set_in_block.should == "got: is_missing"
        ret_val.should == "hello!"
      end
    end
    it 'will have a nil value but will still include? key after deleting' do
      @hshlike.should include(:a)
      @hshlike.delete(:a)
      @hshlike.should include(:a)
      @hshlike[:a].should be_nil
    end
  end

  describe '#keys' do
    it 'lists keys, even where values are nil' do
      @hshlike.keys.should be_array_eql([:a, :b, :c, :nil_val, :false_val, :new_key])
      @hshlike[:nil_val].should be_nil
    end
    it 'is the full list of members, even when nothing has been set' do
      @empty_hshlike.keys.should be_array_eql([:a, :b, :c, :nil_val, :false_val, :new_key])
    end
    it 'is the symbolized members list' do
      @empty_hshlike.keys.map(&:to_s).should == @empty_hshlike.members.map(&:to_s)
    end
  end

  # ===========================================================================
  #
  # Iteration

  describe '#each' do
    describe 'with block' do
      it 'calls block once for each *val* in hsh !like array not hash!' do
        seen_arg1 = []
        seen_arg2 = []
        @hshlike.each{|arg1,arg2| seen_arg1 << arg1 ; seen_arg2 << arg2 }
        seen_arg1.should be_array_eql([100, 200, 300, nil, false, nil])
        seen_arg2.should be_array_eql([nil, nil, nil, nil, nil,   nil])
      end
      it 'with arity 1, returns keys only' do
        seen_args = []
        @hshlike.each{|arg| seen_args << arg }
        seen_args.should be_array_eql([100, 200, 300, nil, false, nil])
      end
      it 'handles array keys' do
        seen_args = []
        @hshlike_with_array_vals.each{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[100, 111, nil], [200, nil, nil], [1, [2, 3, [4, 5, 6]], nil], [nil, nil, nil], [nil, nil, nil], [nil, nil, nil]])
        seen_args = []
        @hshlike_with_array_vals.each{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[100, nil, 111], [200, nil, nil], [1, nil, [2, 3, [4, 5, 6]]], [nil, nil, nil], [nil, nil, nil], [nil, nil, nil]])
      end
      it 'returns self' do
        ret_val = @hshlike.each{|k,v| 3 }
        ret_val.should equal(@hshlike)
      end
    end
    describe 'with no block' do
      it('returns an enumerator'){ @hshlike.each.should enumerate_method(@hshlike, :each) }
    end
  end

  describe '#each_pair' do
    describe 'with block' do
      it 'calls block once for each key/value pair in hsh' do
        seen_arg1 = []
        seen_arg2 = []
        @hshlike.each_pair{|arg1,arg2| seen_arg1 << arg1 ; seen_arg2 << arg2 }
        seen_arg1.should be_array_eql([:a,  :b,  :c, :nil_val, :false_val, :new_key ])
        seen_arg2.should be_array_eql([100, 200, 300, nil,      false,      nil      ])
      end
      it 'with arity 1, returns array pairs' do
        seen_args = []
        @hshlike.each_pair{|arg| seen_args << arg }
        # seen_args.should be_array_eql([[:a, 100], [:b, 200], [:c, 300], [:nil_val, nil], [:false_val, false], [:new_key, nil]])
        seen_args.should be_array_eql([:a, :b, :c, :nil_val, :false_val, :new_key])
      end
      it 'handles array vals' do
        seen_args = []
        @hshlike_with_array_vals.each_pair{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[:a, [100, 111], nil], [:b, 200, nil], [:c, [1, [2, 3, [4, 5, 6]]], nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
        seen_args = []
        @hshlike_with_array_vals.each_pair{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[:a, nil, [100, 111]], [:b, nil, 200], [:c, nil, [1, [2, 3, [4, 5, 6]]]], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
      end
      it 'returns self' do
        ret_val = @hshlike.each_pair{|k,v| 3 }
        ret_val.should equal(@hshlike)
      end
    end
    describe 'with no block' do
      it('returns an enumerator'){ @hshlike.each_pair.should enumerate_method(@hshlike, :each_pair) }
    end
  end

  describe '#each_key' do
    describe 'with block' do
      it 'calls block once for each key in hsh' do
        seen_keys = []
        @hshlike.each_key{|k| seen_keys << k }
        seen_keys.should be_array_eql([:a,  :b,  :c, :nil_val, :false_val, :new_key ])
      end
      it 'handles array keys and extra arity' do
        seen_args = []
        @hshlike.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil] ])
        seen_args = []
        @hshlike_with_array_vals.each_key{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
        seen_args = []
        @hshlike_with_array_vals.each_key{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[:a, nil, nil], [:b, nil, nil], [:c, nil, nil], [:nil_val, nil, nil], [:false_val, nil, nil], [:new_key, nil, nil]])
      end
      it 'returns self' do
        ret_val = @hshlike.each_key{|k,v| 3 }
        ret_val.should equal(@hshlike)
      end
    end
    describe 'with no block' do
      it('returns an enumerator'){ @hshlike.each_key.should enumerate_method(@hshlike, :each_key) }
    end
  end

  describe '#each_value' do
    describe 'with block' do
      it 'calls block once for each key in hsh, passing the value as parameter' do
        seen_vals = []
        @hshlike.each_value{|k| seen_vals << k }
        seen_vals.should be_array_eql([100, 200, 300, nil, false, nil])
      end
      it 'calls block on each value even when nil, false, empty or duplicate' do
        @hshlike[:a]       = 999
        @hshlike[:new_key] = 999
        seen_vals = []
        @hshlike.each_value{|k| seen_vals << k }
        seen_vals.should be_array_eql([999, 200, 300, nil, false, 999 ])
      end
      it 'handles array vals and extra arity' do
        seen_args = []
        @hshlike.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[100, nil, nil], [200, nil, nil], [300, nil, nil], [nil, nil, nil], [false, nil, nil], [nil, nil, nil]])
        seen_args = []
        @hshlike_with_array_vals.each_value{|arg1, arg2, arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[100, 111, nil], [200, nil, nil], [1, [2, 3, [4, 5, 6]], nil], [nil, nil, nil], [nil, nil, nil], [nil, nil, nil]])
        seen_args = []
        @hshlike_with_array_vals.each_value{|(arg1, arg2), arg3| seen_args << [arg1, arg2, arg3] }
        seen_args.should be_array_eql([[100, nil, 111], [200, nil, nil], [1, nil, [2, 3, [4, 5, 6]]], [nil, nil, nil], [nil, nil, nil], [nil, nil, nil]])
      end
      it 'returns self' do
        ret_val = @hshlike.each_value{|k,v| 3 }
        ret_val.should equal(@hshlike)
      end
    end
    describe 'with no block' do
      it('returns an enumerator'){ @hshlike.each_value.should enumerate_method(@hshlike, :each_value) }
    end
  end

  # ===========================================================================
  #
  # Retrieval and Membership

  describe '#values' do
    it 'returns a new array populated with the values from hsh' do
      @hshlike.values.should be_array_eql([100, 200, 300, nil, false, nil])
    end
  end

  describe '#values_at' do
    it 'takes positional, not symbol args' do
      @hshlike.values_at(1, 0, 3, 5).should == [200, 100, nil, nil]
      @hshlike.values_at(1, 1, 5, 3, 2, 5).should == [200, 200, nil, nil, 300, nil]
    end
  end

  describe '#values_of' do
    it 'returns an array containing the values associated with the given keys' do
      @hshlike.values_of(:b, :a, :z, :nil_val).should == [200, 100, nil, nil]
    end
    it 'returns duplicate keys or missing keys in given slot' do
      @hshlike.values_of(:b, :b, :new_key, :nil_val, :c, :c).should == [200, 200, nil, nil, 300, 300]
    end
  end

  describe '#length' do
    it 'returns the number of key/value pairs in the hashlike' do
      @hshlike.length.should == 6
      @hshlike.length.should == @hshlike.members.length
    end
    it 'is always the length of #members, regardless of contents' do
      @empty_hshlike.length.should == 6
    end
  end

  describe '#size' do
    it 'returns the number of key/value pairs in the hashlike' do
      @hshlike.size.should == 6
      @hshlike.size.should == @hshlike.members.size
    end
    it 'is always the length of #members, regardless of contents' do
      @empty_hshlike.size.should == 6
    end
  end

  [:has_key?, :include?, :key?, :member?].each do |method_to_test|
    describe "##{method_to_test}" do
      it 'returns true if the given key is present, false otherwise' do
        @hshlike.should evaluate_to_true(method_to_test, :a)
        @hshlike.should_not evaluate_to_true(method_to_test, :i_am_missing)
      end
      it 'treats symbol and string keys as equivalent' do
        @hshlike.should     evaluate_to_true(method_to_test, :a)
        @hshlike.should     evaluate_to_true(method_to_test, 'a')
        @hshlike.should     evaluate_to_true(method_to_test, :c)
        @hshlike.should     evaluate_to_true(method_to_test, 'c')
      end
      it 'is true even if value is nil, empty or false' do
        @hshlike.should evaluate_to_true(method_to_test, :nil_val)
        @hshlike.should evaluate_to_true(method_to_test, :false_val)
      end
      it 'something something convert_key'
    end
  end

  [:has_value?, :value?].each do |method_to_test|
    describe "##{method_to_test}" do
      it 'returns true if the given value is present, false otherwise' do
        @hshlike.should evaluate_to_true(method_to_test, 100)
        @hshlike.should_not evaluate_to_true(method_to_test, :i_am_missing)
      end
      it 'is true even if key or value is nil, empty or false values' do
        @hshlike.should be_hash_eql({:a=>100, :b=>200, :c=>300, :nil_val=>nil, :false_val=>false })
        @hshlike.should evaluate_to_true(method_to_test, nil)
        @hshlike.should evaluate_to_true(method_to_test, false)
      end
      it 'something something convert_key'
    end
  end

  describe '#fetch' do
    it 'returns a value from the hashlike for the given key' do
      @hshlike.fetch(:a).should       == 100
      @hshlike.fetch(:c).should      == 300
      @hshlike.fetch(:nil_val).should == nil
    end
    describe 'on a missing key' do
      it 'with no other arguments, raises a +KeyError+ exception' do
        lambda{ @hshlike.fetch(:i_am_missing) }.should raise_error(KeyError, 'key not found: :i_am_missing')
      end
      it 'if block given, runs the block with the given key and returns its value' do
        set_in_block = nil
        ret_val = @hshlike.fetch(:is_missing){|k| set_in_block = "got: #{k}" ; "hello!" }
        ret_val.should      == "hello!"
        set_in_block.should == "got: is_missing"
      end
      it 'if default given, returns the default arg' do
        ret_val = @hshlike.fetch(:is_missing, :returned_as_default)
        ret_val.should      == :returned_as_default
      end
      it 'if block and default are both given, issues a warning and runs the block' do
        set_in_block = nil
        ret_val = @hshlike.fetch(:is_missing, :spurious_default){|k| set_in_block = "got: #{k}" ; "hello!" }
        ret_val.should      == "hello!"
        set_in_block.should == "got: is_missing"
      end
    end
    it 'something something convert_key'
  end

  describe '#key' do
    it 'searches for an entry with the given val, returning the corresponding key; if not found, returns nil' do
      @hshlike.key(100).should == :a
      @hshlike.key(300).should == :c
      @hshlike.key(nil).should == :nil_val
      @hshlike.key(:i_am_missing).should be_nil
    end
    it 'returns the first matching key/value pair' do
      @hshlike[:a] = 999
      @hshlike[:new_key] = 999
      @hshlike.key(999).should == :a
    end
  end

  describe '#assoc' do
    it 'searches for an entry with the given key, returning the corresponding key/value pair' do
      @hshlike.assoc(:a).should       == [:a,  100]
      @hshlike.assoc(:nil_val).should == [:nil_val, nil]
    end
    it 'returns nil if missing' do
      @hshlike.assoc(:i_am_missing).should be_nil
    end
    it 'something something convert_key'
  end

  describe '#rassoc' do
    it 'searches for an entry with the given val, returning the corresponding key/value pair' do
      @hshlike.rassoc(100).should == [:a,  100]
      @hshlike.rassoc(300).should == [:c, 300]
      @hshlike.rassoc(nil).should == [:nil_val, nil]
    end
    it 'returns nil if missing' do
      @hshlike.rassoc(:i_am_missing).should be_nil
    end
  end

  describe '#empty?' do
    it 'returns true if the hashlike contains no key-value pairs, false otherwise' do
      @empty_hshlike.empty?.should == true
      @hshlike.empty?.should_not   == true
    end
  end

  # ===========================================================================
  #
  # Update, merge!, merge

  shared_examples_for :merging_method_fixed_keys do |method_to_test|
    describe 'with a block' do
      it 'sets the value for colliding keys by evaluating the block' do
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :nil_val => "here", :new_key => "zzz" }) do |key, other_val, hsh_val|
          "key: '#{key.inspect}', other_val: '#{other_val.inspect}', hsh_val: '#{hsh_val.inspect}'"
        end
        ret_val.should be_hash_eql({
            :a         => %Q{key: ':a', other_val: '"aaa"', hsh_val: '100'},
            :b         => 200,
            :c         => 300,
            :nil_val   => %Q{key: ':nil_val', other_val: '"here"', hsh_val: 'nil'},
            :false_val => false,
            :new_key   => %Q{key: ':new_key', other_val: '"zzz"', hsh_val: 'nil'},
          })
      end
      it 'passes params |key, current val, other hash val|' do
        seen_args = []
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :nil_val => "here", :new_key => "zzz" }) do |key, other_val, hsh_val|
          seen_args << [key, other_val, hsh_val]
          3
        end
        ret_val.should be_hash_eql({ :a => 3, :b => 200, :c => 300, :nil_val => 3, :false_val => false, :new_key => 3 })
        seen_args.should be_array_eql([ [:a, "aaa", 100], [:nil_val, "here", nil], [:new_key, "zzz", nil] ])
      end
      it 'calls the block even if colliding keys have same value' do
        seen_args = []
        ret_val = @hshlike.send(method_to_test, {:a => "aaa", :b => 200, :new_key => "zzz" }) do |key, other_val, hsh_val|
          seen_args << [key, other_val, hsh_val]
          3
        end
        ret_val.should be_hash_eql({ :a => 3, :b => 3, :c => 300, :nil_val => nil, :false_val => false, :new_key => 3 })
        seen_args.should be_array_eql([ [:a, "aaa", 100], [:b, 200, 200], [:new_key, "zzz", nil] ])
      end
    end
  end

  describe 'update' do
    it_should_behave_like :merging_method, :update
    it_should_behave_like :merging_method_fixed_keys, :update
    it 'updates in-place, returning self' do
      ret_val = @hshlike.update({:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should equal(@hshlike)
      @hshlike.should be_hash_eql({:a=>"aaa", :b=>200, :c=>300, :nil_val=>"here", :false_val=>false, :new_key=>"zzz"})
    end
  end

  describe '#merge!' do
    it_should_behave_like :merging_method, :merge!
    it_should_behave_like :merging_method_fixed_keys, :merge!
    it 'updates in-place, returning self' do
      ret_val = @hshlike.merge!({:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should equal(@hshlike)
      @hshlike.should be_hash_eql({:a=>"aaa", :b=>200, :c=>300, :nil_val=>"here", :false_val=>false, :new_key=>"zzz"})
    end
  end

  describe '#merge' do
    it_should_behave_like :merging_method, :merge
    it_should_behave_like :merging_method_fixed_keys, :merge
    it 'does not alter state, returning a new object' do
      ret_val = @hshlike.merge({:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should_not equal(@hshlike)
      @hshlike.should be_hash_eql({:a=>100,   :b=>200, :c=>300, :nil_val=>nil,    :false_val=>false })
      ret_val.should  be_hash_eql({:a=>"aaa", :b=>200, :c=>300, :nil_val=>"here", :false_val=>false, :new_key=>"zzz"})
    end
    it 'returns an object of same class' do
      ret_val = @hshlike_subklass_inst.merge({:a => "aaa", :b => 200, :nil_val => "here", :new_key => "zzz" })
      ret_val.should be_a(@hshlike_subklass)
    end
  end

  # ===========================================================================
  #
  # Filters

  shared_examples_for :hashlike_filter_fixed_keys do |method_to_test|
    it 'passes every key-value pair to block' do
      seen_args = []
      ret_val = @hshlike.send(method_to_test){|key,val| seen_args << [key, val] ; val && (val.to_i > 150) }
      #
      seen_args.should be_array_eql([[:a, 100], [:b, 200], [:c, 300], [:nil_val, nil], [:false_val, false], [:new_key, nil]])
    end
    it 'adapts to the arity of the block' do
      seen_args = []
      ret_val = @hshlike.send(method_to_test){|arg| seen_args << [arg] ; @hshlike[arg] && (@hshlike[arg].to_i > 150) }
      #
      seen_args.should be_array_eql([[:a], [:b], [:c], [:nil_val], [:false_val], [:new_key]])
    end
    describe 'with no block' do
      it('returns an enumerator'){ @hshlike.send(method_to_test).should enumerate_method(@hshlike, method_to_test) }
    end
  end

  describe '#reject!' do
    it_should_behave_like :hashlike_filter_fixed_keys,  :reject!
    it_should_behave_like :rejection_filter, :reject!
    it_should_behave_like :filter_modifies_self_returns_nil_if_unchanged, :reject!, false
  end

  describe '#select!' do
    it_should_behave_like :hashlike_filter_fixed_keys,  :select!
    it_should_behave_like :selection_filter, :select!
    it_should_behave_like :filter_modifies_self_returns_nil_if_unchanged, :select!, true
  end

  describe '#delete_if' do
    it_should_behave_like :hashlike_filter_fixed_keys,  :delete_if
    it_should_behave_like :rejection_filter, :delete_if
    it_should_behave_like :filter_modifies_self_returns_self, :delete_if, false
  end

  describe '#keep_if' do
    it_should_behave_like :hashlike_filter_fixed_keys,  :keep_if
    it_should_behave_like :selection_filter, :keep_if
    it_should_behave_like :filter_modifies_self_returns_self, :keep_if, true
  end

  # describe '#reject' do
  #   it_should_behave_like :hashlike_filter_fixed_keys,  :select
  #   it_should_behave_like :selection_filter, :select
  #   it_should_behave_like :filter_does_not_modify_self_returns_same_class, :reject, false
  # end
  #
  # describe '#select' do
  #   it_should_behave_like :hashlike_filter_fixed_keys,  :select
  #   it_should_behave_like :selection_filter, :select
  #   it_should_behave_like :filter_does_not_modify_self_returns_same_class, :select, true
  # end

  describe '#clear' do
    it 'removes all key/value pairs' do
      ret_val = @hshlike.clear
      ret_val.should be_hash_eql(@empty_hshlike)
      ret_val.should be_empty
      @hshlike.should be_empty
    end
  end

  # ===========================================================================
  #
  # Conversion

  describe '#to_hash' do
    it 'returns a new Hash with each key set to its associated value' do
      ret_val = @hshlike.to_hash
      ret_val.should be_an_instance_of(Hash)
      ret_val.should == {:a=>100, :b=>200, :c=>300, :nil_val=>nil, :false_val=>false, :new_key=>nil}
    end
  end

  if (RUBY_VERSION >= '1.9')
    describe '#invert' do
      it 'returns a new Hash using the values as keys, and the keys as values' do
        ret_val = @hshlike.invert
        ret_val.should == { 100 => :a, 200 => :b, 300 => :c, nil => :new_key, false => :false_val }
      end
      it 'with duplicate values, the result will contain only one of them as a key' do
        @hshlike[:a]       = 999
        @hshlike[:new_key] = 999
        @hshlike.invert.should == { 999 => :new_key, 200 => :b, 300 => :c, nil => :nil_val, false => :false_val }
      end
      it 'returns a Hash, not a self.class' do
        ret_val = @hshlike.invert
        ret_val.should be_an_instance_of(Hash)
      end
    end

    describe '#flatten' do
      it 'with no arg returns a one-dimensional flattening' do
        ret_val     = @hshlike_with_array_vals.flatten
        ret_val.should == [  :a, [100, 111],  :b, 200,    :c, [1, [2, 3, [4, 5, 6]]],   :nil_val, nil, :false_val, nil, :new_key, nil ]
      end
      it 'with no arg is same as level = 1' do
        @hshlike_with_array_vals.flatten(1).should == @hshlike_with_array_vals.flatten
      end
      it 'with level == nil, returns a complete flattening' do
        ret_val     = @hshlike_with_array_vals.flatten(nil)
        ret_val.should == [  :a,  100, 111,    :b,  200,  :c, 1,  2, 3,  4, 5, 6,       :nil_val, nil, :false_val, nil, :new_key, nil ]
      end
      it 'with an arg, flattens to that level (0)' do
        ret_val     = @hshlike_with_array_vals.flatten(0)
        ret_val.should == [ [:a, [100, 111]], [:b, 200], [:c, [1, [2, 3, [4, 5, 6]]]], [:nil_val, nil], [:false_val, nil], [:new_key, nil]]
      end
      it 'with an arg, flattens to that level (3)' do
        ret_val     = @hshlike_with_array_vals.flatten(3)
        ret_val.should == [  :a,  100, 111,    :b, 200,   :c, 1,  2, 3, [4, 5, 6],      :nil_val, nil, :false_val, nil, :new_key, nil ]
      end
      it 'with an arg, flattens to that level (4)' do
        ret_val     = @hshlike_with_array_vals.flatten(4)
        ret_val.should == [  :a,  100, 111,    :b, 200,   :c, 1,  2, 3,  4, 5, 6,       :nil_val, nil, :false_val, nil, :new_key, nil ]
        ret_val.should == @hshlike_with_array_vals.flatten(999)
      end
    end
  end

  # ===========================================================================
  #
  # Method Decoration

  describe 'including Hashlike' do
    module CollidesWithEnumerable ; def map() 3 ; end ; def keys(); [] ; end ; end
    it 'includes enumerable by default' do
      foo_class = Class.new(Object) do
        include CollidesWithEnumerable
        include Gorillib::Hashlike
      end
      #
      foo_class.should include(Enumerable)
      # Enumerable's map method won
      foo_class.new.first.should be_nil
    end
    it 'does not include enumerable if already included' do
      foo_class = Class.new(Object) do
        include Enumerable
        include CollidesWithEnumerable
        include Gorillib::Hashlike
      end
      #
      foo_class.should include(Enumerable)
      # Enumerable wasn't reincluded, so CollidesWithEnumerable's 'map method won
      foo_class.new.map.should == 3
    end
    it 'defines iterator by default' do
      foo_class = Class.new(Object) do
        include Gorillib::Hashlike
      end
      foo_class.should include(Gorillib::Hashlike::EnumerateFromKeys)
      [:each, :each_pair, :length, :values, :values_at].each{|meth| foo_class.should be_method_defined(meth) }
    end
    it 'does not define iterators if #each_pair is already defined' do
      foo_class = Class.new(Object) do
        def each_pair() 3 ; end
        def length() 3 ; end
        include Gorillib::Hashlike
      end
      foo_class.should_not include(Gorillib::Hashlike::EnumerateFromKeys)
      foo_class                                         .should     be_method_defined(:each_pair)
      [:each, :values, :values_at].each{|meth| foo_class.should_not be_method_defined(meth) }
    end
    it 'does not implement the default, rehash, replace, compare_by or shift families of methods' do
      ({}.methods.map(&:to_sym) -
        (@hshlike.methods.map(&:to_sym) +
          [:compare_by_identity, :compare_by_identity?,
            :default, :default=, :default_proc, :default_proc=,
            :indexes, :indices,
            :rehash, :replace, :shift, :index,
          ])
        ).should == []
    end
  end # including Hashlike

end
