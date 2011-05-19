require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/metaprogramming/aliasing'

module BarMethodAliaser
  def self.included(foo_class)
    foo_class.class_eval do
      include BarMethods
      alias_method_chain :bar, :baz
    end
  end
end

module BarMethods
  def bar_with_baz
    bar_without_baz << '_with_baz'
  end

  def quux_with_baz!
    quux_without_baz! << '_with_baz'
  end

  def quux_with_baz?
    false
  end

  def quux_with_baz=(v)
    send(:quux_without_baz=, v) << '_with_baz'
  end

  def duck_with_orange
    duck_without_orange << '_with_orange'
  end
end

describe 'metaprogramming' do
  before do
    Object.const_set :FooClassWithBarMethod, Class.new{ def bar() 'bar' end }
    @instance = FooClassWithBarMethod.new
  end

  after do
    Object.instance_eval { remove_const :FooClassWithBarMethod }
  end

  describe 'alias_method_chain' do
    it 'creates a with_ and without_ method that chain' do
      @instance.should respond_to(:bar)
      feature_aliases = [:bar_with_baz, :bar_without_baz]

      feature_aliases.each do |method|
        @instance.should_not respond_to(method)
      end
      @instance.bar.should == 'bar'

      FooClassWithBarMethod.class_eval{ include BarMethodAliaser }
      feature_aliases.each do |method|
        @instance.should respond_to(method)
      end
      @instance.bar.should == 'bar_with_baz'
      @instance.bar_without_baz.should == 'bar'
    end

    it 'with bang' do
      FooClassWithBarMethod.class_eval do
        def quux!; 'quux' end
      end

      @instance.should_not respond_to(:quux_with_baz!)
      FooClassWithBarMethod.class_eval do
        include BarMethodAliaser
        alias_method_chain :quux!, :baz
      end
      @instance.should respond_to(:quux_with_baz!)

      @instance.quux!.should == 'quux_with_baz'
      @instance.quux_without_baz!.should == 'quux'
    end

    it 'with same names between predicates and bang methods' do
      FooClassWithBarMethod.class_eval do
        def quux!; 'quux!' end
        def quux?; true end
        def quux=(v); 'quux=' end
      end

      @instance.should_not respond_to(:quux_with_baz!)
      @instance.should_not respond_to(:quux_with_baz?)
      @instance.should_not respond_to(:quux_with_baz=)

      FooClassWithBarMethod.class_eval { include BarMethodAliaser }
      @instance.should respond_to(:quux_with_baz!)
      @instance.should respond_to(:quux_with_baz?)
      @instance.should respond_to(:quux_with_baz=)

      FooClassWithBarMethod.alias_method_chain :quux!, :baz
      @instance.quux!.should == 'quux!_with_baz'
      @instance.quux_without_baz!.should == 'quux!'

      FooClassWithBarMethod.alias_method_chain :quux?, :baz
      @instance.quux?.should == false
      @instance.quux_without_baz?.should == true

      FooClassWithBarMethod.alias_method_chain :quux=, :baz
      @instance.send(:quux=, 1234).should == 'quux=_with_baz'
      @instance.send(:quux_without_baz=, 1234).should == 'quux='
    end

    it 'with_feature_punctuation' do
      FooClassWithBarMethod.class_eval do
        def quux; 'quux' end
        def quux?; 'quux?' end
        include BarMethodAliaser
        alias_method_chain :quux, :baz!
      end

      @instance.quux_with_baz!.should == 'quux_with_baz'

      lambda{ FooClassWithBarMethod.alias_method_chain :quux?, :baz! }.should raise_error(NameError)
    end

    it 'yields target and punctuation' do
      args = nil
      FooClassWithBarMethod.class_eval do
        def quux?; end
        include BarMethods

        FooClassWithBarMethod.alias_method_chain :quux?, :baz do |target, punctuation|
          args = [target, punctuation]
        end
      end

      args.should_not be_nil
      args[0].should == 'quux'
      args[1].should == '?'
    end

    it 'preserves private method status' do
      FooClassWithBarMethod.class_eval do
        def duck; 'duck' end
        include BarMethodAliaser
        private :duck
        alias_method_chain :duck, :orange
      end

      lambda{ @instance.duck }.should raise_error(NoMethodError)

      @instance.instance_eval{ duck }.should == 'duck_with_orange'
      FooClassWithBarMethod.should be_private_method_defined(:duck)
    end

    it 'preserves protected method status' do
      FooClassWithBarMethod.class_eval do
        def duck; 'duck' end
        include BarMethodAliaser
        protected :duck
        alias_method_chain :duck, :orange
      end

      lambda{ @instance.duck }.should raise_error(NoMethodError)

      @instance.instance_eval{ duck }.should == 'duck_with_orange'
      FooClassWithBarMethod.should be_protected_method_defined(:duck)
    end

    it 'preserves public method status' do
      FooClassWithBarMethod.class_eval do
        def duck; 'duck' end
        include BarMethodAliaser
        public :duck
        alias_method_chain :duck, :orange
      end

      @instance.duck.should == 'duck_with_orange'
      FooClassWithBarMethod.should be_public_method_defined(:duck)
    end
  end
end
