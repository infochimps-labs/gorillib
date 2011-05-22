require File.dirname(__FILE__)+'/spec_helper.rb'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/object/blank'
require 'time'
require 'date'
require 'gorillib/receiver'
require 'gorillib/array/extract_options'

class Wide
  include Receiver
  rcvr_accessor :my_int, Integer
end

describe Receiver do
  before do
    @klass = Class.new(Wide)
  end

  it 'tracks an order for the rcvrs' do
    @klass.rcvr_accessor :a, Integer
    @klass.rcvr_reader   :b, Integer
    @klass.rcvr_writer   :c, Integer
    @klass.rcvr          :d, Integer
    @klass.receiver_attr_names.should == [:my_int, :a, :b, :c, :d]
  end

  describe '.receive' do
    it 'creates a new object and returns it' do
      obj = @klass.new
      @klass.should_receive(:new).and_return(obj)
      ret = @klass.receive({})
      ret.should equal(obj)
    end

    it 'invokes receive! on the new object' do
      obj = @klass.new
      @klass.should_receive(:new).and_return(obj)
      obj.should_receive(:receive!).with({})
      ret = @klass.receive({})
    end

    it 'passes extra args to the constructor' do
      obj = @klass.new
      @klass.should_receive(:new).with(:a, :b).and_return(obj)
      obj.should_receive(:receive!).with({})
      ret = @klass.receive(:a, :b, {})
    end

    it 'accepts an empty arg set (receives an empty hash)' do
      obj = mock
      @klass.should_receive(:new).and_return(obj)
      obj.should_receive(:receive!).with({})
      @klass.receive(nil)
    end

    it 'uses the *last* arg as the hsh to receive' do
      obj = mock
      hsh_to_receive      = { :a => :b }
      hsh_for_constructor = { :c => :d }
      @klass.should_receive(:new).with(hsh_for_constructor).and_return(obj)
      obj.should_receive(:receive!).with(hsh_to_receive)
      @klass.receive(hsh_for_constructor, hsh_to_receive)
    end
  end

  describe '.rcvr' do

    it 'creates the receive_{whatever} method' do
      @klass.rcvr_accessor :a, Integer, :foo => :bar_a
      obj = @klass.new
      obj.should respond_to(:receive_a)
    end

    it 'stores the name, type and extra info into receiver_attrs, and the name (in order) into receiver_attr_names' do
      @klass.rcvr_accessor :a, Integer, :foo => :bar_a
      @klass.rcvr_reader   :b, Integer, :foo => :bar_b
      @klass.rcvr          :c, Integer, :foo => :bar_c
      @klass.receiver_attr_names.should == [:my_int, :a, :b, :c]
      @klass.receiver_attrs.should      == {
        :my_int => {:type => Integer, :name => :my_int},
        :a => {:type => Integer, :name => :a, :foo => :bar_a},
        :b => {:type => Integer, :name => :b, :foo => :bar_b},
        :c => {:type => Integer, :name => :c, :foo => :bar_c},
      }
    end

    it 'does not replace the class attributes in-place, so that inheritance works' do
      old_receiver_attrs = @klass.receiver_attrs
      old_receiver_attr_names = @klass.receiver_attr_names
      @klass.rcvr_accessor :a, Integer, :foo => :bar_a
      old_receiver_attrs.should_not equal(@klass.receiver_attrs)
      old_receiver_attr_names.should_not equal(@klass.receiver_attr_names)
    end
  end

  describe '.rcvr_accessor, .rcvr_reader, .rcvr_writer' do
    it 'accepts rcvr, rcvr_accessor, rcvr_reader, rcvr_writer' do
      @klass.rcvr_accessor :a, Integer
      @klass.rcvr_reader   :b, Integer
      @klass.rcvr_writer   :c, Integer
      @klass.rcvr          :d, Integer
      obj = @klass.new
      obj.should     respond_to(:a)
      obj.should     respond_to(:a=)
      obj.should     respond_to(:b)
      obj.should_not respond_to(:b=)
      obj.should_not respond_to(:c)
      obj.should     respond_to(:c=)
      obj.should_not respond_to(:d)
      obj.should_not respond_to(:d=)
    end

    it 'delegates to rcvr' do
      @klass.should_receive(:rcvr).with(:a, Integer, {:foo => :bar}).ordered
      @klass.should_receive(:rcvr).with(:b, Integer, {:foo => :bar}).ordered
      @klass.should_receive(:rcvr).with(:c, Integer, {:foo => :bar}).ordered
      @klass.should_receive(:rcvr).with(:d, Integer, {:foo => :bar}).ordered
      @klass.rcvr_accessor :a, Integer, :foo => :bar
      @klass.rcvr_reader   :b, Integer, :foo => :bar
      @klass.rcvr_writer   :c, Integer, :foo => :bar
      @klass.rcvr          :d, Integer, :foo => :bar
    end

    it 'does not modify parent class' do
      @klass.rcvr_accessor :a, Integer
      @klass.rcvr          :d, Integer
      obj = Wide.new
      obj.should_not respond_to(:a)
      obj.should_not respond_to(:a=)
      Wide.receiver_attr_names.should == [:my_int]
      Wide.receiver_attrs.should      == {:my_int => {:type => Integer, :name => :my_int}}
    end
  end

  describe '.rcvr_remaining'

  describe '.type_to_klass'

  describe '#unset'

  describe 'attr_set?'

  describe '#impose_defaults!'

  describe '#run_after_receivers'

  describe '#receive!' do
    before do
      @obj = @klass.new
    end
    it 'accepts things that quack like a hash: have [] and has_key?' do
      foo = mock
      def foo.[](*_) 3 end ; def foo.has_key?(*_) true end
      @obj.receive!(foo)
      @obj.my_int.should == 3
    end
    it 'only accepts things that quack like a hash' do
      lambda{ @obj.receive!(3) }.should raise_error ArgumentError, "Can't receive (it isn't hashlike): {3}"
    end
    it 'lets me call receive! with no args so I can trigger the defaults and after_receive hooks' do
      @obj.should_receive(:impose_defaults!).with({}).ordered
      @obj.should_receive(:run_after_receivers).with({}).ordered
      @obj.receive!
    end

    it 'receives symbol key' do
      @obj.receive! :my_int => 4
      @obj.my_int.should == 4
    end
    it 'receives string key' do
      @obj.receive! :my_int => 5
      @obj.my_int.should == 5
    end
    it 'with symbol and string key in given hash, takes symbol key only' do
      @obj.receive! :my_int => 7, 'my_int' => 6
      @obj.my_int.should == 7
    end
    it 'only accepts things that are receivers' do
      @klass.class_eval do attr_accessor :bob ; end
      @obj.receive! :my_int => 7, :bob => 12
      @obj.should_not_receive(:bob=)
      @obj.bob.should be_nil
    end
    it 'ignores extra keys' do
      @obj.receive! :my_int => 7, :bob => 12
      @obj.instance_variable_get('@bob').should be_nil
    end
    it 'delegates to receive_{whatever}' do
      @obj.should_receive(:receive_my_int).with(7)
      @obj.receive! :my_int => 7, :bob => 12
    end
    it 'imposes defaults and triggers after_receivers after hash has been sucked in' do
      @obj.should_receive(:receive_my_int).with(7).ordered
      @obj.should_receive(:impose_defaults!).with(:my_int => 7, :bob => 12).ordered
      @obj.should_receive(:run_after_receivers).with(:my_int => 7, :bob => 12).ordered
      @obj.receive! :my_int => 7, :bob => 12
    end
    it 'returns self, to allow chaining' do
      @obj.receive!(:my_int => 7, :bob => 12).should equal(@obj)
    end

    it 'only receives when there is a setter' do
      Wide.rcvr_reader :a, Integer
      p Wide.receiver_attrs
      obj = Wide.receive :my_int => 3, :a => 5
      obj.my_int.should == 3
      obj.a.should be_nil
      # make a setter for a
      def obj.a= val ; @a = val ; end
      obj.receive! :my_int => 20, :a => 25
      obj.my_int.should == 20
      obj.a.should      == 25
    end
  end

  describe "receiving type" do
    RECEIVABLES = [Symbol, String, Integer, Float, Time, Date, Array, Hash, Boolean, NilClass, Object]
    ALIASES     = [:symbol, :string, :int, :integer, :long, :time, :date, :float, :double, :hash, :map, :array, :null, :boolean, :bytes]
    it "has specs for every type" do
      (Receiver::RECEIVER_BODIES.keys - RECEIVABLES).should be_empty
    end
    it "has specs for every alias" do
      (Receiver::TYPE_ALIASES.keys - ALIASES).should == []
    end
    RECEIVABLES.each do |receivable|
      it "#{receivable} has a receiver_body" do
        Receiver::RECEIVER_BODIES.should have_key(receivable)
      end
    end
    (RECEIVABLES - [String]).each do |receivable|
      it "#{receivable} accepts nil as nil" do
        Wide.rcvr_accessor :nil_field, receivable
        obj = Wide.receive(:nil_field => nil)
        obj.nil_field.should be_nil
      end
    end
    [String].each do |receivable|
      it "#{receivable} accepts nil as empty string" do
        Wide.rcvr_accessor :nil_field, receivable
        obj = Wide.receive(:nil_field => nil)
        obj.nil_field.should == ""
      end
    end

    it 'accepts a type alias but uses the aliased class' do
      Wide.rcvr_accessor :my_symbol, :symbol
      Wide.rcvr_accessor :my_bytes,  :bytes
      Wide.receiver_attrs[:my_symbol][:type].should == Symbol
      Wide.receiver_attrs[:my_bytes ][:type].should == String
    end

    def self.it_correctly_converts(type, orig, desired)
      it "for #{type} converts #{orig.inspect} to #{desired.inspect}" do
        field = "#{type}_field".to_sym
        Wide.rcvr_accessor field, type
        obj = Wide.receive( field => orig )
        obj.send(field).should == desired
      end
    end

    describe 'type coercion' do
      [
        [Symbol,   'foo', :foo], [Symbol, :foo, :foo], [Symbol, nil, nil],     [Symbol, '', nil],
        [Integer, '5', 5],       [Integer, 5,   5],    [Integer, nil, nil],    [Integer, '', nil],
        [Integer, '5', 5],       [Integer, 5,   5],    [Integer, nil, nil],    [Integer, '', nil],
        [Float,   '5.2', 5.2],   [Float,   5.2, 5.2],  [Float, nil, nil],      [Float, '', nil],
        [String,  'foo', 'foo'], [String, :foo, 'foo'], [String, nil, ""],     [String, '', ""],
        [String,  5.2, "5.2"],   [String, [1], "[1]"],  [String, 1, "1"],
        [Time,  '1985-11-05T04:03:02Z',             Time.parse('1985-11-05T04:03:02Z')],
        [Time,  '1985-11-05T04:03:02+06:00',        Time.parse('1985-11-04T22:03:02Z')],
        [Time,  Time.parse('1985-11-05T04:03:02Z'), Time.parse('1985-11-05T04:03:02Z')],
        [Date,  Time.parse('1985-11-05T04:03:02Z'), Date.parse('1985-11-05')],
        [Date,  '1985-11-05T04:03:02Z',             Date.parse('1985-11-05')],
        [Date,  '1985-11-05T04:03:02+06:00',        Date.parse('1985-11-05')],
        [Time, nil, nil],  [Time, '', nil], [Time, 'blah', nil],
        [Date, nil, nil],  [Date, '', nil], [Date, 'blah', nil],
        [Array,  ['this', 'that', 'thother'], ['this', 'that', 'thother'] ],
        [Array,  ['this,that,thother'],       ['this,that,thother'] ],
        [Array,   'this,that,thother',        ['this,that,thother'] ],
        [Array,  'alone', ['alone'] ],
        [Array,  '',      []        ],
        [Array,  nil,     nil       ],
        [Hash,   {:hi => 1}, {:hi => 1}], [Hash,   nil,     nil],    [Hash,   "",      {}], [Hash,   [],      {}], [Hash,   {},      {}],
        [:boolean, '0', true],   [:boolean, 0, true],  [:boolean, '',  false], [:boolean, [],     true], [:boolean, nil, nil],
        [:boolean, '1', true],   [:boolean, 1, true],  [:boolean, '5', true],  [:boolean, 'true', true],
        [NilClass, nil, nil],
        [Object,  {:foo => [1]}, {:foo => [1]} ], [Object, nil, nil], [Object, 1, 1],
      ].each do |type, orig, desired|
        it_correctly_converts type, orig, desired
      end

      describe 'controversially' do
        [
          [Hash,  ['does no type checking'],      ['does no type checking'] ],
          [Hash,   'does no type checking',        'does no type checking'  ],
        ].each do |type, orig, desired|
          it_correctly_converts type, orig, desired
        end
      end

      describe 'NilClass' do
        it 'only accepts nil' do
          Wide.rcvr_accessor :nil_field, NilClass
          lambda{ Wide.receive( :nil_field => 'hello' ) }.should raise_error(ArgumentError, "This field must be nil, but {hello} was given")
        end
      end
    end
  end
end
