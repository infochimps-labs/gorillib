require File.expand_path('../spec_helper', File.dirname(__FILE__))

# libs under test
require 'gorillib/builder'
require 'gorillib/builder/field'
# testing helpers
require 'gorillib/hash/compact'
require 'model_test_helpers'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Builder, :model_spec => true, :builder_spec => true do
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
  let(:example_engine){ Gorillib::Test::Engine.new( :name => 'Geo Metro 1.0L', :volume => 61, :cylinders => 3 )}
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

  context 'receive!' do
    it 'accepts a configurate block' do
      expect_7 = nil ; expect_obj = nil
      wildcat.receive!({}){    expect_7 = 7 ; expect_obj = self }
      expect_7.should == 7 ; expect_obj.should  == wildcat
      expect_7 = nil ; expect_obj = nil
      wildcat.receive!({}){|c| expect_7 = 7 ; expect_obj = c }
      expect_7.should    == 7 ; expect_obj.should  == wildcat
    end
  end

  context ".field" do
    subject{ car_class.new }
    let(:sample_val){ 'fiat' }
    let(:raw_val   ){ :fiat  }
    it_behaves_like "a model field", :make_model
    it("#read_attribute is nil if never set"){ subject.read_attribute(:make_model).should == nil }

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
    it "calling the getset method #foo with multiple arguments is an error" do
      ->{ wildcat.doors(1, 2) }.should raise_error(ArgumentError, "wrong number of arguments (2 for 0..1)")
    end
    it "does not create a writer method #foo=" do
      wildcat.should     respond_to(:doors)
      wildcat.should_not respond_to(:doors=)
    end
  end

  context ".member" do
    subject{ car_class.new }
    let(:sample_val){ example_engine }
    let(:raw_val   ){ example_engine.attributes }
    it_behaves_like "a model field", :engine
    it("#read_attribute is nil if never set"){ subject.read_attribute(:engine).should == nil }

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
    it "calling the getset method #foo with multiple arguments is an error" do
      ->{ wildcat.doors(1, 2) }.should raise_error(ArgumentError, "wrong number of arguments (2 for 0..1)")
    end
    it "does not create a writer method #foo=" do
      wildcat.should     respond_to(:doors)
      wildcat.should_not respond_to(:doors=)
    end
  end

  context 'collections' do
    subject{ garage }
    let(:sample_val){ wildcat }
    let(:raw_val   ){ wildcat.attributes }
    it_behaves_like "a model field", :cars
    it("#read_attribute is an empty collection if never set"){ subject.read_attribute(:cars).should == Gorillib::Collection.new }

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

    context 'collection getset method' do
      it 'clxn(:name, existing_object) -- replaces with given object, does not call block' do
        test = nil
        subject.car(:wildcat, wildcat).should equal(wildcat){ test = 3 }
        test.should be_nil
      end
      it 'clxn(:name) (missing & no attributes given) -- autovivifies' do
        subject.car(:cadzilla).should == Gorillib::Test::Car.new(:name => :cadzilla)
      end
      it 'clxn(:name, &block) (missing & no attributes given) -- autovivifies, execs block' do
        test = nil
        subject.car(:cadzilla){ test = 7 }
        test.should == 7
      end
      it 'clxn(:name, :attr => val) (missing, attributes given) -- creates item' do
        subject.car(:cadzilla, :doors => 3).should == Gorillib::Test::Car.new(:name => :cadzilla, :doors => 3)
      end
      it 'clxn(:name, :attr => val) (missing, attributes given) -- creates item, execs block' do
        test = nil
        subject.car(:cadzilla, :doors => 3){ test = 7 }
        test.should == 7
      end
      it 'clxn(:name, :attr => val) (present, attributes given) -- updates item' do
        subject.car(:wildcat, wildcat)
        subject.car(:wildcat, :doors => 9)
        wildcat.doors.should == 9
      end
      it 'clxn(:name, :attr => val) (present, attributes given) -- updates item, execs block' do
        subject.car(:wildcat, wildcat)
        subject.car(:wildcat, :doors => 9){ self.make_model 'WILDCAT' }
        wildcat.doors.should == 9
        wildcat.make_model.should == 'WILDCAT'
      end
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
#       it "retrieves a named model"
#       it "accepts an attribute hash to update the member"
#       it "has behavior for collection member"
#     end
#   end
# end
