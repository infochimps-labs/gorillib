require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/hashlike'
require 'gorillib/struct/acts_as_hash'
require GORILLIB_ROOT_DIR('spec/support/hashlike_via_delegation')
require GORILLIB_ROOT_DIR('spec/support/hashlike_helper')
require GORILLIB_ROOT_DIR('spec/support/hashlike_fuzzing_helper')
require GORILLIB_ROOT_DIR('spec/support/hashlike_struct_helper')
require GORILLIB_ROOT_DIR('spec/hashlike/hashlike_behavior_spec')

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

  # ===========================================================================
  #
  # Fundamental behavior

  describe '#[] and #[]= and #store' do
    it_should_behave_like :hashlike_store_and_retrieve
    it_should_behave_like :references_string_and_symbol_keys_equivalently, ArgumentError
    it 'reject unknown keys' do
      lambda{ @hshlike[:fnord] = 69   }.should raise_error NameError, /no member 'fnord' in struct/
      lambda{ @hshlike[:fnord]        }.should raise_error NameError, /no member 'fnord' in struct/
      @hshlike.delete(:fnord).should be_nil
    end
    it 'accepts defined but unset keys' do
      @hshlike[:new_key].should be_nil
      @hshlike[:new_key] = 69
      @hshlike[:new_key].should == 69
    end
    it 'does not allow nil, Object, and other non-stringy keys' do
      lambda{ @hshlike[300] = :i_haz_num  }.should raise_error(IndexError, /offset 300 too large for struct/)
      lambda{ @hshlike[nil] = :i_haz_nil  }.should raise_error(TypeError, "no implicit conversion from nil to integer")
      obj = Object.new
      lambda{ @hshlike[obj] = :i_haz_obj  }.should raise_error(TypeError, "can't convert Object into Integer")
      def obj.to_sym() :c ; end
      lambda{ @hshlike[obj] = :i_haz_obj  }.should raise_error(TypeError, "can't convert Object into Integer")
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

  describe '#each_pair' do
    describe 'with block' do
      it_should_behave_like :each_pair_on_stringlike_fixed_keys, :each_pair
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_pair
  end

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
    it_should_behave_like :with_no_block_returns_enumerator, :each
  end

  describe '#each_key' do
    describe 'with block' do
      it_should_behave_like :each_key_on_stringlike_fixed_keys
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_key
  end

  describe '#each_value' do
    describe 'with block' do
      it_should_behave_like :each_value_on_stringlike_fixed_keys
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_value
  end

  # ===========================================================================
  #
  # Retrieval and Membership

  describe '#values' do
    it 'returns a new array populated with the values from hsh even when they were never set' do
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
    it_should_behave_like :hashlike_values_at_or_of, :values_of
  end

  describe '#length' do
    it 'returns the number of key/value pairs in the hashlike' do
      @hshlike.length.should == 6
      @hshlike.length.should == @hshlike.members.length
      @hshlike.delete(:a)
      @hshlike.delete(:b)
      @hshlike.length.should == 6
    end
    it 'is always the length of #members, regardless of contents' do
      @empty_hshlike.length.should == 6
    end
  end

  describe '#size' do
    it 'returns the number of key/value pairs in the hashlike' do
      @hshlike.size.should == 6
      @hshlike.size.should == @hshlike.members.size
      @hshlike.delete(:a)
      @hshlike.delete(:b)
      @hshlike.size.should == 6
    end
    it 'is always the length of #members, regardless of contents' do
      @empty_hshlike.size.should == 6
    end
  end

  describe '#has_key?' do
    it_should_behave_like :hashlike_has_key_predefined_always_present, :has_key?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :has_key?
  end

  describe '#include?' do
    it_should_behave_like :hashlike_has_key_predefined_always_present, :include?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :include?
  end

  describe '#key?' do
    it_should_behave_like :hashlike_has_key_predefined_always_present, :key?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :key?
  end

  describe '#member?' do
    it_should_behave_like :hashlike_has_key_predefined_always_present, :member?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :member?
  end

  describe '#has_value?' do
    it_should_behave_like :hashlike_has_value?, :has_value?
  end

  describe '#value?' do
    it_should_behave_like :hashlike_has_value?, :value?
  end

  describe '#fetch' do
    it 'returns a value from the hashlike for the given key' do
      @hshlike.fetch(:a).should       == 100
      @hshlike.fetch(:c).should       == 300
      @hshlike.fetch(:nil_val).should == nil
    end
    describe 'on a missing key' do
      it 'with no other arguments, raises a +KeyError+ exception' do
        lambda{ @hshlike.fetch(:is_missing) }.should raise_error(KeyError, 'key not found: :is_missing')
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
    it_should_behave_like :hashlike_key
  end

  describe '#assoc' do
    it_should_behave_like :hashlike_assoc
  end

  describe '#rassoc' do
    it_should_behave_like :hashlike_rassoc
  end

  describe '#empty?' do
    it 'returns true if the hashlike contains only nil values, false otherwise' do
      @hshlike.empty?.should       == false
      @empty_hshlike.empty?.should == true
      @empty_hshlike[:a] = false
      @empty_hshlike.empty?.should == false
    end
  end

  # ===========================================================================
  #
  # Update, merge!, merge


  describe 'update' do
    it_should_behave_like :merging_method, :update
    it_should_behave_like :merging_method_with_struct_keys, :update
    it_should_behave_like :merging_method_inplace, :update
  end

  describe '#merge!' do
    it_should_behave_like :merging_method, :merge!
    it_should_behave_like :merging_method_with_struct_keys, :merge!
    it_should_behave_like :merging_method_inplace, :merge!
  end

  describe '#merge' do
    it_should_behave_like :merging_method, :merge
    it_should_behave_like :merging_method_with_struct_keys, :merge
    it_should_behave_like :merging_method_returning_new, :merge
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
    it_should_behave_like :hashlike_clear
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
  # Sanity check

  it 'built test objects correctly' do
    @hshlike_subklass      .should     <  @hshlike.class
    @hshlike_subklass      .should_not == @hshlike.class
    @hshlike_subklass_inst .should     be_a(StructUsingHashlike)
    @hshlike_subklass_inst .should     be_a(@hshlike_subklass)
    @hshlike_subklass_inst .should_not be_an_instance_of(StructUsingHashlike)
    @hshlike               .should_not be_a(@hshlike_subklass)
    @hshlike               .should     be_an_instance_of(StructUsingHashlike)
  end

end
