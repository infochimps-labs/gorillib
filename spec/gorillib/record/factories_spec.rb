require File.expand_path('../../spec_helper', File.dirname(__FILE__))

require 'gorillib/record/factories'

describe 'a', :record_spec => true do
  let(:inst    ){ mock('any object') }
  let(:example_class){  Class.new }
  let(:example_module){ Module.new }
  let(:example_hash){  { :modacity => 7.3, :embiggen => :cromulent } }
  let(:example_array){ %w[alice bob charlie] }
  let(:example_proc){  ->(){ 'a proc' } }

  shared_examples_for :it_converts do |conversion_mapping|
    non_native_ok = conversion_mapping.delete(:non_native_ok)
    conversion_mapping.each do |obj, expected_result|
      it "#{obj.inspect} to #{expected_result}" do
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

  # describe Gorillib::Factory::BaseFactory do
  # end
  #
  # describe Gorillib::Factory::NonConvertingFactory do
  # end
  #
  # # __________________________________________________________________________
  # #
  # #
  #
  # describe Gorillib::Factory::StringFactory do
  #   it_behaves_like :it_considers_native,   'foo', ''
  #   it_behaves_like :it_converts,           :foo => 'foo', 3 => '3', false => "false", [] => "[]"
  #   it_behaves_like :it_considers_blankish, nil
  # end
  #
  # describe Gorillib::Factory::SymbolFactory do
  #   it_behaves_like :it_considers_native,   :foo, :"symbol :with weird chars"
  #   it_behaves_like :it_converts,           'foo' => :foo
  #   it_behaves_like :it_considers_blankish, nil, ""
  #   it_behaves_like :it_is_a_mismatch_for,  3, false, []
  # end
  #
  # describe Gorillib::Factory::RegexpFactory do
  #   it_behaves_like :it_considers_native,   /foo/, //
  #   it_behaves_like :it_converts,           'foo' => /foo/,  ".*" => /.*/
  #   it_behaves_like :it_considers_blankish, nil, ""
  #   it_behaves_like :it_is_a_mismatch_for,  :foo, 3, false, []
  # end
  #
  # describe Gorillib::Factory::IntegerFactory do
  #   it_behaves_like :it_considers_native,   1, -1
  #   it_behaves_like :it_converts,           'one' => 0, '3blindmice' => 3, "0x10" => 0
  #   it_behaves_like :it_converts,           '1.0' => 1, '1'  => 1,    "0" => 0, "0L" => 0, "1_234_567" => 1234567, "1_234_567.0" => 1234567
  #   it_behaves_like :it_converts,            1.0  => 1, 1.234567e6 => 1234567, Complex(1,0) => 1
  #   it_behaves_like :it_considers_blankish, nil, ""
  #   it_behaves_like :it_is_a_mismatch_for,  :foo, false, [], Complex(1,3)
  # end
  #
  # describe Gorillib::Factory::FloatFactory do
  #   it_behaves_like :it_considers_native,   1.0, 1.234567e6
  #   it_behaves_like :it_converts,           'one' => 0.0, '3blindmice' => 3.0, "0x10" => 0.0
  #   it_behaves_like :it_converts,           '1.0' => 1.0, '1' => 1.0, "0" => 0.0, "0L" => 0.0, "1_234_567" => 1234567.0, "1_234_567.0" => 1234567.0
  #   it_behaves_like :it_converts,                          1  => 1.0, -1 => -1.0, Complex(1,0) => 1.0
  #   it_behaves_like :it_considers_blankish, nil, ""
  #   it_behaves_like :it_is_a_mismatch_for,  :foo, false, []
  # end
  #
  # describe Gorillib::Factory::ComplexFactory do
  #   cplx0 = Complex(0) ; cplx1 = Complex(1) ; cplx1f = Complex(1.0) ;
  #   it_behaves_like :it_considers_native,   Complex(1,3), Complex(1,0)
  #   it_behaves_like :it_converts,           'one' => cplx0,  '3blindmice' => Complex(3), "0x10" => cplx0
  #   it_behaves_like :it_converts,           '1.0' => cplx1f, '1' => cplx1, '0' => cplx0, '0L' => cplx0, '1_234_567' => Complex(1234567), '1_234_567.0' => Complex(1234567.0)
  #   it_behaves_like :it_converts,            1.0 => cplx1f,   1 => cplx1,  -1 => Complex(-1), Rational(3,2) => Complex(Rational(3,2),0)
  #   it_behaves_like :it_considers_blankish, nil, ""
  #   it_behaves_like :it_is_a_mismatch_for,  :foo, false, []
  # end
  #
  # describe Gorillib::Factory::RationalFactory do
  #   rat_0 = Rational(0) ; rat1 = Rational(1) ; rat3_2 = Rational(3, 2) ;
  #   it_behaves_like :it_considers_native,   Rational(1, 3), Rational(1, 7)
  #   it_behaves_like :it_converts,           'one' => rat_0,  '3blindmice' => Rational(3), "0x10" => rat_0
  #   it_behaves_like :it_converts,           '1.5' => rat3_2, '1' => rat1, '0' => rat_0, '0L' => rat_0, '1_234_567' => Rational(1234567), '1_234_567.0' => Rational(1234567)
  #   it_behaves_like :it_converts,            1.5  => rat3_2,  1  => rat1,  -1 => Rational(-1), Complex(1.5) => rat3_2
  #   it_behaves_like :it_considers_blankish, nil, ""
  #   it_behaves_like :it_is_a_mismatch_for,  :foo, false, [], Complex(1.5,3)
  # end
  #
  # describe Gorillib::Factory::BooleanFactory do
  #   it_behaves_like :it_considers_native,   true, false
  #   it_behaves_like :it_considers_blankish, nil
  #   it_behaves_like :it_converts,           "false" => false, :false => false
  #   it_behaves_like :it_converts,           "true" => true,   :true  => true, [] => true, :foo => true, [] => true, Complex(1.5,3) => true, Object.new => true
  # end
  #
  #
  # describe Gorillib::Factory::IdentityFactory do
  #   it_behaves_like :it_considers_native,   true, false, nil, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
  # end
  # describe Gorillib::Factory::Whatever do
  #   it{ described_class.should equal(Gorillib::Factory::IdentityFactory) }
  # end
  #
  # describe Gorillib::Factory::ModuleFactory do
  #   it_behaves_like :it_considers_blankish, nil
  #   it_behaves_like :it_considers_native,  Module, Module.new, Class, Class.new, Object, String, BasicObject
  #   it_behaves_like :it_is_a_mismatch_for, true, false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' },             Complex(1,3), Object.new
  # end
  #
  # describe Gorillib::Factory::ClassFactory do
  #   it_behaves_like :it_considers_blankish, nil
  #   it_behaves_like :it_considers_native,  Module, Class, Class.new, Object, String, BasicObject
  #   it_behaves_like :it_is_a_mismatch_for, true, false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
  # end
  #
  # describe Gorillib::Factory::NilFactory do
  #   it_behaves_like :it_considers_native,  nil
  #   it_behaves_like :it_is_a_mismatch_for, true, false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
  # end
  #
  # describe Gorillib::Factory::TrueFactory do
  #   it_behaves_like :it_considers_native,  true
  #   it_behaves_like :it_is_a_mismatch_for,       false, 3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
  # end
  #
  # describe Gorillib::Factory::FalseFactory do
  #   it_behaves_like :it_considers_native,  false
  #   it_behaves_like :it_is_a_mismatch_for, true,        3, '', 'a string', :a_symbol, [], {}, ->(){ 'a proc' }, Module.new, Complex(1,3), Object.new
  # end

  # __________________________________________________________________________

  describe Gorillib::Factory::HashFactory do
    subject{ described_class.new(::Whatever, :native? => true ) }
    it_behaves_like :it_considers_blankish, nil, {}, []
    it_behaves_like :it_converts, { { "a" => 2 } => { :a => 2 }, :non_native_ok => true }
  end

  describe Gorillib::Factory::ArrayFactory do
    it_behaves_like :it_considers_blankish, nil, []
    it_behaves_like :it_converts, { [1,2,3] => [1,2,3], :non_native_ok => true }
  end

end
