require File.expand_path('spec_helper', File.dirname(__FILE__))
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

require 'gorillib/receiver/acts_as_hash'
class StreetAddress
  include Receiver
  include Receiver::ActsAsHash
  rcvr_accessor :num,      Integer
  rcvr_accessor :street,   String
  rcvr_accessor :city,     String
  rcvr_accessor :state,    String
  rcvr_accessor :zip_code, Integer
end

class Vcard
  include Receiver
  include Receiver::ActsAsHash
  rcvr_accessor :name,         String
  rcvr_accessor :home_address, StreetAddress
  rcvr_accessor :work_address, StreetAddress
  rcvr_accessor :phone,        String
end

class RecursiveReceiver < Wide
  include Receiver
  rcvr_accessor :a, Integer
  rcvr_accessor :b, String
  rcvr_accessor :wide_rcvr_a, Wide
  rcvr_accessor :rec_field, RecursiveReceiver
  rcvr_accessor :wide_rcvr_b, Wide
  rcvr_accessor :c, String
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

    it 'accepts an empty arg set (as if it got an empty hash)' do
      obj = mock
      @klass.should_receive(:new).and_return(obj)
      obj.should_receive(:receive!).with({})
      @klass.receive()
    end

    it 'accepts an empty hash' do
      obj = mock
      @klass.should_receive(:new).and_return(obj)
      obj.should_receive(:receive!).with({})
      @klass.receive({})
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

  ADDRESS_TUPLE = ['Homer J Simpson', 742, 'Evergreen Terr', 'Springfield', 'AZ', 12345, 100, 'Industrial Way', 'Springfield', 'WY', 98765, '800-BITE-ME']
  ADDRESS_HASH = {
        :name => 'Homer J Simpson',
        :home_address => { :num => 742, :street => 'Evergreen Terr', :city => 'Springfield', :state => 'AZ', :zip_code => 12345 },
        :work_address => { :num => 100, :street => 'Industrial Way', :city => 'Springfield', :state => 'WY', :zip_code => 98765 },
    :phone => '800-BITE-ME'}

  describe '.consume_tuple' do
    it 'receives a tuple, assigning to rcvrs in order' do
      obj = Vcard.consume_tuple(ADDRESS_TUPLE.dup)
      obj.to_hash.should == ADDRESS_HASH
    end

    it 'allows empty tuple'

    it '?breaks? on too-long tuple'
  end

  describe '#to_tuple' do
    it 'flattens' do
      obj = Vcard.receive(ADDRESS_HASH)
      obj.to_tuple.should == ADDRESS_TUPLE
    end
  end

  describe '.tuple_keys' do
    it 'for a simple receiver, produces attrs in order' do
      StreetAddress.tuple_keys.should == [:num, :street, :city, :state, :zip_code]
    end

    it 'for a complex receiver, in-order traverses the tree' do
      Vcard.tuple_keys.should == [:name, :num, :street, :city, :state, :zip_code, :num, :street, :city, :state, :zip_code, :phone]
    end

    it 'does not recurse endlessly' do
      RecursiveReceiver.tuple_keys.should == [:my_int, :a, :b, :my_int, RecursiveReceiver, :my_int, :c]
    end
  end

  describe '.receive_foo' do
    it 'injects a superclass, so I can call super() in receive_foo'
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

    it 'accepts a type alias but uses the aliased class' do
      @klass.rcvr_accessor :my_symbol, :symbol
      @klass.rcvr_accessor :my_bytes,  :bytes
      @klass.receiver_attrs[:my_symbol][:type].should == Symbol
      @klass.receiver_attrs[:my_bytes ][:type].should == String
    end

    it 'does not accept an unknown type' do
      lambda{ @klass.rcvr_accessor :my_symbol, :oxnard }.should raise_error(ArgumentError, "Can\'t handle type oxnard: is it a Class or one of the TYPE_ALIASES?")
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

  describe 'default values' do
    it 'rcvr accepts a default for an attribute' do
      @klass.rcvr_reader :will_get_a_value, Integer, :default => 12
      @klass.rcvr_reader :has_a_default, Integer, :default => 5
      obj = @klass.receive(:my_int => 3, :will_get_a_value => 9)
      obj.my_int.should == 3
      obj.has_a_default.should == 5
      obj.will_get_a_value.should == 9
    end

    it 'does not use default if value is set-but-nil' do
      @klass.rcvr_reader :has_a_default, Integer, :default => 5
      obj = @klass.receive(:my_int => 3, :has_a_default => nil)
      obj.has_a_default.should be_nil
    end
  end

  describe 'required attributes' do
    it 'rcvr accepts required attributes'
  end

  describe 'typed collections' do
    it 'sets a type for an array with :of => Type' do
      @klass.rcvr_accessor :array_of_symbol, Array, :of => Symbol
      obj = @klass.receive(:array_of_symbol => [:a, 'b', 'c'])
      obj.array_of_symbol.should == [:a, :b, :c]
    end

    it 'accepts nil if value is nil' do
      @klass.rcvr_accessor :array_of_symbol, Array, :of => Symbol
      obj = @klass.receive(:array_of_symbol => nil)
      obj.array_of_symbol.should == nil
    end

    it 'accepts complex class as :of => Type' do
      class Foo ; include Receiver ; rcvr_accessor(:foo, Integer) ; end
      @klass.rcvr_accessor :array_of_obj, Array, :of => Foo
      obj = @klass.receive( :array_of_obj => [ {:foo => 3}, {:foo => 5} ] )
      obj.array_of_obj.first.foo.should == 3
      obj.array_of_obj.last.foo.should == 5
    end

    it 'sets a type for a hash with :of => Type' do
      @klass.rcvr_accessor :hash_of_symbol, Hash, :of => Symbol
      obj = @klass.receive(:hash_of_symbol => { :a => 'val_a', 'b' => :val_b , 'c' => 'val_c' })
      obj.hash_of_symbol.should == { :a => :val_a, 'b' => :val_b , 'c' => :val_c }
    end
  end

  describe '.rcvr_remaining' do
    it 'creates a dummy receiver for the extra params' do
      @klass.should_receive(:rcvr_reader).with(:bob, Hash, {:foo => :bar})
      @klass.rcvr_remaining :bob, :foo => :bar
    end
    it 'does not get params that go with defined attrs (even if there is no writer)' do
      @klass.rcvr_remaining :bob
      hsh = {:my_int => 3, :foo => :bar, :width => 5}
      obj = @klass.receive(hsh)
      obj.bob.should == {:foo => :bar, :width => 5}
      hsh.should == {:my_int => 3, :foo => :bar, :width => 5}
    end
    it 'does not get params whose key starts with "_"' do
      @klass.rcvr_remaining :bob
      hsh = {:my_int => 3, :foo => :bar, :width => 5, :_ignored => 9}
      obj = @klass.receive(hsh)
      obj.bob.should == {:foo => :bar, :width => 5}
    end
    it 'stores them, replacing a previous value' do
      @klass.rcvr_remaining :bob
      obj = @klass.new
      obj.instance_variable_set("@bob", {:foo => 9, :width => 333, :extra => :will_be_gone})
      obj.receive!({ :my_int => 3, :foo => :bar, :width => 5 })
      obj.bob.should == {:foo => :bar, :width => 5}
    end
  end

  describe '.after_receive, #run_after_receivers' do
    it 'calls each block in order' do
      @klass.after_receive{|hsh| hsh.i_am_calling_you_first }
      @klass.after_receive{|hsh| hsh.i_am_calling_you_second }
      @klass.after_receive{|hsh| hsh.i_am_calling_you_third }
      hsh = {:my_int => 3}
      hsh.should_receive(:i_am_calling_you_first).ordered
      hsh.should_receive(:i_am_calling_you_second).ordered
      hsh.should_receive(:i_am_calling_you_third).ordered
      @klass.receive(hsh)
    end

    it 'calls the block with the full receive hash' do
      @klass.after_receive{|hsh| hsh.i_am_calling_you }
      hsh = {}
      hsh.should_receive(:i_am_calling_you)
      @klass.receive(hsh)
    end
  end

  describe '#unset' do
    it 'nukes any existing instance_variable' do
      obj = @klass.new
      obj.my_int = 3
      obj.instance_variable_get('@my_int').should == 3
      obj.send(:unset!, :my_int)
      obj.instance_variable_get('@my_int').should be_nil
      obj.instance_variables.should == []
    end

    it 'succeeds even if instance_variable never set' do
      obj = @klass.new
      obj.send(:unset!, :my_int)
      obj.instance_variable_get('@my_int').should be_nil
      obj.instance_variables.should == []
    end

  end

  describe 'attr_set?' do
    it 'is set if the corresponding instance_variable exists' do
      obj = @klass.new
      obj.attr_set?(:my_int).should == false
      obj.instance_variable_set('@my_int', 3)
      obj.attr_set?(:my_int).should == true
    end

    it 'can be set but nil or false' do
      @klass.rcvr_accessor :bool_field, Boolean
      @klass.rcvr_accessor :str_field,  String
      obj = @klass.new
      obj.attr_set?(:bool_field).should == false
      obj.attr_set?(:str_field).should == false
      obj.instance_variable_set('@bool_field', false)
      obj.instance_variable_set('@str_field',  nil)
      obj.attr_set?(:bool_field).should == true
      obj.attr_set?(:str_field).should == true
    end
  end

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

    it 'receives even if there is no setter' do
      @klass.rcvr_reader :a, Integer
      @klass.rcvr        :b, Integer
      obj = @klass.receive :my_int => 3, :a => 5, :b => 7
      obj.should_not respond_to(:a=)
      obj.should_not respond_to(:b=)
      obj.my_int.should == 3
      obj.a.should == 5
      obj.instance_variable_get("@b").should == 7
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
        @klass.rcvr_accessor :nil_field, receivable
        obj = @klass.receive(:nil_field => nil)
        obj.nil_field.should be_nil
      end
    end
    [String].each do |receivable|
      it "#{receivable} accepts nil as empty string" do
        @klass.rcvr_accessor :nil_field, receivable
        obj = @klass.receive(:nil_field => nil)
        obj.nil_field.should == ""
      end
    end

    it "lets me use an anonymous class as a received type" do
      @klass_2 = Class.new(Wide)
      @klass_2.rcvr_accessor :maw, Integer
      @klass.rcvr_accessor :k2, @klass_2
      obj = @klass.receive({ :my_int => 3, :k2 => { :maw => 2 }})
      obj.k2.maw.should == 2
    end

    it 'keeps values across a receive!' do
      @klass.rcvr_accessor :repeated,    Integer
      @klass.rcvr_accessor :just_second, Integer
      obj = @klass.receive( :my_int => 1, :repeated => 3)
      [obj.my_int, obj.repeated, obj.just_second].should == [1, 3, nil]
      obj.receive!(:repeated => 20, :just_second => 30)
      [obj.my_int, obj.repeated, obj.just_second].should == [1, 20, 30]
    end

    # ---------------------------------------------------------------------------

    it 'core class .receive method' do
      Symbol.receive('hi').should == :hi
      Integer.receive(3.4).should == 3
      Float.receive("4.5").should == 4.5
      String.receive(4.5).should == "4.5"
      Time.receive('1985-11-05T04:03:02Z').should == Time.parse('1985-11-05T04:03:02Z')
      Date.receive('1985-11-05T04:03:02Z').should == Date.parse('1985-11-05')
      Array.receive('hi').should == ['hi']
      Hash.receive({:hi => :there}).should == {:hi => :there}
      Boolean.receive("false").should == false
      NilClass.receive(nil).should == nil
      Object.receive(:fnord).should == :fnord
    end

    # ---------------------------------------------------------------------------

    def self.it_correctly_converts(type, orig, desired)
      it "for #{type} converts #{orig.inspect} to #{desired.inspect}" do
        field = "#{type}_field".to_sym
        @klass.rcvr_accessor field, type
        obj = @klass.receive( field => orig )
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
          @klass.rcvr_accessor :nil_field, NilClass
          lambda{ @klass.receive( :nil_field => 'hello' ) }.should raise_error(ArgumentError, "This field must be nil, but [hello] was given")
        end
      end
    end

  end
end
