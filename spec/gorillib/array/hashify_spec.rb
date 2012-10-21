require 'spec_helper'
require 'gorillib/array/hashify'

describe Array, :simple_spec, :only do

  describe '#hashify' do
    it 'returns a hash pairing elements with value from block' do
      [1,2,3].hashify{|x| x * x }.should == { 1 => 1, 2 => 4, 3 => 9 }
      [1,2,3].hashify{|x| x > 2 ? nil : x }.should == { 1 => 1, 2 => 2, 3 => nil }
    end
    it "returns an empty hash on an empty array" do
      [].hashify{}.should == {}
    end
    it "fails if no block given" do
      expect{ [1,2,3].hashify }.to raise_error(ArgumentError)
    end

  end

end
