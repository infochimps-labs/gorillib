require 'spec_helper'
require 'gorillib/dsl_object'


describe DslObject do
  let(:test_property) { :yo_momma }
  let(:attrs)         { { test_property => "is so fat" } }

  after(:each) do
    DslObject.send(:remove_method, test_property) if DslObject.method_defined? test_property
    DslObject.properties = {}
  end

  context DslObject, ".new" do
    subject { DslObject.new(attrs) }

    it "transforms an attribute hash given as a constructor argument into properties" do
      subject.to_hash.should include attrs
      subject.should respond_to test_property
    end
  end

  context DslObject, ".property" do
    subject { DslObject.new(attrs) }    
    
    it "defines a method on a DslObject instance" do
      DslObject.property(test_property)
      subject.should respond_to test_property
    end
    
    it "allows a default return value to be established for a property" do
      DslObject.property(test_property, :default => "is so fat")
      subject.send(test_property).should  == "is so fat"
    end
    
    let(:existing_method) { :class }
    it "does not allow a property to override an existing method" do
      DslObject.property(existing_method, :default => "override")
      subject.send(existing_method).should_not == "override"
      subject.should_not be_instance_variable_defined("@" + existing_method.to_s)
    end
  end

  context DslObject, "#configure" do
    let(:dsl_object) { DslObject.new }
    subject          { double :context_obj, :delegate => dsl_object }
    
    it "delegates the configure block to the DslObject instance" do
      dsl_object.should_receive(test_property)
      subject.should_not_receive(test_property)
      subject.delegate.configure { yo_momma "is so fat" }
    end
  end

  context DslObject, "#to_s" do
    subject { DslObject.new(attrs) }
    
    it "prints to the screen with its class name and properties" do
      subject.to_s.should =~ /#{subject.class}.*#{attrs}/
    end
  end

  context DslObject, "#set" do
    subject { DslObject.new(attrs) }

    it "sets a property correctly" do
      subject.set(test_property, "is so dumb")
      subject.to_hash.should include(test_property => "is so dumb" )
    end
  end

  context DslObject, "#get" do
    subject { DslObject.new(attrs) }    

    it "returns a property correctly" do
      subject.get(test_property).should == "is so fat"
    end
  end

  context DslObject, "#set?" do
    subject { DslObject.new(attrs) }    
    
    it "correctly determines if a property is set" do
      subject.set?(test_property).should be_true
      subject.set?(:not_set).should be_false
    end
  end

  context DslObject, "#unset!" do
    subject { DslObject.new(attrs) }    
    
    it "unsets a property" do
      subject.unset!(test_property)
      subject.set?(test_property).should be_false
    end
  end
end


