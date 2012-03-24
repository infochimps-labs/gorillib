require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/slice'

class HashSubclass < Hash ; end

describe Hash, :hashlike_spec => true do
  describe '#slice' do
    it 'should return a new hash with only the given keys' do
      original = { :a => 'x', :b => 'y', :c => 10 }
      expected = { :a => 'x', :b => 'y' }

      original.slice(:a, :b).should == expected
      original.should == { :a => 'x', :b => 'y', :c => 10 }
    end

    it 'should return a new hash with only the given keys when given an array key' do
      original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
      expected = { [:a, :b] => "an array key", :c => 10 }

      original.slice([:a, :b], :c).should == expected
      original.should_not == expected
    end

    it 'Should grab each of the splatted keys' do
      original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
      expected = { :a => 'x', :b => "y" }

      original.slice(*[:a, :b]).should == expected
    end

    it 'should have the same type as the original' do
      hsh = HashSubclass.new.merge({ :a => 'x', :b => 'y', :c => 10 })
      hsh.slice(:a, :b).should be_a(HashSubclass)
    end
  end

  describe '#slice!' do
    it 'Should replace the hash with only the given keys' do
      original  = { :a => 'x', :b => 'y', :c => 10 }
      expected  = { :c => 10 }
      remaining = { :a => 'x', :b => 'y' }

      original.slice!(:a, :b).should == expected
      original.should == remaining
    end

    it 'should replace the hash with only the given keys when given an array key' do
      original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
      expected = { :a => 'x', :b => 'y' }

      original.slice!([:a, :b], :c).should == expected
    end
  end

  describe '#extract!' do
    it 'Should replace the hash with only the omitted keys' do
      original  = { :a => 'x', :b => 'y', :c => 10 }
      expected  = { :a => 'x', :b => 'y' }
      remaining = { :c => 10 }

      original.extract!(:a, :b).should == expected
      original.should == remaining
    end
  end

end
