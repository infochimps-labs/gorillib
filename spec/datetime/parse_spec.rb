require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/datetime/flat'
require 'gorillib/datetime/parse'

describe DateTime do
  describe '#parse_safely' do
    before do
      @time_utc  = Time.parse("2011-02-03T04:05:06 UTC")
      @time_cst  = Time.parse("2011-02-02T22:05:06-06:00")
      @time_flat    = "20110203040506"
      @time_iso_utc = "2011-02-03T04:05:06+00:00"
      @time_iso_cst = "2011-02-02T22:05:06-06:00"
    end

    it 'with a Time, passes it through.' do
      Time.parse_safely(@time_utc).should == @time_utc
      Time.parse_safely(@time_cst).should == @time_cst
    end

    it 'with a Time, converts to UTC.' do
      Time.parse_safely(@time_utc).utc_offset.should == 0
      Time.parse_safely(@time_cst).utc_offset.should == 0
    end

    it 'with a flat time, converts to UTC Time instance' do
      Time.parse_safely(@time_flat).should == @time_utc
      Time.parse_safely(@time_flat).utc_offset.should == 0
    end

    it 'with a flat time and Z, converts to UTC Time instance' do
      Time.parse_safely(@time_flat+'Z').should == @time_utc
      Time.parse_safely(@time_flat+'Z').utc_offset.should == 0
    end

    it 'parses a regular time string, converting to UTC' do
      Time.parse_safely(@time_iso_utc).should == @time_utc
      Time.parse_safely(@time_iso_utc).utc_offset.should == 0
      Time.parse_safely(@time_iso_cst).should == @time_utc
      Time.parse_safely(@time_iso_cst).utc_offset.should == 0
    end

    it 'round-trips' do
      Time.parse_safely(@time_flat).to_flat.should == @time_flat
      Time.parse_safely(@time_utc.to_flat).should  == @time_utc
    end

  end
end
