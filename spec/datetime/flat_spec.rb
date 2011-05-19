require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/datetime/flat'
require 'gorillib/datetime/parse'

describe Time do
  describe '#to_flat' do
    before do
      @time_utc  = Time.new(2011, 2, 3,  4, 5, 6, 0)
      @time_cst  = Time.new(2011, 2, 3, 10, 5, 6, '+06:00')
      @time_flat = "20110203040506"
    end

    it 'converts times to UTC' do
      @time_utc.to_flat.should == @time_flat
      @time_cst.to_flat.should == @time_flat
    end

    it 'round-trips' do
      Time.parse_safely(@time_flat).to_flat.should == @time_flat
      Time.parse_safely(@time_utc.to_flat).should  == @time_utc
    end

  end
end

describe DateTime do
  describe '#to_flat' do
    before do
      @date_time_utc  = DateTime.new(2011, 2, 3,  4, 5, 6, 0)
      @date_time_cst  = DateTime.new(2011, 2, 3, 10, 5, 6, '+06:00')
      @date_time_flat = "20110203040506"
    end

    it 'converts times to UTC' do
      @date_time_utc.to_flat.should == @date_time_flat
      @date_time_cst.to_flat.should == @date_time_flat
    end

  end
end

describe Date do
  describe '#to_flat' do
    before do
      @date      = Date.new(2011, 2, 3)
      @date_flat = "20110203"
    end

    it 'converts dates' do
      @date.to_flat.should == @date_flat
    end

  end
end
