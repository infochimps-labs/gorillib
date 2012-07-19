require 'spec_helper'
require 'gorillib/model'
require 'gorillib/model/lint'

describe Gorillib::Model::Lint, :model_spec => true do
  subject do
    klass = Class.new{ include Gorillib::Model ; include Gorillib::Model::Lint ; field :bob, Integer }
    klass.new
  end

  context '#read_attribute' do
    it "raises an error if the field does not exist" do
      ->{ subject.read_attribute(:fnord) }.should raise_error(Gorillib::Model::UnknownFieldError, /unknown field: fnord/)
    end
  end

  context '#write_attribute' do
    it "raises an error if the field does not exist" do
      ->{ subject.write_attribute(:fnord, 8) }.should raise_error(Gorillib::Model::UnknownFieldError, /unknown field: fnord/)
    end
  end

  context '#attribute_set?' do
    it "raises an error if the field does not exist" do
      ->{ subject.attribute_set?(:fnord) }.should raise_error(Gorillib::Model::UnknownFieldError, /unknown field: fnord/)
    end
  end
end
