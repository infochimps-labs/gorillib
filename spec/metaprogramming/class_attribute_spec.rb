require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/metaprogramming/class_attribute'

describe 'metaprogramming' do
  describe 'class_attribute' do
    before do
      @klass = Class.new { class_attribute :setting }
      @sub = Class.new(@klass)
    end

    it 'does not have an effect if already provided by another lib.'

    it 'defaults to nil' do
      @klass.setting.should be_nil
      @sub.setting.should be_nil
    end

    it 'is inheritable' do
      @klass.setting = 1
      @sub.setting == 1
    end

    it 'is overridable' do
      @sub.setting = 1
      @klass.setting.should be_nil

      @klass.setting = 2
      @sub.setting.should == 1

      Class.new(@sub).setting.should == 1
    end

    it 'creates a query? method' do
      @klass.setting?.should == false
      @klass.setting = 1
      @klass.setting?.should == true
    end

    it 'instance reader delegates to class' do
      @klass.new.setting.should be_nil

      @klass.setting = 1
      @klass.new.setting.should == 1
    end

    it 'instance override' do
      object = @klass.new
      object.setting = 1
      @klass.setting.should be_nil
      @klass.setting = 2
      object.setting.should == 1
    end

    it 'instance query' do
      object = @klass.new
      object.setting?.should == false
      object.setting = 1
      object.setting?.should == true
    end

    it 'disabling instance writer' do
      object = Class.new { class_attribute :setting, :instance_writer => false }.new
      lambda{ object.setting = 'boom' }.should raise_error(NoMethodError)
    end

    it 'works well with singleton classes' do
      object = @klass.new
      object.singleton_class.setting = 'foo'
      object.setting.should == 'foo'
    end

    it 'setter returns set value' do
      val = @klass.send(:setting=, 1)
      val.should == 1
    end
  end
end
