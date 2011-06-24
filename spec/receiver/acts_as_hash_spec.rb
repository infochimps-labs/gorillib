require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/receiver'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/hashlike'
require 'gorillib/receiver/acts_as_hash'
require GORILLIB_ROOT_DIR('spec/support/hashlike_helper')
require GORILLIB_ROOT_DIR('spec/support/hashlike_via_delegation')
require GORILLIB_ROOT_DIR('spec/hashlike/hashlike_behavior_spec')

class SimpleReceiver
  include Receiver
  include Receiver::ActsAsHash
  include Gorillib::Hashlike
  #
  rcvr_accessor :a,         Integer
  rcvr_accessor :b,         Integer
  rcvr_accessor :c,         Integer
  # rcvr_reader   :b,         Integer
  # rcvr_writer   :c,         Integer
  rcvr_accessor :nil_val,   NilClass
  rcvr_accessor :false_val, Boolean
  rcvr_accessor :new_key,   String
end

describe Receiver do

  before do
    @hshlike                 = SimpleReceiver.new.merge(HashlikeHelper::HASH_TO_TEST_HL_V_A.dup)
    @empty_hshlike           = SimpleReceiver.new
    @hshlike_with_array_vals = SimpleReceiver.new.merge(HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.dup)
    #
    @hshlike_subklass        = Class.new(SimpleReceiver)
    @hshlike_subklass_inst   = @hshlike_subklass.new.merge(HashlikeHelper::BASE_HSH.dup)
  end


  # ===========================================================================
  #
  # Fundamental behavior

  describe '#[] and #[]= and #store' do
    it_should_behave_like :hashlike_store_and_retrieve
    it_should_behave_like :references_string_and_symbol_keys_equivalently

    it 'reject unknown keys' do
      lambda{ @hshlike[:fnord] = 69   }.should raise_error NoMethodError, /undefined method `fnord=' for/
      lambda{ @hshlike[:fnord]        }.should raise_error NoMethodError, /undefined method `fnord' for/
      @hshlike.delete(:fnord).should be_nil
    end

    it 'accepts defined but unset keys' do
      @hshlike[:new_key].should be_nil
      @hshlike[:new_key] = 69
      @hshlike[:new_key].should == 69
    end

    it 'does not allow nil, Object, or other non-stringy keys' do
      lambda{ @hshlike[300] = :i_haz_num }.should raise_error(ArgumentError, "Keys for SimpleReceiver must be symbols, strings or respond to #to_sym")
      lambda{ @hshlike[nil] = :i_haz_nil }.should raise_error(ArgumentError, "Keys for SimpleReceiver must be symbols, strings or respond to #to_sym")
      obj = Object.new
      lambda{ @hshlike[obj] = :i_haz_obj }.should raise_error(ArgumentError, "Keys for SimpleReceiver must be symbols, strings or respond to #to_sym")
      def obj.to_sym() :c ; end
      @hshlike[obj] = :i_haz_obj
      @hshlike[obj].should == :i_haz_obj
    end

    it 'defines the right accessor methods' do
      @hshlike_subklass.rcvr_writer :write_only_attr,  String
      @hshlike_subklass.rcvr_reader :read_only_attr,   String
      @hshlike_subklass.rcvr        :internal_attr,    String
      @hshlike_subklass.class_eval{ attr_accessor :not_a_receiver }
      [ :receive_write_only_attr, :write_only_attr=,
        :receive_read_only_attr,  :read_only_attr,
        :receive_internal_attr,
        :not_a_receiver, :not_a_receiver= ].each{ |attr| @hshlike_subklass.should be_method_defined(attr) }
      [ :write_only_attr,  :read_only_attr=,
        :internal_attr,  :internal_attr=,
        :receive_not_a_receiver ].each{ |attr| @hshlike_subklass.should_not be_method_defined(attr) }
      @hshlike_subklass.receiver_attr_names.should == [:a, :b, :c, :nil_val, :false_val, :new_key, :write_only_attr, :read_only_attr, :internal_attr]
    end
  end

  describe '#delete' do
    it_should_behave_like :hashlike_delete
  end

  describe '#keys' do
    it_should_behave_like :hashlike_keys
  end

  # ===========================================================================
  #
  # Iteration

  describe '#each_pair' do
    describe 'with block' do
      it_should_behave_like :each_pair_on_stringlike_keys, :each_pair
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_pair
  end

  describe '#each' do
    describe 'with block' do
      it_should_behave_like :each_pair_on_stringlike_keys, :each
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each
  end

  describe '#each_key' do
    describe 'with block' do
      it_should_behave_like :each_key_on_stringlike_keys
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_key
  end

  describe '#each_value' do
    describe 'with block' do
      it_should_behave_like :each_value_on_stringlike_keys
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_value
  end

  # ===========================================================================
  #
  # Retrieval and Membership

  describe '#values' do
    it_should_behave_like :hashlike_values
  end

  describe '#values_at' do
    it_should_behave_like :hashlike_values_at_or_of, :values_at
  end

  describe '#values_of' do
    it_should_behave_like :hashlike_values_at_or_of, :values_of
  end

  describe '#length' do
    it_should_behave_like :hashlike_length, :length
  end

  describe '#size' do
    it_should_behave_like :hashlike_length, :size
  end

  describe '#has_key?' do
    it_should_behave_like :hashlike_has_key?, :has_key?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :has_key?
  end

  describe '#include?' do
    it_should_behave_like :hashlike_has_key?, :include?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :include?
  end

  describe '#key?' do
    it_should_behave_like :hashlike_has_key?, :key?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :key?
  end

  describe '#member?' do
    it_should_behave_like :hashlike_has_key?, :member?
    it_should_behave_like :hashlike_has_key_string_and_symbol_equivalent, :member?
  end

  describe '#has_value?' do
    it_should_behave_like :hashlike_has_value?, :has_value?
  end

  describe '#value?' do
    it_should_behave_like :hashlike_has_value?, :value?
  end

  describe '#fetch' do
    it_should_behave_like :hashlike_fetch
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
    it_should_behave_like :hashlike_empty?
  end

  # ===========================================================================
  #
  # Update, merge!, merge

  describe 'update' do
    it_should_behave_like :merging_method, :update
    it_should_behave_like :merging_method_with_normal_keys, :update
    it_should_behave_like :merging_method_inplace, :update
  end

  describe '#merge!' do
    it_should_behave_like :merging_method, :merge!
    it_should_behave_like :merging_method_with_normal_keys, :merge!
    it_should_behave_like :merging_method_inplace, :merge!
  end

  describe '#merge' do
    it_should_behave_like :merging_method, :merge
    it_should_behave_like :merging_method_with_normal_keys, :merge
    it_should_behave_like :merging_method_returning_new, :merge
  end

  # ===========================================================================
  #
  # Filters

  describe '#reject!' do
    it_should_behave_like :hashlike_filter,  :reject!
    it_should_behave_like :rejection_filter, :reject!
    it_should_behave_like :filter_modifies_self_returns_nil_if_unchanged, :reject!, false
  end

  describe '#select!' do
    it_should_behave_like :hashlike_filter,  :select!
    it_should_behave_like :selection_filter, :select!
    it_should_behave_like :filter_modifies_self_returns_nil_if_unchanged, :select!, true
  end

  describe '#delete_if' do
    it_should_behave_like :hashlike_filter,  :delete_if
    it_should_behave_like :rejection_filter, :delete_if
    it_should_behave_like :filter_modifies_self_returns_self, :delete_if, false
  end

  describe '#keep_if' do
    it_should_behave_like :hashlike_filter,  :keep_if
    it_should_behave_like :selection_filter, :keep_if
    it_should_behave_like :filter_modifies_self_returns_self, :keep_if, true
  end

  describe '#reject' do
    it_should_behave_like :hashlike_filter,  :select
    it_should_behave_like :selection_filter, :select
    it_should_behave_like :filter_does_not_modify_self_returns_same_class, :reject, false
  end

  describe '#select' do
    it_should_behave_like :hashlike_filter,  :select
    it_should_behave_like :selection_filter, :select
    it_should_behave_like :filter_does_not_modify_self_returns_same_class, :select, true
  end

  describe '#clear' do
    it_should_behave_like :hashlike_clear
  end

  # ===========================================================================
  #
  # Conversion

  describe '#to_hash' do
    it_should_behave_like :hashlike_to_hash
  end

  describe '#invert' do
    it_should_behave_like :hashlike_invert
  end

  describe '#flatten' do
    it_should_behave_like :hashlike_flatten
  end

  # ===========================================================================
  #
  # Sanity check

  it 'built test objects correctly' do
    @hshlike_subklass      .should     <  @hshlike.class
    @hshlike_subklass      .should_not == @hshlike.class
    @hshlike_subklass_inst .should     be_a(SimpleReceiver)
    @hshlike_subklass_inst .should     be_a(@hshlike_subklass)
    @hshlike_subklass_inst .should_not be_an_instance_of(SimpleReceiver)
    @hshlike               .should_not be_a(@hshlike_subklass)
    @hshlike               .should     be_an_instance_of(SimpleReceiver)
  end

end
