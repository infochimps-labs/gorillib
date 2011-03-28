require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/hash/slice'

class HashSliceTest < Test::Unit::TestCase

  def test_slice
    original = { :a => 'x', :b => 'y', :c => 10 }
    expected = { :a => 'x', :b => 'y' }

    # Should return a new hash with only the given keys.
    assert_equal expected, original.slice(:a, :b)
    assert_not_equal expected, original
  end

  def test_slice_inplace
    original = { :a => 'x', :b => 'y', :c => 10 }
    expected = { :c => 10 }

    # Should replace the hash with only the given keys.
    assert_equal expected, original.slice!(:a, :b)
  end

  def test_slice_with_an_array_key
    original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
    expected = { [:a, :b] => "an array key", :c => 10 }

    # Should return a new hash with only the given keys when given an array key.
    assert_equal expected, original.slice([:a, :b], :c)
    assert_not_equal expected, original
  end

  def test_slice_inplace_with_an_array_key
    original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
    expected = { :a => 'x', :b => 'y' }

    # Should replace the hash with only the given keys when given an array key.
    assert_equal expected, original.slice!([:a, :b], :c)
  end

  def test_slice_with_splatted_keys
    original = { :a => 'x', :b => 'y', :c => 10, [:a, :b] => "an array key" }
    expected = { :a => 'x', :b => "y" }

    # Should grab each of the splatted keys.
    assert_equal expected, original.slice(*[:a, :b])
  end
end
