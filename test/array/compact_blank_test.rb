require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/array/compact_blank'

class ArrayCompactBlankTests < Test::Unit::TestCase

  def test_compact_blank_with_empty
    [ [nil], [nil, false, {}, ""] ].each do |arr|
      assert_equal([], arr.compact_blank)
      assert_not_equal(0,  arr.length)
    end
  end

  def test_compact_blank_bang_with_empty
    assert_equal([], [].compact_blank!)
    #
    [ [nil], [nil, false, {}, ""] ].each do |arr|
      assert_equal([], arr.compact_blank!)
      assert_equal(0,  arr.length)
    end
  end

  def test_compact_blank_with_full
    [ [nil, 1, nil, 2], [nil, 1, false, 2, {}, ""] ].each do |arr|
      assert_equal([1, 2], arr.compact_blank)
    end
  end

  def test_compact_blank_bang_with_full
    [ [nil, 1, nil, 2], [nil, 1, false, 2, {}, ""] ].each do |arr|
      assert_equal([1, 2], arr.compact_blank!)
    end
  end
end
