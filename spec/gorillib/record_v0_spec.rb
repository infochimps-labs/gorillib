require File.expand_path('../../spec_helper', File.dirname(__FILE__))
#
require 'gorillib/metaprogramming/concern'
require 'gorillib/metaprogramming/remove_method'
require "gorillib/object/try_dup"
#
require 'gorillib/record/errors'
require 'gorillib/record/field'
require 'gorillib/record/named_type'
require 'gorillib/record/record_type'
#
require 'record_test_helpers'

require 'pry'

describe Gorillib::Record, :record_spec => true do
  context '.field' do
  end

  context '.fields' do
    it 'has no fields by default' do
      poppa_smurf.fields.should == {}
    end

    it 'inherits parent fields' do
      poppa_smurf.field :height, Integer
      smurfette.field   :pulchritude, Float
      poppa_smurf.fields.keys.should == [ :height ]
      smurfette.fields.keys.should   == [ :height, :pulchritude ]
    end

    it 'raises an error if a field is redefined' do
      poppa_smurf.field :height, Integer
      poppa_smurf.send(:define_method, :boogie){ 'na na na' }
      ->{ smurfette.field   :height, Float }.should raise_error(::Gorillib::Record::DangerousFieldError, /A field named 'height'.*conflict/)
      ->{ smurfette.field   :boogie, Float }.should raise_error(::Gorillib::Record::DangerousFieldError, /A field named 'boogie'.*conflict/)
    end
  end

end

describe Meta::Schema::NamedSchema, :record_spec => true do

  context '.metamodel' do
    it 'defines a new module named Meta::[KlassName]Type' do
      defined?(::Meta::Gorillib::Scratch::PoppaSmurfType).should be_false
      poppa_smurf.metamodel.should == ::Meta::Gorillib::Scratch::PoppaSmurfType
    end
    it 'includes metamodule in host class' do
      poppa_smurf.metamodel
      poppa_smurf.should            < ::Meta::Gorillib::Scratch::PoppaSmurfType
    end
  end

  context '#define_metamodel_method' do
    before{ Meta::Schema::NamedSchema.send(:public, :define_metamodel_method) }

    it 'adds method to metamodel' do
      poppa_smurf.define_metamodel_method(:smurf){ 'smurfy!' }
      poppa_smurf.public_instance_methods.should include(:smurf)
      poppa_smurf.metamodel.public_instance_methods.should include(:smurf)
      poppa_smurf.new.smurf.should == 'smurfy!'
    end

    context 'visibility' do
      it 'raises an error if an illegal visibility is given' do
        poppa_smurf.define_metamodel_method(:smurf, :public){ 'public' }
        poppa_smurf.public_instance_methods.should include(:smurf)
      end
      it 'raises an error if an illegal visibility is given' do
        poppa_smurf.define_metamodel_method(:smurf, :private){ 'private' }
        poppa_smurf.private_instance_methods.should include(:smurf)
      end
      it 'raises an error if an illegal visibility is given' do
        poppa_smurf.define_metamodel_method(:smurf, :protected){ 'protected' }
        poppa_smurf.protected_instance_methods.should include(:smurf)
      end
      it 'raises an error if an illegal visibility is given' do
        ->{ poppa_smurf.define_metamodel_method(:smurf, :smurfily){ } }.should raise_error(ArgumentError, /^Visibility must be.*'smurfily'/)
      end
    end
  end
end
