require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/array/extract_options'

class ArrayExtractOptionsTests < Test::Unit::TestCase
  class HashSubclass < Hash
  end

  class ExtractableHashSubclass < Hash
    def extractable_options?
      true
    end
  end

  def test_extract_options
    assert_equal({}, [].extract_options!)
    assert_equal({}, [1].extract_options!)
    assert_equal({:a=>:b}, [{:a=>:b}].extract_options!)
    assert_equal({:a=>:b}, [1, {:a=>:b}].extract_options!)
  end

  def test_extract_options_doesnt_extract_hash_subclasses
    hash = HashSubclass.new
    hash[:foo] = 1
    array = [hash]
    options = array.extract_options!
    assert_equal({}, options)
    assert_equal [hash], array
  end

  def test_extract_options_extracts_extractable_subclass
    hash = ExtractableHashSubclass.new
    hash[:foo] = 1
    array = [hash]
    options = array.extract_options!
    assert_equal({:foo => 1}, options)
    assert_equal [], array
  end

end
