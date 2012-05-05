require File.expand_path('../../spec_helper', File.dirname(__FILE__))

require 'gorillib/record/factories'

describe 'a', :record_spec => true do
  let(:inst    ){ mock('any object') }
  let(:example_class){  Class.new }
  let(:example_module){ Module.new }
  let(:example_hash){  { :modacity => 7.3, :embiggen => :cromulent } }
  let(:example_array){ %w[alice bob charlie] }

  let(:many_things){ [ example_class, example_module, TrueClass, NilClass, String, 3, 'a string', :a_symbol, example_hash, example_array, true, false, nil, ->(){ 'a proc' }  ] }

  shared_examples_for :identity_factory_for do |instances|
    it 'returns receivable instances directly' do
      instances ||= [inst]
      Array(instances).each{|thing| described_class.receive(thing).should equal(thing) }
    end
  end

  shared_examples_for :it_raises_factory_mismatch_error do |instances|
    it "on #{instances.join(', ')}" do
      instances ||= [inst]
      Array(instances).each do |thing|
        ->{ described_class.receive(thing) }.should raise_error(Gorillib::Factory::FactoryMismatchError, /already be a/)
      end
    end
  end

  shared_examples_for :it_only_accepts do |ok_things|
    ok_things.each do |ok_thing|
      it "returns a #{ok_thing} directly" do
        described_class.receive(ok_thing).should equal(ok_thing)
      end
    end
    it "does not receive anything else" do
      ok_things = ok_things.nil? ? [] : Array(ok_things)
      (many_things - ok_things).each do |thing|
        ->{ described_class.receive(thing) }.should raise_error(Gorillib::Factory::FactoryMismatchError, /already be a/)
      end
    end
  end

  describe Gorillib::Factory::IdentityFactory do
    it_behaves_like :identity_factory_for
  end
  describe Gorillib::Factory::Whatever do
    it_behaves_like :identity_factory_for
  end

  describe Gorillib::Factory::ClassFactory do
    let(:many_things){ [ example_module, 3, 'a string', :a_symbol, example_hash, example_array, true, false, nil, ->(){ 'a proc' }  ] }
    it_behaves_like :it_only_accepts, [Integer, Float, Class.new]
  end

  describe Gorillib::Factory::ModuleFactory do
    let(:many_things){ [ 3, 'a string', :a_symbol, example_hash, example_array, true, false, nil, ->(){ 'a proc' }  ] }
    it_behaves_like :it_only_accepts, [Integer, Float, Module.new]
  end

  describe(Gorillib::Factory::NilFactory  ){ it_behaves_like :it_only_accepts, [nil]   }
  describe(Gorillib::Factory::TrueFactory ){ it_behaves_like :it_only_accepts, [true]  }
  describe(Gorillib::Factory::FalseFactory){ it_behaves_like :it_only_accepts, [false] }


  describe Gorillib::Factory::StringFactory do
    it 'is' do
      [ 3, 'hi', :bob, nil, "", [], {}, Set.new ].each do |obj|
        p [obj, Gorillib::Factory::StringFactory.receive(obj)]
      end
    end
  end
end
