require 'spec_helper'
require 'gorillib/configurable'

describe Gorillib::Configurable do
  include_context 'included_module'
  
  it 'defines a config() method on the class' do
    subject.should respond_to(:config)
  end
  
  it 'creates a class attribute :settings' do
    subject.should respond_to(:settings)
    subject.receive.should respond_to(:settings)
  end
  
  it 'creates a class attribute :configuration_scope' do
    subject.should respond_to(:configuration_scope)
    subject.receive.should respond_to(:configuration_scope)      
  end
  
  context 'config' do
    let(:test_field)   { :gonads  }
    let(:test_default) { 'strife' }
    let(:test_type)    { String   }
    
    before(:each) { subject.config(test_field, test_type, :default => test_default) }
    
    # it 'defines a field on settings with optional defaults' do
    #   subject.settings.send(test_field).should == test_default
    # end
    
    it 'defines a receiver for the given field' do
      subject.receive.send(test_field).should == test_default
    end
    
  end
  
  context 'receive' do
    
    it 'resolves configuration in order' do
      subject.settings.should_receive(:load_configuration_in_order!).and_return({})
      subject.receive
    end
    
    before do
      subject.class_eval do
        config :yo_momma, String, :default => 'is so ugly'
        config :she,      String
      end
      subject.stub(:settings).and_return(test_settings) 
    end
    
    let(:creation_attrs) { { yo_momma: 'is so fat',  she: 'eats wheat THICKS'       } }    
    let(:configuration)  { { yo_momma: 'is so dumb', she: 'got hit by a parked car' } }
    let(:test_settings)  { double :settings, :load_configuration_in_order! => configuration }
    
    it 'overrides attributes with configuration settings' do
      subject.receive(creation_attrs).attributes.should include(creation_attrs.merge(configuration))
    end
  end
end

