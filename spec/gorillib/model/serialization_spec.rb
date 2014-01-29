require 'spec_helper'
require 'support/model_test_helpers'

require 'multi_json'
#
require 'gorillib/model'
require 'gorillib/builder'
require 'gorillib/model/serialization'

describe Gorillib::Model, :model_spec, :builder_spec do
  subject do
    garage.cars << wildcat
    garage.cars << ford_39
    garage
  end
  let :wired_garage_hash do
    { :cars => [
        {:name=>:wildcat, :make_model=>"Buick Wildcat",    :year=>1968, :doors=>2, :engine=>{:volume=>455, :cylinders=>8, :_type => "gorillib.test.engine"}, :_type => "gorillib.test.car"},
        {:name=>:ford_39, :make_model=>"Ford Tudor Sedan", :year=>1939, :doors=>2, :_type => "gorillib.test.car"}, ], :_type => "gorillib.test.garage" }
  end

  describe 'to_json' do
    it 'recursively serializes' do
      MultiJson.load(wildcat.to_json).should == {"name"=>"wildcat","make_model"=>"Buick Wildcat","year"=>1968,"doors"=>2,"engine"=>{"volume"=>455,"cylinders"=>8, "_type"=>"gorillib.test.engine"},"_type"=>"gorillib.test.car"}
    end
    it 'recursively serializes' do
      subject.to_json.should == MultiJson.dump(wired_garage_hash)
    end
  end

  describe 'to_wire' do
    it 'calls to_wire recursively, passing options along' do
      opts = {:dummy=>'options'}
      ford_39.should_receive(:to_wire).with(opts)
      wildcat.engine.should_receive(:to_wire).with(opts)
      subject.to_wire(opts)
    end

    it 'returns a nested hash' do
      subject.to_wire.should == wired_garage_hash
    end
    it 'aliases method as_json' do
      subject.as_json.should == wired_garage_hash
    end
  end
end
