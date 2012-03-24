require File.expand_path('spec_helper', File.dirname(__FILE__))
require 'gorillib/hashlike'
require GORILLIB_ROOT_DIR('spec/support/hashlike_via_delegation')
require GORILLIB_ROOT_DIR('spec/support/hashlike_helper')
require GORILLIB_ROOT_DIR('spec/hashlike/hashlike_behavior_spec')







describe Gorillib::Hashlike do

  before do
    @hshlike                 = InternalHash.new.merge(HashlikeHelper::BASE_HSH.dup)
    @empty_hshlike           = InternalHash.new
    @hshlike_with_array_keys = InternalHash.new.merge(HashlikeHelper::BASE_HSH_WITH_ARRAY_KEYS.dup)
    @hshlike_with_array_vals = InternalHash.new.merge(HashlikeHelper::BASE_HSH_WITH_ARRAY_VALS.dup)
    #
    @hshlike_subklass        = Class.new(InternalHash)
    @hshlike_subklass_inst   = @hshlike_subklass.new.merge(HashlikeHelper::BASE_HSH.dup)
  end

  # ===========================================================================
  #
  # Fundamental behavior

  describe '#[] and #[]= and #store' do
    it_should_behave_like :hashlike_store_and_retrieve
    it_should_behave_like :references_complex_keys
    it_should_behave_like :accepts_arbitrary_keys
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
      it_should_behave_like :each_pair_on_stringlike_keys,   :each_pair
      it_should_behave_like :each_pair_on_complex_keys,      :each_pair
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each_pair
  end

  describe '#each' do
    describe 'with block' do
      it_should_behave_like :each_pair_on_stringlike_keys,   :each
      it_should_behave_like :each_pair_on_complex_keys,      :each
    end
    it_should_behave_like :with_no_block_returns_enumerator, :each
  end

  describe '#each_key' do
    describe 'with block' do
      it_should_behave_like :each_key_on_stringlike_keys
      it_should_behave_like :each_key_on_complex_keys
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
    it_should_behave_like :hashlike_has_key_on_complex_keys, :has_key?
  end

  describe '#include?' do
    it_should_behave_like :hashlike_has_key?, :include?
    it_should_behave_like :hashlike_has_key_on_complex_keys, :include?
  end

  describe '#key?' do
    it_should_behave_like :hashlike_has_key?, :key?
    it_should_behave_like :hashlike_has_key_on_complex_keys, :key?
  end

  describe '#member?' do
    it_should_behave_like :hashlike_has_key?, :member?
    it_should_behave_like :hashlike_has_key_on_complex_keys, :member?
  end

  describe '#has_value?' do
    it_should_behave_like :hashlike_has_value?, :has_value?
    it_should_behave_like :hashlike_has_value_on_complex_keys, :has_value?
  end

  describe '#value?' do
    it_should_behave_like :hashlike_has_value?, :value?
    it_should_behave_like :hashlike_has_value_on_complex_keys, :value?
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
          HashlikeHelper::OMITTED_METHODS_FROM_HASH +
          HashlikeHelper::FANCY_HASHLIKE_METHODS
          )
        ).should == []
    end
  end # including Hashlike

  # ===========================================================================
  #
  # Sanity check

  it 'built test objects correctly' do
    @hshlike_subklass      .should     <  @hshlike.class
    @hshlike_subklass      .should_not == @hshlike.class
    @hshlike_subklass_inst .should     be_a(InternalHash)
    @hshlike_subklass_inst .should     be_a(@hshlike_subklass)
    @hshlike_subklass_inst .should_not be_an_instance_of(InternalHash)
    @hshlike               .should_not be_a(@hshlike_subklass)
    @hshlike               .should     be_an_instance_of(InternalHash)
  end

end
