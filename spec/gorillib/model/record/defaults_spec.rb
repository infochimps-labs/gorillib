require 'spec_helper'

require 'gorillib/model'
require 'gorillib/model/field'
require 'gorillib/model/defaults'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Model, :model_spec => true do
  after(:each){   Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }

  let(:car_class) do
    class Gorillib::Test::Car
      include Gorillib::Model
      field    :name,          Symbol
      field    :make_model,    String
      field    :year,          Integer
      field    :style,         Symbol, :default => :sedan
      field    :doors,         Integer,
        :default => ->{ [:coupe, :convertible].include?(style) ? 2 : 4 }
      self
    end
    Gorillib::Test::Car
  end
  let(:wildcat) do
    car_class.receive( :name => :wildcat, :make_model => 'Buick Wildcat', :year => 1968, :doors => 2 )
  end
  let(:ford_39) do
    car_class.receive( :name => :ford_39 )
  end
  let(:year_field ){ car_class.fields[:year] }
  let(:doors_field){ car_class.fields[:doors] }
  let(:style_field){ car_class.fields[:style] }

  describe 'Field#default' do
    it 'is itself a field on Gorillib::Model::Field (boy that is confusing)' do
      Gorillib::Model::Field.should have_field(:default)
    end
    context '#has_default?' do
      it 'is true if the default is set' do
        year_field.should_not have_default
        year_field.default = '2012'
        year_field.should have_default
      end
    end
  end

  describe '#attribute_default' do
    before{ car_class.class_eval{ public :attribute_default } }

    it "if the default does not exist, returns nil" do
      ford_39.attribute_default(year_field).should be_nil
    end
    it "if the default is a value, returns it, dup'd if possible" do
      ford_39.attribute_default(style_field).should == :sedan
      year_val = mock ; dupd_year_val = mock
      year_val.should_receive(:try_dup).and_return(dupd_year_val)
      year_field.default = year_val
      ford_39.attribute_default(year_field).should equal(dupd_year_val)
    end
    it "if the default is a proc with no args, instance_exec it" do
      ford_39.style = :sedan
      ford_39.attribute_default(doors_field).should == 4
      ford_39.style = :coupe
      ford_39.attribute_default(doors_field).should == 2
    end
    it "if the default is a proc with no args, instance_exec it" do
      year_field.default = ->{ self }
      ford_39.attribute_default(year_field).should equal(ford_39)
    end
    it "if the default responds_to #call, call it, passing the instance and field name" do
      callable = mock ; expected = mock
      year_field.default = callable
      callable.should_receive(:respond_to?).with(:call).and_return(true)
      callable.should_receive(:call).with(ford_39, :year).and_return(expected)
      ford_39.stub(:read_unset_attribute).and_return('bob')
      ford_39.attribute_default(year_field).should equal(expected)
    end
    it "if the default is a proc with args, call it in current context with the model and field name" do
      this = self ; expected = mock
      year_field.default = ->(inst, field_name){ [self, inst, field_name, expected] }
      ford_39.attribute_default(year_field).should == [this, ford_39, :year, expected]
    end
  end

  describe 'reading an attribute with a default' do
    it "sets the default value on the field and returns it" do
      ford_39.attribute_set?(:doors).should be_false
      ford_39.read_attribute(:doors).should == 4
    end
    it "only calls a block default if the attribute is unset" do
      val = 0
      year_field.default = ->{ val += 1 }
      ford_39.read_attribute(:year).should == 1
      year_field.default.call.should == 2       # the next call to the block will return 3
      ford_39.read_attribute(:year).should == 1 # repeated calls give the same value
      ford_39.unset_attribute(:year)
      ford_39.read_attribute(:year).should == 3 # see! since it was unset, the block was called again.
    end
    it "is attribute_set? after" do
      ford_39.attribute_set?(:doors).should be_false
      ford_39.read_attribute(:doors)
      ford_39.attribute_set?(:doors).should be_true
    end
  end

end
