require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/metaprogramming/cattr_accessor'

describe 'metaprogramming' do
  describe 'cattr_accessor' do
    before do
      @class = Class.new do
        cattr_accessor :foo
        cattr_accessor :bar,  :instance_writer => false
        cattr_reader   :shaq, :instance_reader => false
      end
      @object = @class.new
    end

    it 'uses mattr default' do
      @class.foo.should be_nil
      @object.foo.should be_nil
    end

    it 'sets mattr value' do
      @class.foo = :test
      @object.foo.should == :test

      @object.foo = :test2
      @class.foo.should == :test2
    end

    it 'with instance_writer => false, does not create an instance writer' do
      @class.should respond_to(:foo)
      @class.should respond_to(:foo=)
      @object.should respond_to(:bar)
      @object.should_not respond_to(:bar=)
    end

    it 'with instance_reader => false, does not create an instance reader' do
      @class.should respond_to(:shaq)
      @object.should_not respond_to(:shaq)
      @object.should_not respond_to(:shaq=)
    end
  end
end
