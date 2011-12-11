require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/zip'

describe Hash do
  describe '#zip' do
    it 'builds a hash from keys and values' do
      Hash.zip([:a, :b, :c], [1, 2, 3]).should == { :a => 1, :b => 2, :c => 3 }
    end

    it 'ignores extra values' do
      Hash.zip([:a, :b, :c], [1, 2, 3, 4, 5]).should == { :a => 1, :b => 2, :c => 3 }
    end

    it 'supplies nil values for extra keys' do
      Hash.zip([:a, :b, :c, :d], [1, 2, 3]).should == { :a => 1, :b => 2, :c => 3, :d => nil }
    end

    it 'uses the default block if given' do
      hsh = Hash.zip([:a, :b, :c], [1, 2, 3]){|h,k| h[k] = :foo }
      hsh.should == { :a => 1, :b => 2, :c => 3 }
      hsh[:d].should == :foo
    end

    it 'uses the default value if given' do
      hsh = Hash.zip([:a, :b, :c], [1, 2, 3], :bar)
      hsh.should == { :a => 1, :b => 2, :c => 3 }
      hsh[:d].should == :bar
    end

  end
end
