require 'spec_helper'

# libs under test
require 'gorillib/builder'
require 'gorillib/builder/field'

# testing helpers
require 'gorillib/hash/compact'
require 'model_test_helpers'

describe Gorillib::Builder, :model_spec => true, :builder_spec => true do
  let(:example_val  ){ mock('example val') }
  subject{ car_class }

  context 'examples:' do
    subject{ car_class }
    it 'type-converts values' do
      obj = subject.receive(     :name => 'wildcat', :make_model => 'Buick Wildcat', :year => "1968", :doors => "2" )
      obj.attributes.should == { :name => :wildcat,  :make_model => 'Buick Wildcat', :year =>  1968,  :doors =>  2, :engine => nil }
    end
    it 'handles nested structures' do
      obj = subject.receive(
        :name => 'wildcat', :make_model => 'Buick Wildcat', :year => "1968", :doors => "2",
        :engine => { :carburetor => 'edelbrock', :volume => "455", :cylinders => '8' })
      obj.attributes.values_at(:name, :make_model, :year, :doors).should == [:wildcat, 'Buick Wildcat', 1968,  2 ]
      obj.engine.attributes.values_at(:carburetor, :volume, :cylinders).should == [:edelbrock, 455, 8 ]
    end
    it 'lets you dive down' do
      wildcat.engine.attributes.values_at(:carburetor, :volume, :cylinders).should == [:stock, 455, 8 ]
      wildcat.engine(:cylinders => 6) do
        volume   383
      end
      wildcat.engine.attributes.values_at(:carburetor, :volume, :cylinders).should == [:stock, 383, 6 ]
    end
    it 'lazily autovivifies members' do
      ford_39.read_attribute(:engine).should be_nil
      ford_39.engine(:cylinders => 6)
      ford_39.read_attribute(:engine).should be_a(Gorillib::Test::Engine)
      ford_39.engine.read_attribute(:cylinders).should == 6
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

    context do
      subject{ car_class.new }
      let(:sample_val){ 'fiat' }
      let(:raw_val   ){ :fiat  }
      it_behaves_like "a model field", :make_model
      it("#read_attribute is nil if never set"){ subject.read_attribute(:make_model).should == nil }
    end

    context 'calling the getset "#foo" method' do
      subject{ wildcat }

      it "with no args calls read_attribute(:foo)" do
        subject.write_attribute(:doors, example_val)
        subject.should_receive(:read_attribute).with(:doors).at_least(:once).and_return(example_val)
        subject.doors.should == example_val
      end
      it "with an argument calls write_attribute(:foo)" do
        subject.write_attribute(:doors, 'gone')
        subject.should_receive(:write_attribute).with(:doors, example_val).and_return('returned')
        result = subject.doors(example_val)
        result.should == 'returned'
      end
      it "with multiple arguments is an error" do
        expect{ subject.doors(1, 2) }.to raise_error(ArgumentError, "wrong number of arguments (2 for 0..1)")
      end
    end

    it "does not create a writer method #foo=" do
      subject{ car_class }
      subject.should     be_method_defined(:doors)
      subject.should_not be_method_defined(:doors=)
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
    let(:sample_val){ Gorillib::Collection.receive([wildcat], car_class, :name) }
    let(:raw_val   ){ [ wildcat.attributes ] }
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
