require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/aliasing'

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

class MethodAliasingTest < Test::Unit::TestCase
  def setup
    Object.const_set :FooClassWithBarMethod, Class.new { def bar() 'bar' end }
    @instance = FooClassWithBarMethod.new
  end

  def teardown
    Object.instance_eval { remove_const :FooClassWithBarMethod }
  end

  def test_alias_method_chain
    assert @instance.respond_to?(:bar)
    feature_aliases = [:bar_with_baz, :bar_without_baz]

    feature_aliases.each do |method|
      assert !@instance.respond_to?(method)
    end

    assert_equal 'bar', @instance.bar

    FooClassWithBarMethod.class_eval { include BarMethodAliaser }

    feature_aliases.each do |method|
      assert_respond_to @instance, method
    end

    assert_equal 'bar_with_baz', @instance.bar
    assert_equal 'bar', @instance.bar_without_baz
  end

  def test_alias_method_chain_with_punctuation_method
    FooClassWithBarMethod.class_eval do
      def quux!; 'quux' end
    end

    assert !@instance.respond_to?(:quux_with_baz!)
    FooClassWithBarMethod.class_eval do
      include BarMethodAliaser
      alias_method_chain :quux!, :baz
    end
    assert_respond_to @instance, :quux_with_baz!

    assert_equal 'quux_with_baz', @instance.quux!
    assert_equal 'quux', @instance.quux_without_baz!
  end

  def test_alias_method_chain_with_same_names_between_predicates_and_bang_methods
    FooClassWithBarMethod.class_eval do
      def quux!; 'quux!' end
      def quux?; true end
      def quux=(v); 'quux=' end
    end

    assert !@instance.respond_to?(:quux_with_baz!)
    assert !@instance.respond_to?(:quux_with_baz?)
    assert !@instance.respond_to?(:quux_with_baz=)

    FooClassWithBarMethod.class_eval { include BarMethodAliaser }
    assert_respond_to @instance, :quux_with_baz!
    assert_respond_to @instance, :quux_with_baz?
    assert_respond_to @instance, :quux_with_baz=


    FooClassWithBarMethod.alias_method_chain :quux!, :baz
    assert_equal 'quux!_with_baz', @instance.quux!
    assert_equal 'quux!', @instance.quux_without_baz!

    FooClassWithBarMethod.alias_method_chain :quux?, :baz
    assert_equal false, @instance.quux?
    assert_equal true,  @instance.quux_without_baz?

    FooClassWithBarMethod.alias_method_chain :quux=, :baz
    assert_equal 'quux=_with_baz', @instance.send(:quux=, 1234)
    assert_equal 'quux=', @instance.send(:quux_without_baz=, 1234)
  end

  def test_alias_method_chain_with_feature_punctuation
    FooClassWithBarMethod.class_eval do
      def quux; 'quux' end
      def quux?; 'quux?' end
      include BarMethodAliaser
      alias_method_chain :quux, :baz!
    end

    assert_nothing_raised do
      assert_equal 'quux_with_baz', @instance.quux_with_baz!
    end

    assert_raise(NameError) do
      FooClassWithBarMethod.alias_method_chain :quux?, :baz!
    end
  end

  def test_alias_method_chain_yields_target_and_punctuation
    args = nil

    FooClassWithBarMethod.class_eval do
      def quux?; end
      include BarMethods

      FooClassWithBarMethod.alias_method_chain :quux?, :baz do |target, punctuation|
        args = [target, punctuation]
      end
    end

    assert_not_nil args
    assert_equal 'quux', args[0]
    assert_equal '?', args[1]
  end

  def test_alias_method_chain_preserves_private_method_status
    FooClassWithBarMethod.class_eval do
      def duck; 'duck' end
      include BarMethodAliaser
      private :duck
      alias_method_chain :duck, :orange
    end

    assert_raise NoMethodError do
      @instance.duck
    end

    assert_equal 'duck_with_orange', @instance.instance_eval { duck }
    assert FooClassWithBarMethod.private_method_defined?(:duck)
  end

  def test_alias_method_chain_preserves_protected_method_status
    FooClassWithBarMethod.class_eval do
      def duck; 'duck' end
      include BarMethodAliaser
      protected :duck
      alias_method_chain :duck, :orange
    end

    assert_raise NoMethodError do
      @instance.duck
    end

    assert_equal 'duck_with_orange', @instance.instance_eval { duck }
    assert FooClassWithBarMethod.protected_method_defined?(:duck)
  end

  def test_alias_method_chain_preserves_public_method_status
    FooClassWithBarMethod.class_eval do
      def duck; 'duck' end
      include BarMethodAliaser
      public :duck
      alias_method_chain :duck, :orange
    end

    assert_equal 'duck_with_orange', @instance.duck
    assert FooClassWithBarMethod.public_method_defined?(:duck)
  end
end
