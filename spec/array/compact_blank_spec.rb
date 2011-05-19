require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/array/compact_blank'

describe Array do

  describe '#compact_blank' do
    it 'with empty' do
      [ [nil], [nil, false, {}, ""] ].each do |arr|
        arr.compact_blank.should == []
        arr.length.should_not    == 0
      end
    end

    it 'with full' do
      [ [nil, 1, nil, 2], [nil, 1, false, 2, {}, ""] ].each do |arr|
        arr.compact_blank.should == [1, 2]
      end
    end
  end

  describe '#compact_blank!' do
    it 'with empty' do
      [].compact_blank!.should == []
      [ [nil], [nil, false, {}, ""] ].each do |arr|
        arr.compact_blank!.should == []
        arr.length.should         == 0
      end
    end

    it 'with full' do
      [ [nil, 1, nil, 2], [nil, 1, false, 2, {}, ""] ].each do |arr|
        arr.compact_blank!.should == [1, 2]
      end
    end

  end
end
