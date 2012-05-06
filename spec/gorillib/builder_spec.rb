require File.expand_path('../spec_helper', File.dirname(__FILE__))
#
require 'gorillib/record'
require 'gorillib/record/field'
require 'gorillib/builder'
require 'gorillib/builder/field'
#
require 'record_test_helpers'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Builder, :record_spec => true do
  after(:each){   Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }

  let(:example_class) do
    class Gorillib::Test::ExampleBuilder
      include Gorillib::Builder
      member :my_field,  :whatever
      member :str_field, String
      member :sym_field, Symbol
      self
    end
  end
  let(:example_inst ){ subject.receive(:my_field => 69) }
  let(:example_val  ){ mock('example val') }
  subject{ example_class }

  context 'examples' do
    let(:nested_class){ Class.new(example_class){ field :another_record, self } }
    subject{ nested_class }
    it 'type-converts values' do
      obj = example_class.receive({
          :my_field => 'accepted as-is', :str_field => :bob, :sym_field => 'converted_to_sym'
        })
      obj.attributes.should == { :my_field => 'accepted as-is', :str_field => 'bob', :sym_field=>:converted_to_sym }
    end
    it 'handles nested structures' do
      obj      = nested_class.receive({ :my_field => 69 })
      obj.attributes.should == { :my_field => 69, :str_field => nil, :sym_field=>nil, :another_record => nil }
      deep_obj = nested_class.receive(:my_field => 111, :str_field => 'deep, man',
        :another_record => { :my_field => 69, :another_record => nil })
      deep_obj.attributes.should == { :my_field => 111, :str_field => 'deep, man', :sym_field=>nil, :another_record => obj }
    end

    it 'example' do
      example_inst.receive!(:another_record => { :my_field => 69, :str_field => "deep", :sym_field=>:bob, })
      p example_inst
      example_inst.another_record do
        p self
      end
      p example_inst.another_record.sym_field # .should == :voila
    end
  end

  context ".member" do
    it "describes an attribute" do
      example_inst.attributes.should == { :my_field => 69, :str_field=>nil, :sym_field=>nil }
      example_inst.write_attribute(:my_field, 3).should == 3
      example_inst.attributes.should == { :my_field => 3, :str_field=>nil, :sym_field=>nil }
      example_inst.read_attribute(:my_field).should == 3
    end
    it "calling the getset method #foo with no args calls read_attribute(:foo)" do
      example_inst.should_receive(:read_attribute).with(:my_field).and_return(example_val)
      example_inst.my_field.should == example_val
    end
    it "calling the getset method #foo with an argument calls write_attribute(:foo)" do
      example_inst.should_receive(:write_attribute).with(:my_field, example_val).and_return(7)
      ( example_inst.my_field(example_val) ).should == 7
    end
    it "calling the getset method #foo with multiple arguments is an error" do
      ->{ example_inst.my_field(1, 2) }.should raise_error(ArgumentError, "wrong number of arguments (2 for 0..1)")
    end
    it "does not create a writer method #foo=" do
      example_inst.should     respond_to(:my_field)
      example_inst.should_not respond_to(:my_field=)
    end
  end

  context ".collection" do

  end

end



# describe "[builder gettersettter pattern]" do
#
#   it "supplies a gettersettter method #foo, and no method #foo="
#   it_behaves_like "... a gettersetter method"
#
#   shared_examples_for "a simple gettersettter method" do
#     it "with no arg, reads the current value"
#     it "with an argument, writes the new value"
#     it "with a nil arg, `write_attribute`s the value to nil"
#     it "returns the updated value"
#   end
#
#   shared_examples_for "a named collection gettersettter method" do
#     it "example: utensil(:spork, :tines => 3){ color :black } creates or updates a utensil named :spork with 3 tines, color black."
#     shared_examples_for 'collection member' do
#       it "executes a supplied block with no arity (`utensil(:spork){     ... }`) in the context of the collection member"
#       it "executes a supplied block with arity 1  (`utensil(:spork){ |u| ... }`) in the current context, passing the member as the block param"
#       it "does not execute a block if no block is supplied"
#       it "returns the collection member"
#     end
#     context "if absent" do
#       it "creates a new member"
#       it "with the given name"
#       it "accepts an attribute hash on behalf of the new member"
#       it "has behavior for collection member"
#     end
#     context "if exists" do
#       it "retrieves a named record"
#       it "accepts an attribute hash to update the member"
#       it "has behavior for collection member"
#     end
#   end
# end
