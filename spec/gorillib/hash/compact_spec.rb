require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/compact'

describe Hash, :hashlike_spec => true do
  describe '#compact' do
    it 'scrubs nil' do
      hsh = { 1 => nil }
      hsh.compact.should == {}
      hsh.length.should == 1
    end

    it 'does not scrub false, {} or ""' do
      hsh       = { 1 => nil, 2 => false, 3 => {}, 4 => "" }
      hsh.compact.should == { 2 => false, 3 => {}, 4 => "" }
      hsh.length.should == 4
    end

    it 'with values' do
      { 1 => nil, nil => 2 }.compact.should == { nil => 2 }
      { 1 => nil, 2 => :val_2, 3 => {}, 4 => :val_4}.compact.should == { 2 => :val_2, 3 => {}, 4 => :val_4 }
    end
  end

  describe '#compact!' do
    it 'scrubs nil' do
      hsh = { 1 => nil }
      hsh.compact!.should == {}
      hsh.length.should == 0
    end

    it 'does not scrub false, {} or ""' do
      hsh        = { 1 => nil, 2 => false, 3 => {}, 4 => "" }
      hsh.compact!.should == { 2 => false, 3 => {}, 4 => "" }
      hsh.length.should == 3
    end

    it 'with values' do
      { 1 => nil, nil => 2 }.compact!.should == { nil => 2 }
      { 1 => nil, 2 => :val_2, 3 => {}, 4 => :val_4}.compact!.should == { 2 => :val_2, 3 => {}, 4 => :val_4 }
    end
  end

  describe '#compact_blank' do
    it 'when empty' do
      [ { 1 => nil}, { 1 => nil, 2 => false, 3 => {}, 4 => ""} ].each do |hsh|
        hsh.compact_blank.should == {}
        hsh.length.should_not == 0
      end
    end

    it 'with values' do
      { 1 => nil, nil => 2 }.compact_blank.should == { nil => 2 }
      { 1 => nil, 2 => :val_2, 3 => {}, 4 => :val_4}.compact_blank.should == { 2 => :val_2, 4 => :val_4 }
    end
  end

  describe '#compact_blank!' do
    it 'when empty' do
      [ { 1 => nil}, { 1 => nil, 2 => false, 3 => {}, 4 => ""} ].each do |hsh|
        hsh.compact_blank!.should == {}
        hsh.length.should == 0
      end
    end

    it 'with values' do
        { 1 => nil, nil => 2 }.compact_blank!.should == { nil => 2 }
        { 1 => nil, 2 => :val_2, 3 => {}, 4 => :val_4}.compact_blank!.should == { 2 => :val_2, 4 => :val_4 }
    end
  end
end
