require File.expand_path('../spec_helper', File.dirname(__FILE__))
# related libs
require 'gorillib/record'
require 'gorillib/record/field'
require 'gorillib/record/defaults'
# libs under test
require 'gorillib/builder'
require 'gorillib/builder/field'
# testing helpers
require 'gorillib/string/simple_inflector'
require 'gorillib/hash/compact'
require 'record_test_helpers'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Builder, :record_spec => true do
  after(:each){   Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }

  let(:example_class) do
    class Gorillib::Test::Engine
      include Gorillib::Builder
      field     :carburetor,   Symbol, :default => :stock
      field     :volume,       Integer
      field     :cylinders,    Integer
      self
    end
    class Gorillib::Test::Car
      include Gorillib::Builder
      field    :name,          Symbol
      field    :make_model,    String
      field    :year,          Integer
      field    :doors,         Integer
      member   :engine,        Gorillib::Test::Engine
      self
    end
    class Gorillib::Test::Garage
      include Gorillib::Builder
      collection :cars,       Gorillib::Test::Car
      self
    end
    Gorillib::Test::Car
  end
  let(:car_class){    example_class ; Gorillib::Test::Car    }
  let(:garage_class){ example_class ; Gorillib::Test::Garage }
  let(:wildcat) do
    car_class.receive( :name => :wildcat,
      :make_model => 'Buick Wildcat', :year => 1968, :doors => 2,
      :engine => { :volume => 455, :cylinders => 8 } )
  end
  let(:ford_39) do
    car_class.receive( :name => :ford_39,
      :make_model => 'Ford Tudor Sedan', :year => 1939, :doors => 2, )
  end
  let(:garage) do
    garage_class.new
  end
  subject{ car_class }
  let(:example_val  ){ mock('example val') }

  context 'examples:' do
    it 'type-converts values' do
      obj = subject.receive(     :name => 'wildcat', :make_model => 'Buick Wildcat', :year => "1968", :doors => "2" )
      obj.attributes.should == { :name => :wildcat,  :make_model => 'Buick Wildcat', :year =>  1968,  :doors =>  2, :engine => nil }
    end
    it 'handles nested structures' do
      obj = subject.receive(
        :name => 'wildcat', :make_model => 'Buick Wildcat', :year => "1968", :doors => "2",
        :engine => { :carburetor => 'edelbrock', :volume => "455", :cylinders => '8' })
      obj.attributes.except(:engine).should == {
        :name => :wildcat,  :make_model => 'Buick Wildcat', :year =>  1968,  :doors =>  2 }
      obj.engine.attributes.should == {
        :carburetor => :edelbrock, :volume => 455, :cylinders => 8 }
    end
    it 'lets you dive down' do
      wildcat.engine.attributes.should == { :carburetor => :stock, :volume => 455, :cylinders => 8 }
      wildcat.engine(:cylinders => 6) do
        volume   383
      end
      wildcat.engine.attributes.should == { :carburetor => :stock, :volume => 383, :cylinders => 6}
    end
    it 'lazily autovivifies members' do
      ford_39.read_attribute(:engine).should be_nil
      ford_39.engine(:cylinders => 6)
      ford_39.engine.attributes.should == { :carburetor => :stock, :volume => nil, :cylinders => 6}
    end
  end

  context ".field" do
    it "describes an attribute" do
      car_class.should have_field(:name)
      obj = car_class.new
      obj.read_attribute(:name).should be_nil
      obj.attribute_set?(:name).should be_false
      obj.write_attribute(:name, :bob).should == :bob
      obj.read_attribute(:name).should == :bob
      obj.attribute_set?(:name).should be_true
      obj.receive_name('bob').should == obj
      obj.read_attribute(:name).should == :bob
    end
    it "calling the getset method #foo with no args calls read_attribute(:foo)" do
      wildcat.write_attribute(:doors, example_val)
      wildcat.should_receive(:read_attribute).with(:doors).at_least(:once).and_return(example_val)
      wildcat.doors.should == example_val
    end
    it "calling the getset method #foo with an argument calls write_attribute(:foo)" do
      wildcat.write_attribute(:doors, 'gone')
      wildcat.should_receive(:write_attribute).with(:doors, example_val).and_return('returned')
      result = wildcat.doors(example_val)
      result.should == 'returned'
    end
    # it "calling the getset method #foo with multiple arguments is an error" do
    #   ->{ wildcat.my_field(1, 2) }.should raise_error(ArgumentError, "wrong number of arguments (2 for 0..1)")
    # end
    # it "does not create a writer method #foo=" do
    #   wildcat.should     respond_to(:my_field)
    #   wildcat.should_not respond_to(:my_field=)
    # end
  end

  # context ".member" do
  #   it "describes an attribute" do
  #     wildcat.attributes.should == { :my_field => 69, :str_field=>nil, :sym_field=>nil }
  #     wildcat.write_attribute(:my_field, 3).should == 3
  #     wildcat.attributes.should == { :my_field => 3, :str_field=>nil, :sym_field=>nil }
  #     wildcat.read_attribute(:my_field).should == 3
  #   end
  #   it "calling the getset method #foo with no args calls read_attribute(:foo)" do
  #     wildcat.write_attribute(:my_field, example_val)
  #     # wildcat.should_receive(:read_attribute).with(:my_field).at_least(:once).and_return(example_val)
  #     wildcat.my_field.should == example_val
  #   end
  #   it "calling the getset method #foo with an argument calls write_attribute(:foo)" do
  #     wildcat.should_receive(:write_attribute).with(:my_field, example_val).and_return(7)
  #     ( wildcat.my_field(example_val) ).should == 7
  #   end
  #   it "calling the getset method #foo with multiple arguments is an error" do
  #     ->{ wildcat.my_field(1, 2) }.should raise_error(ArgumentError, "wrong number of arguments (2 for 0..1)")
  #   end
  #   it "does not create a writer method #foo=" do
  #     wildcat.should     respond_to(:my_field)
  #     wildcat.should_not respond_to(:my_field=)
  #   end
  # end

  context 'collections' do
    subject{ garage }
    it 'a collection holds named objects' do
      garage.cars.should be_empty

      # create a car with a hash of attributes
      garage.car(:cadzilla, :make_model => 'Cadillac, Mostly')
      # ...and retrieve it by name
      cadzilla = garage.car(:cadzilla)

      # add a car explicitly
      garage.car(:wildcat,  wildcat)
      garage.car(:wildcat).should     equal(wildcat)

      # duplicate a car
      garage.car(:ford_39, ford_39.attributes.compact)
      garage.car(:ford_39).should     ==(ford_39)
      garage.car(:ford_39).should_not equal(ford_39)

      # examine the whole collection
      garage.cars.keys.should == [:cadzilla, :wildcat, :ford_39]
      garage.cars.should == Gorillib::Collection.receive([cadzilla, wildcat, ford_39], car_class, :name)
    end
    it 'lazily autovivifies collection items' do
      garage.cars.should be_empty
      garage.car(:chimera).should be_a(car_class)
      garage.cars.should == Gorillib::Collection.receive([{:name => :chimera}], car_class, :name)
    end
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
