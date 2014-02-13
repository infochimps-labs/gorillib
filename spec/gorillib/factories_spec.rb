require 'spec_helper'
require 'support/factory_test_helpers'

require 'gorillib/object/blank'
require 'gorillib/object/try_dup'
require 'gorillib/hash/slice'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/string/inflector'

require 'gorillib/collection'
require 'gorillib/factories'

describe '', :model_spec, :factory_spec do

  describe Gorillib::Factory do
    describe 'Factory()' do
      it 'turns a proc into an ApplyProcFactory' do
        ff = Gorillib::Factory( ->(obj){ "bob says #{obj}" } )
        ff.receive(3).should == "bob says 3"
      end
      it 'returns anything that responds to #receive directly' do
        ff = Object.new ; ff.define_singleton_method(:receive){}
        Gorillib::Factory(ff).should equal(ff)
      end
      it 'returns a factory directly' do
        ff = Gorillib::Factory::SymbolFactory.new
        Gorillib::Factory(ff).should equal(ff)
      end
      it 'does not look up factory **classes**' do
        ->{ Gorillib::Factory(Gorillib::Factory::SymbolFactory) }.should raise_error(ArgumentError, /Don\'t know which factory makes/)
      end
      it 'looks up factories by typename' do
        Gorillib::Factory(:symbol   ).should be_a(Gorillib::Factory::SymbolFactory)
        Gorillib::Factory(:identical).should == (::Whatever)
      end
      it 'looks up factories by class' do
        Gorillib::Factory(Symbol).should be_a(Gorillib::Factory::SymbolFactory)
        Gorillib::Factory(String).should be_a(Gorillib::Factory::StringFactory)
      end
      it 'calls Gorillib::Factory.lookup' do
        x = double
        Gorillib::Factory.should_receive(:find).with(x)
        Gorillib::Factory(x)
      end
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
    it_behaves_like :it_considers_native,   1, -1, 123_456_789_123_456_789_123_456_789_123_456_789
    #
    it_behaves_like :it_converts,           '1'   => 1,   '0'   => 0,   '1234567'   => 1234567
    it_behaves_like :it_converts,           '123456789123456789123456789123456789' => 123_456_789_123_456_789_123_456_789_123_456_789
    it_behaves_like :it_converts,           '1_234_567'  => 1234567
    it_behaves_like :it_converts,            1.0  => 1,   1.99  => 1,   -0.9 =>  0
    it_behaves_like :it_converts,            Complex(1,0) => 1, Complex(1.0,0) => 1, Rational(5,2) => 2
    #
    it_behaves_like :it_considers_blankish,  nil, ''
    it_behaves_like :it_is_a_mismatch_for,   Complex(1,0.0), Complex(0,3), :foo, false, []
    it_behaves_like :it_is_a_mismatch_for,  '8_',          'one',         '3blindmice',        '_8_'
    it_behaves_like :it_is_a_mismatch_for,   Float::INFINITY, Float::NAN
    # Does not accept floating-point-ish
    it_behaves_like :it_is_a_mismatch_for,  '1.0',       '0.0',       '1234567.0'
    it_behaves_like :it_is_a_mismatch_for,  '1e5',       '1_234_567e-3',         '1_234_567.0', '+11.123E+12'
    # Handles hex
    it_behaves_like :it_converts,           '011' =>  9,   '0x10' => 16
    # Intolerant of cruft, unlike GraciousIntegerFactory
    it_behaves_like :it_is_a_mismatch_for,  '0L',          '1_234_567L',              '1_234_567e-3f', '1,234,567'
    #
    it_behaves_like :it_is_registered_as, :int, :integer, Integer
    its(:typename){ should == :integer }
  end

  describe Gorillib::Factory::GraciousIntegerFactory do
    it_behaves_like :it_considers_native,   1, -1, 123_456_789_123_456_789_123_456_789_123_456_789
    #
    it_behaves_like :it_converts,           '1'   => 1,    '0'   => 0,   '1234567'   => 1234567
    it_behaves_like :it_converts,           '123456789123456789123456789123456789' => 123_456_789_123_456_789_123_456_789_123_456_789
    it_behaves_like :it_converts,           '1_234_567'  => 1234567
    it_behaves_like :it_converts,            1.0  => 1,   1.99  => 1,   -0.9 =>  0
    it_behaves_like :it_converts,            Complex(1,0) => 1, Complex(1.0,0) => 1, Rational(5,2) => 2
    #
    it_behaves_like :it_considers_blankish,  nil, ''
    it_behaves_like :it_is_a_mismatch_for,   Complex(1,0.0), Complex(0,3), :foo, false, []
    it_behaves_like :it_is_a_mismatch_for,  '8_',          'one',         '3blindmice',        '_8_'
    it_behaves_like :it_is_a_mismatch_for,   Float::INFINITY, Float::NAN
    # Handles floating-point well
    it_behaves_like :it_converts,           '1.0' => 1,    '0.0' => 0,   '1234567.0' => 1234567
    it_behaves_like :it_converts,           '1e5' => 100000, '1_234_567e-3' => 1234,  '1_234.5e3' => 1_234_500, '+11.123E+12' => 11_123_000_000_000
    # Silently confuses hex and octal
    it_behaves_like :it_converts,           '011' =>  9,   '0x10' => 16, '0x1.999999999999ap4' => 25
    # Tolerates some cruft, unlike IntegerFactory
    it_behaves_like :it_converts,           '0L'  => 0,    '1_234_567L' => 1234567,    '1234.5e3f' => 1_234_500,    '1234567e-3f' => 1_234
    it_behaves_like :it_converts,           '1,234,567'  => 1234567, ',,,,1,23,45.67e,-1,' => 1234
    #
    it_behaves_like :it_is_registered_as, :gracious_int
    its(:typename){ should == :integer }
  end

  describe Gorillib::Factory::FloatFactory do
    it_behaves_like :it_considers_native,   1.0, 1.234567e6, 123_456_789_123_456_789_123_456_789_123_456_789.0
    it_behaves_like :it_considers_native,   Float::INFINITY, Float::NAN
    it_behaves_like :it_converts,           '1'   => 1.0, '0'   => 0.0, '1234567'   => 1234567.0
    it_behaves_like :it_converts,           '1.0' => 1.0, '0.0' => 0.0, '1234567.0' => 1234567.0
    it_behaves_like :it_converts,           '123456789123456789123456789123456789' => 123_456_789_123_456_789_123_456_789_123_456_789.0
    it_behaves_like :it_converts,           '1_234_567'  => 1234567.0
    it_behaves_like :it_converts,            1    => 1.0
    it_behaves_like :it_converts,            Complex(1,0) => 1.0, Complex(1.0,0) => 1.0, Rational(5,2) => 2.5
    it_behaves_like :it_converts,           '1e5' => 1e5,  '1_234_567e-3' => 1234.567, '1_234_567.0' => 1234567.0, '+11.123E+700' => 11.123e700
    #
    it_behaves_like :it_considers_blankish,  nil, ''
    it_behaves_like :it_is_a_mismatch_for,   Complex(1,0.0), Complex(0,3), :foo, false, []
    #
    # Different from #to_f
    it_behaves_like :it_converts,           '011' => 11.0, '0x10' => 16.0, '0x1.999999999999ap4' => 25.6
    it_behaves_like :it_is_a_mismatch_for,  '0L',          '1_234_567L',              '1_234_567e-3f'
    it_behaves_like :it_is_a_mismatch_for,  '_8_',          'one',         '3blindmice',        '8_'
    #
    it_behaves_like :it_is_registered_as, :float, Float
    its(:typename){ should == :float }
  end

  describe Gorillib::Factory::GraciousFloatFactory do
    it_behaves_like :it_considers_native,   1.0, 1.234567e6, 123_456_789_123_456_789_123_456_789_123_456_789.0
    it_behaves_like :it_converts,           '1'   => 1.0, '0'   => 0.0, '1234567'   => 1234567.0
    it_behaves_like :it_converts,           '1.0' => 1.0, '0.0' => 0.0, '1234567.0' => 1234567.0
    it_behaves_like :it_converts,           '123456789123456789123456789123456789' => 123_456_789_123_456_789_123_456_789_123_456_789.0
    it_behaves_like :it_converts,           '1_234_567'  => 1234567.0
    it_behaves_like :it_converts,            1    => 1.0
    it_behaves_like :it_converts,            Complex(1,0) => 1.0, Complex(1.0,0) => 1.0, Rational(5,2) => 2.5
    it_behaves_like :it_converts,           '1e5' => 1e5,  '1_234_567e-3' => 1234.567, '1_234_567.0' => 1234567.0, '+11.123E+700' => 11.123e700
    #
    it_behaves_like :it_considers_blankish,  nil, ''
    it_behaves_like :it_is_a_mismatch_for,   Complex(1,0.0), Complex(0,3), :foo, false, []
    #
    # Different from stricter FloatFactory or laxer #to_f
    it_behaves_like :it_converts,           '011' => 11.0, '0x10' => 16.0, '0x1.999999999999ap4' => 25.6
    it_behaves_like :it_converts,           '0L'  => 0.0,  '1_234_567L' => 1234567.0, '1_234_567e-3f' => 1234.567
    it_behaves_like :it_is_a_mismatch_for,  '_8_',         'one',         '3blindmice',        '8_'
    it_behaves_like :it_converts,           '1,234,567e-3' => 1234.567, ',,,,1,23,45.67e,-1,' => 1234.567, '+11.123E+700' => 11.123e700
    #
    it_behaves_like :it_is_registered_as, :gracious_float
    its(:typename){ should == :float }
  end

  describe Gorillib::Factory::ComplexFactory do
    cplx0 = Complex(0) ; cplx1 = Complex(1) ; cplx1234500 = Complex(1_234_500,0) ; cplx1234500f = Complex(1_234_500.0,0) ;
    it_behaves_like :it_considers_native,   Complex(1,3), Complex(1,0)
    it_behaves_like :it_converts,           '1234.5e3' => cplx1234500f, '1234500' => cplx1234500, '0' => cplx0
    it_behaves_like :it_converts,           1234.5e3 => cplx1234500f,   1 => cplx1,  -1 => Complex(-1), Rational(3,2) => Complex(Rational(3,2),0)
    it_behaves_like :it_converts,           [1,0] => Complex(1),       [1,2] => Complex(1,2)
    it_behaves_like :it_converts,           ['1234.5e3','98.6'] => Complex(1234.5e3, 98.6)
    it_behaves_like :it_considers_blankish, nil, ''
    it_behaves_like :it_is_a_mismatch_for,  'one', '3blindmice', '0x10', '1234.5e3f', '1234L', :foo, false, []
    it_behaves_like :it_is_registered_as, :complex, Complex
    its(:typename){ should == :complex }
  end

  describe Gorillib::Factory::RationalFactory do
    rat_0 = Rational(0) ; rat1 = Rational(1) ; rat3_2 = Rational(3, 2) ;
    it_behaves_like :it_considers_native,   Rational(1, 3), Rational(1, 7)
    it_behaves_like :it_converts,           '1.5' => rat3_2, '1' => rat1, '0' => rat_0, '1_234_567' => Rational(1234567), '1_234_567.0' => Rational(1234567)
    it_behaves_like :it_converts,            1.5  => rat3_2,  1  => rat1,  -1 => Rational(-1), Complex(1.5) => rat3_2
    it_behaves_like :it_considers_blankish, nil, ''
    it_behaves_like :it_is_a_mismatch_for,  'one', '3blindmice', '0x10', '1234.5e3f', '1234L', :foo, false, [], Complex(1.5,3)
    it_behaves_like :it_is_registered_as, :rational, Rational
    its(:typename){ should == :rational }
  end

  describe Gorillib::Factory::TimeFactory do
    fuck_wit_dre_day   = Time.new(1993, 2, 18, 8, 8, 0, '-08:00')  # and Everybody's Celebratin'
    ice_cubes_good_day = Time.utc(1992, 1, 20, 0, 0, 0)
    it_behaves_like :it_considers_native,   Time.now.utc, ice_cubes_good_day
    it_behaves_like :it_converts,           fuck_wit_dre_day => fuck_wit_dre_day.getutc
    it_behaves_like :it_converts,           '19930218160800' => fuck_wit_dre_day.getutc, '19920120000000Z' => ice_cubes_good_day
    it_behaves_like :it_converts,           Date.new(1992, 1, 20) => ice_cubes_good_day
    before('behaves like it_converts "an unparseable time" to nil'){ subject.stub(:warn) }
    it_behaves_like :it_converts,           "an unparseable time" => nil, :non_native_ok => true
    it_behaves_like :it_considers_blankish, nil, ''
    it_behaves_like :it_is_a_mismatch_for,  :foo, false, []
    it_behaves_like :it_is_registered_as,   :time, Time
    it('always returns a UTC timezoned time') do
      subject.convert(fuck_wit_dre_day).utc_offset.should == 0
      fuck_wit_dre_day.utc_offset.should == (-8 * 3600)
    end
    its(:typename){ should == :time }
  end

  describe Gorillib::Factory::BooleanFactory do
    it_behaves_like :it_considers_native,   true, false
    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts,           'false' => false, :false => false
    it_behaves_like :it_converts,           'true' => true,   :true  => true, '0' => true, 0 => true, [] => true, :foo => true, [] => true, Complex(1.5,3) => true, Object.new => true
    it_behaves_like :it_is_registered_as, :boolean
    its(:typename){ should == :boolean }
  end

  describe ::Whatever do
    it_behaves_like :it_considers_native,   true, false, nil, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
    it 'it is itself the factory for :identical and :whatever' do
      keys = [Whatever, :identical, :whatever]
      keys.each do |key|
        Gorillib::Factory(key).should equal(described_class)
      end
      its_factory = ::Whatever
      Gorillib::Factory.send(:factories).to_hash.select{|key,val| val.equal?(its_factory) }.keys.should == keys
    end
  end
  describe Gorillib::Factory::IdenticalFactory do
    it{ described_class.should equal(Whatever) }
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

  describe Gorillib::Factory::HashFactory do
    let(:collection_123){   { 'a' => 1, :b => 2, 'c' => 3 } }
    let(:empty_collection){ {} }

    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts, { {} => {}, { "a" => 2 } => { 'a' => 2 }, { :a => 2 } => { :a => 2 }, :non_native_ok => true }
    it_behaves_like :it_is_a_mismatch_for, [1,2,3]
    it_behaves_like :an_enumerable_factory

    it 'follows examples' do
      described_class.new.receive(collection_123).should == { 'a' => 1, :b => 2, 'c' => 3}
      described_class.new(:keys  => :symbol).receive({'a' => 'x', :b => 'y', 'c' => :z}).should == {:a  => 'x', :b => 'y', :c  => :z}
      described_class.new(:items => :symbol).receive({'a' => 'x', :b => 'y', 'c' => :z}).should == {'a' => :x,  :b => :y,  'c' => :z}
      autov_factory = described_class.new(:empty_product => Hash.new{|h,k| h[k] = {} })
      result = autov_factory.receive({:a => :b})  ; result.should == { :a => :b }
      result[:flanger][:modacity] = 11            ; result.should == { :a => :b,  :flanger => { :modacity => 11 }}
      result2 = autov_factory.receive({:x => :y}) ; result2.should == { :x => :y } ; result.should == { :a => :b,  :flanger => { :modacity => 11 }}
    end

    it "accepts a factory for the keys" do
      mock_factory = double('factory')
      mock_factory.should_receive(:receive).with(3).and_return("converted!")
      factory = described_class.new(:keys => mock_factory)
      factory.receive( { 3 => 4 } ).should == { 'converted!' => 4 }
    end
    it_behaves_like :it_is_registered_as, :hash, Hash
    its(:typename){ should == :hash }
  end

  describe Gorillib::Factory::ArrayFactory do
    let(:collection_123){ [1,2,3] }
    let(:empty_collection){ [] }

    it 'follows examples' do
      described_class.new.receive([1,2,3]).should == [1,2,3]
      described_class.new(:items         => :symbol).receive(['a', 'b', :c]).should == [:a, :b, :c]
      described_class.new(:empty_product => [1,2,3]).receive([:a,  :b,  :c]).should == [1, 2, 3, :a, :b, :c]
    end

    it_behaves_like :it_considers_blankish, nil
    it_behaves_like :it_converts, { [] => [], {} => [], [1,2,3] => [1,2,3], {:a => :b} => [[:a, :b]], [:a] => [:a], [[]] => [[]], :non_native_ok => true }
    it_behaves_like :an_enumerable_factory
    it_behaves_like :it_is_registered_as, :array, Array
    its(:typename){ should == :array }
  end

end
