require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/array/extract_options'

class HashSubclass < Hash
end

class ExtractableHashSubclass < Hash
  def extractable_options?
    true
  end
end

describe Array, :simple_spec => true do
  describe '#extract_options!' do
    it 'pulls empty hash from empty array' do
      [].extract_options!.should == {}
    end
    it 'pulls empty hash from array with no hash' do
      [1].extract_options!.should == {}
    end
    it 'pulls hash from array with only that hash' do
      [{:a=>:b}].extract_options!.should    == {:a=>:b}
    end
    it 'pulls hash from end of array' do
      [1, {:a=>:b}].extract_options!.should == {:a=>:b}
    end

    it 'does not extract hash subclasses' do
      hash = HashSubclass.new
      hash[:foo] = 1
      array = [hash]
      options = array.extract_options!
      options.should == {}
      array.should   == [hash]
    end

    it 'does extract extractable subclass' do
      hash = ExtractableHashSubclass.new
      hash[:foo] = 1
      array = [hash]
      options = array.extract_options!
      options.should == {:foo => 1}
      array.should   == []
    end

  end
end
