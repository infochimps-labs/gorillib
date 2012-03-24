require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/numeric/clamp'

describe Numeric, :simple_spec => true do
  describe '#clamp' do
    it 'should return self if neither min nor max are given' do
      5.clamp().should == 5
    end

    it 'should return min if x < min' do
      5.clamp(6).should == 6
    end

    it 'should return self if x >= min' do
      5.clamp(4).should   == 5
      5.clamp(5).should   == 5
      5.clamp(nil).should == 5
    end

    it 'should return max if x > max' do
      5.clamp(nil, 4).should == 4
      5.clamp(4,   4).should == 4
    end

    it 'should return self if x <= max' do
      5.clamp(4, 6).should   == 5
      5.clamp(5, 5).should   == 5
      5.clamp(nil, 6).should == 5
      5.clamp(nil, 5).should == 5
    end

    it 'lets me mix floats and ints' do
      (5.0).clamp(4, 6).should   == 5.0
      (5).clamp(4.0, 6.0).should == 5.0
      (5.0).clamp(6.0, 7.0).should == 6.0
      (5.0).clamp(4, 6).should be_a_kind_of(Float)
      (5.0).clamp(6, 6).should be_a_kind_of(Integer)
    end

    it 'should raise if min > max' do
      lambda{ 5.clamp(6, 3) }.should raise_error(ArgumentError)
    end

    it 'lets me set min == max' do
      5.clamp(6, 6).should == 6
    end
  end
end
