require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/hash/slice'

describe Hash do
  describe '#slice' do
    it 'should return a new hash with only the given keys' do
      original = { :a => 'x', :b => 'y', :c => 10 }
      expected = { :a => 'x', :b => 'y' }

      original.slice(:a, :b).should == expected
      original.should_not == expected
    end

    it 'Should replace the hash with only the given keys' do
      original = { :a => 'x', :b => 'y', :c => 10 }
      expected = { :c => 10 }

      original.slice!(:a, :b).should == expected
    end

    it 'should return a new hash with only the given keys when given an array key' do
      original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
      expected = { [:a, :b] => "an array key", :c => 10 }

      original.slice([:a, :b], :c).should == expected
      original.should_not == expected
    end

    it 'should replace the hash with only the given keys when given an array key' do
      original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
      expected = { :a => 'x', :b => 'y' }

      original.slice!([:a, :b], :c).should == expected
    end

    it 'Should grab each of the splatted keys' do
      original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
      expected = { :a => 'x', :b => "y" }

      original.slice(*[:a, :b]).should == expected
    end
  end
end
