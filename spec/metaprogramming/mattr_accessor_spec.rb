require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/metaprogramming/mattr_accessor'

describe Module do
  describe 'mattr_accessor' do
    before do
      m = @module = Module.new do
        mattr_accessor :foo
        mattr_accessor :bar, :instance_writer => false
        mattr_reader   :shaq, :instance_reader => false
      end
      @class = Class.new
      @class.instance_eval { include m }
      @object = @class.new
    end

    it 'uses mattr default' do
      @module.foo.should be_nil
      @object.foo.should be_nil
    end

    it 'sets mattr value' do
      @module.foo = :test
      @object.foo.should == :test

      @object.foo = :test2
      @module.foo.should == :test2
    end

    it 'with :instance_writer => false, does not create instance writer' do
      @module.should respond_to(:foo)
      @module.should respond_to(:foo=)
      @object.should respond_to(:bar)
      @object.should_not respond_to(:bar=)
    end

    it 'with :instance_writer => false, does not create instance reader' do
      @module.should respond_to(:shaq)
      @object.should_not respond_to(:shaq)
      @object.should_not respond_to(:shaq=)
    end
  end
end

