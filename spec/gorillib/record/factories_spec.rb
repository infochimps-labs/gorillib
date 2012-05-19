require 'spec_helper'

require 'gorillib/object/blank'
require 'gorillib/object/try_dup'
require 'gorillib/hash/slice'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/string/inflector'
#
require 'gorillib/collection'
#
require 'gorillib/model/factories'


describe '', :model_spec => true do
  let(:inst    ){ mock('any object') }
  let(:example_class){  Class.new }
  let(:example_module){ Module.new }
  let(:example_hash){  { :modacity => 7.3, :embiggen => :cromulent } }
  let(:example_array){ %w[alice bob charlie] }
  let(:example_proc){  ->(){ 'a proc' } }

  let(:mock_factory){ Gorillib::Factory::BaseFactory.new }

  def test_factory(*args, &block)
    described_class.new(*args, &block)
  end

  describe Gorillib::Factory do
    describe 'Factory()' do
      it 'turns a proc into an ApplyProcFactory' do
        ff = Gorillib::Factory( ->(obj){ "bob says #{obj}" } )
        ff.receive(3).should == "bob says 3"
      end
      it 'uses a factory directly' do
        ff = Gorillib::Factory::SymbolFactory.new
        Gorillib::Factory(ff).should == ff
        Gorillib::Factory(Gorillib::Factory::SymbolFactory).should == Gorillib::Factory::SymbolFactory
      end
      it 'looks up factories by typename' do
        Gorillib::Factory(:symbol   ).should == Gorillib::Factory::SymbolFactory
        Gorillib::Factory(:identical).should == Gorillib::Factory::IdenticalFactory
      end
      it 'looks up factories by class' do
        Gorillib::Factory(Symbol).should == Gorillib::Factory::SymbolFactory
        Gorillib::Factory(String).should == Gorillib::Factory::StringFactory
      end
      it 'calls Gorillib::Factory.receive' do
        x = mock
        Gorillib::Factory.should_receive(:receive).with(x)
        Gorillib::Factory(x)
      end
    end
  end

  shared_examples_for :it_converts do |conversion_mapping|
    non_native_ok = conversion_mapping.delete(:non_native_ok)
    conversion_mapping.each do |obj, expected_result|
      it "#{obj.inspect} to #{expected_result.inspect}" do
        subject.native?(  obj).should be_false
        subject.blankish?(obj).should be_false
        actual_result = subject.receive(obj)
        actual_result.should  eql(expected_result)
        unless non_native_ok then subject.native?(actual_result).should be_true  ; end
      end
    end
  end

  shared_examples_for :it_considers_native do |*native_objs|
    it native_objs.inspect do
      native_objs.each do |obj|
        subject.native?(  obj).should be_true
        actual_result = subject.receive(obj)
        actual_result.should equal(obj)
      end
    end
  end

  shared_examples_for :it_considers_blankish do |*blankish_objs|
    it blankish_objs.inspect do
      blankish_objs.each do |obj|
        subject.blankish?(obj).should be_true
        subject.receive(obj).should be_nil
      end
    end
  end

  shared_examples_for :it_is_a_mismatch_for do |*mismatched_objs|
    it mismatched_objs.inspect do
      mismatched_objs.each do |obj|
        ->{ subject.receive(obj) }.should raise_error(Gorillib::Factory::FactoryMismatchError)
      end
    end
  end

  shared_examples_for :it_is_registered_as do |*keys|
    it "the factory for #{keys}" do
      keys.each do |key|
        Gorillib::Factory(key).should == described_class
      end
      Gorillib::Factory.send(:factories).to_hash.select{|key,val| val == described_class }.keys.should == keys
    end
  end

  # __________________________________________________________________________
  #
  #
  #
  describe Gorillib::Factory::StringFactory do
    it_behaves_like :it_considers_native,   'foo', ''
    it_behaves_like :it_converts,           :foo => 'foo', 3 => '3', false => "false", [] => "[]"
    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_is_registered_as, :string, String
    its(:typename){ should == :string }
  end

  describe Gorillib::Factory::SymbolFactory do
    it_behaves_like :it_considers_native,   :foo, :"symbol :with weird chars"
    it_behaves_like :it_converts,           'foo' => :foo
    it_behaves_like :it_considers_blankish, nil, ""
    it_behaves_like :it_is_a_mismatch_for,  3, false, []
    it_behaves_like :it_is_registered_as, :symbol, Symbol
    its(:typename){ should == :symbol }
  end

  describe Gorillib::Factory::RegexpFactory do
    it_behaves_like :it_considers_native,   /foo/, //
    it_behaves_like :it_converts,           'foo' => /foo/,  ".*" => /.*/
    it_behaves_like :it_considers_blankish, nil, ""
    it_behaves_like :it_is_a_mismatch_for,  :foo, 3, false, []
    it_behaves_like :it_is_registered_as, :regexp, Regexp
    its(:typename){ should == :regexp }
  end

  describe Gorillib::Factory::IntegerFactory do
    it_behaves_like :it_considers_native,   1, -1
    it_behaves_like :it_converts,           'one' => 0, '3blindmice' => 3, "0x10" => 0
    it_behaves_like :it_converts,           '1.0' => 1, '1'  => 1,    "0" => 0, "0L" => 0, "1_234_567" => 1234567, "1_234_567.0" => 1234567
    it_behaves_like :it_converts,            1.0  => 1, 1.234567e6 => 1234567, Complex(1,0) => 1
    it_behaves_like :it_considers_blankish, nil, ""
    it_behaves_like :it_is_a_mismatch_for,  :foo, false, [], Complex(1,3)
    it_behaves_like :it_is_registered_as, :int, :integer, Integer
    its(:typename){ should == :integer }
  end

  describe Gorillib::Factory::FloatFactory do
    it_behaves_like :it_considers_native,   1.0, 1.234567e6
    it_behaves_like :it_converts,           'one' => 0.0, '3blindmice' => 3.0, "0x10" => 0.0
    it_behaves_like :it_converts,           '1.0' => 1.0, '1' => 1.0, "0" => 0.0, "0L" => 0.0, "1_234_567" => 1234567.0, "1_234_567.0" => 1234567.0
    it_behaves_like :it_converts,                          1  => 1.0, -1 => -1.0, Complex(1,0) => 1.0
    it_behaves_like :it_considers_blankish, nil, ""
    it_behaves_like :it_is_a_mismatch_for,  :foo, false, []
    it_behaves_like :it_is_registered_as, :float, Float
    its(:typename){ should == :float }
  end

  describe Gorillib::Factory::ComplexFactory do
    cplx0 = Complex(0) ; cplx1 = Complex(1) ; cplx1f = Complex(1.0) ;
    it_behaves_like :it_considers_native,   Complex(1,3), Complex(1,0)
    it_behaves_like :it_converts,           'one' => cplx0,  '3blindmice' => Complex(3), "0x10" => cplx0
    it_behaves_like :it_converts,           '1.0' => cplx1f, '1' => cplx1, '0' => cplx0, '0L' => cplx0, '1_234_567' => Complex(1234567), '1_234_567.0' => Complex(1234567.0)
    it_behaves_like :it_converts,            1.0 => cplx1f,   1 => cplx1,  -1 => Complex(-1), Rational(3,2) => Complex(Rational(3,2),0)
    it_behaves_like :it_considers_blankish, nil, ""
    it_behaves_like :it_is_a_mismatch_for,  :foo, false, []
    it_behaves_like :it_is_registered_as, :complex, Complex
    its(:typename){ should == :complex }
  end

  describe Gorillib::Factory::RationalFactory do
    rat_0 = Rational(0) ; rat1 = Rational(1) ; rat3_2 = Rational(3, 2) ;
    it_behaves_like :it_considers_native,   Rational(1, 3), Rational(1, 7)
    it_behaves_like :it_converts,           'one' => rat_0,  '3blindmice' => Rational(3), "0x10" => rat_0
    it_behaves_like :it_converts,           '1.5' => rat3_2, '1' => rat1, '0' => rat_0, '0L' => rat_0, '1_234_567' => Rational(1234567), '1_234_567.0' => Rational(1234567)
    it_behaves_like :it_converts,            1.5  => rat3_2,  1  => rat1,  -1 => Rational(-1), Complex(1.5) => rat3_2
    it_behaves_like :it_considers_blankish, nil, ""
    it_behaves_like :it_is_a_mismatch_for,  :foo, false, [], Complex(1.5,3)
    it_behaves_like :it_is_registered_as, :rational, Rational
    its(:typename){ should == :rational }
  end

  describe Gorillib::Factory::BooleanFactory do
    it_behaves_like :it_considers_native,   true, false
    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts,           "false" => false, :false => false
    it_behaves_like :it_converts,           "true" => true,   :true  => true, [] => true, :foo => true, [] => true, Complex(1.5,3) => true, Object.new => true
    it_behaves_like :it_is_registered_as, :boolean
    its(:typename){ should == :boolean }
  end

  describe Gorillib::Factory::IdenticalFactory do
    it_behaves_like :it_considers_native,   true, false, nil, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :identical, :whatever
  end
  describe ::Whatever do
    it{ described_class.should equal(Gorillib::Factory::IdenticalFactory) }
  end

  describe Gorillib::Factory::ModuleFactory do
    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_considers_native,  Module, Module.new, Class, Class.new, Object, String, BasicObject
    it_behaves_like :it_is_a_mismatch_for, true, false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' },             Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :module, Module
    its(:typename){ should == :module }
  end

  describe Gorillib::Factory::ClassFactory do
    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_considers_native,  Module, Class, Class.new, Object, String, BasicObject
    it_behaves_like :it_is_a_mismatch_for, true, false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :class, Class
    its(:typename){ should == :class }
  end

  describe Gorillib::Factory::NilFactory do
    it_behaves_like :it_considers_native,  nil
    it_behaves_like :it_is_a_mismatch_for, true, false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :nil, NilClass
    its(:typename){ should == :nil_class }
  end

  describe Gorillib::Factory::TrueFactory do
    it_behaves_like :it_considers_native,  true
    it_behaves_like :it_is_a_mismatch_for,       false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :true, TrueClass
  end

  describe Gorillib::Factory::FalseFactory do
    it_behaves_like :it_considers_native,  false
    it_behaves_like :it_is_a_mismatch_for, true,        3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :false, FalseClass
  end

  describe Gorillib::Factory::RangeFactory do
    it_behaves_like :it_considers_blankish, nil, []
    it_behaves_like :it_considers_native,  (1..2), ('a'..'z')
    it_behaves_like :it_is_a_mismatch_for, true,        3, '', 'a string', :a_symbol, [1,2], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it_behaves_like :it_is_registered_as, :range, Range
    its(:typename){ should == :range }
  end

  # __________________________________________________________________________

  # hand it a collection with entries 1, 2, 3 please
  shared_examples_for :an_enumerable_factory do
    it "accepts a factory for its items" do
      mock_factory.should_receive(:receive).with(1)
      mock_factory.should_receive(:receive).with(2)
      mock_factory.should_receive(:receive).with(3)
      factory = test_factory(:items => mock_factory)
      factory.receive( collection_123 )
    end
    it "can generate an empty collection" do
      subject.empty_product.should == empty_collection
    end
    it "lets you override the empty collection" do
      ep = mock; ep.should_receive(:try_dup).and_return 'hey'
      subject = test_factory(:empty_product => ep)
      subject.empty_product.should == 'hey'
      subject = test_factory(:empty_product => ->{ 'yo' })
      subject.empty_product.should == 'yo'
    end
  end

  describe Gorillib::Factory::HashFactory do
    let(:collection_123){   { 'a' => 1, :b => 2, 'c' => 3 } }
    let(:empty_collection){ {} }

    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts, { {} => {}, { "a" => 2 } => { 'a' => 2 }, { :a => 2 } => { :a => 2 }, :non_native_ok => true }
    it_behaves_like :it_is_a_mismatch_for, [1,2,3]
    it_behaves_like :an_enumerable_factory

    it 'follows examples' do
      test_factory.receive(collection_123).should == { 'a' => 1, :b => 2, 'c' => 3}
      test_factory(:keys  => :symbol).receive({'a' => 'x', :b => 'y', 'c' => :z}).should == {:a  => 'x', :b => 'y', :c  => :z}
      test_factory(:items => :symbol).receive({'a' => 'x', :b => 'y', 'c' => :z}).should == {'a' => :x,  :b => :y,  'c' => :z}
      autov_factory = test_factory(:empty_product => Hash.new{|h,k| h[k] = {} })
      result = autov_factory.receive({:a => :b})  ; result.should == { :a => :b }
      result[:flanger][:modacity] = 11            ; result.should == { :a => :b,  :flanger => { :modacity => 11 }}
      result2 = autov_factory.receive({:x => :y}) ; result2.should == { :x => :y } ; result.should == { :a => :b,  :flanger => { :modacity => 11 }}
    end

    it "accepts a factory for the keys" do
      mock_factory.should_receive(:receive).with(3).and_return("converted!")
      factory = test_factory(:keys => mock_factory)
      factory.receive( { 3 => 4 } ).should == { 'converted!' => 4 }
    end
    it_behaves_like :it_is_registered_as, :hash, Hash
    its(:typename){ should == :hash }
  end

  describe Gorillib::Factory::ArrayFactory do
    let(:collection_123){ [1,2,3] }
    let(:empty_collection){ [] }

    it 'follows examples' do
      test_factory.receive([1,2,3]).should == [1,2,3]
      test_factory(:items         => :symbol).receive(['a', 'b', :c]).should == [:a, :b, :c]
      test_factory(:empty_product => [1,2,3]).receive([:a,  :b,  :c]).should == [1, 2, 3, :a, :b, :c]
    end

    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts, { [] => [], {} => [], [1,2,3] => [1,2,3], {:a => :b} => [[:a, :b]], [:a] => [:a], [[]] => [[]], :non_native_ok => true }
    it_behaves_like :an_enumerable_factory
    it_behaves_like :it_is_registered_as, :array, Array
    its(:typename){ should == :array }
  end

  describe Gorillib::Factory::SetFactory do
    let(:collection_123){   Set.new([1,2,3]) }
    let(:empty_collection){ Set.new }

    it 'follows examples' do
      test_factory.receive([1,2,3]).should == collection_123
      test_factory(:items  => :symbol).receive(['a', 'b', :c]).should == [:a, :b, :c].to_set
      test_factory(:empty_product => [1,2,3].to_set).receive([:a,  :b,  :c]).should == [1, 2, 3, :a, :b, :c].to_set

      has_an_empty_array = test_factory.receive( [[]] )
      has_an_empty_array.should == Set.new( [[]] )
      has_an_empty_array.first.should == []
      has_an_empty_array.size.should  == 1
    end

    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts, { [] => Set.new, {} => Set.new, [1,2,3] => [1,2,3].to_set, {:a => :b} => Set.new({:a => :b}), [:a] => [:a].to_set, :non_native_ok => true }
    it_behaves_like :an_enumerable_factory
    it_behaves_like :it_is_registered_as, :set, Set
    its(:typename){ should == :set }
  end

end
