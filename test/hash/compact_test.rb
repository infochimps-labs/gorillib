require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/hash/compact'

class HashCompactTests < Test::Unit::TestCase

  def test_compact_blank_with_empty
    [ { 1 => nil}, { 1 => nil, 2 => false, 3 => {}, 4 => ""} ].each do |hsh|
      assert_equal({}, hsh.compact_blank)
      assert_not_equal(0,  hsh.length)
    end
  end

  def test_compact_blank_with_empty
    [ { 1 => nil}, { 1 => nil, 2 => false, 3 => {}, 4 => ""} ].each do |hsh|
      assert_equal({}, hsh.compact_blank!)
      assert_equal(0,  hsh.length)
    end
  end

  def test_compact_blank_with_full
    assert_equal(
      { nil => 2 },
      { 1 => nil, nil => 2 }.compact_blank  )
    assert_equal(
      { 2 => :val_2, 4 => :val_4 },
      { 1 => nil, 2 => :val_2, 3 => {}, 4 => :val_4}.compact_blank  )
  end

  def test_compact_blank_bang_with_full
    assert_equal(
      { nil => 2 },
      { 1 => nil, nil => 2 }.compact_blank!  )
    assert_equal(
      { 2 => :val_2, 4 => :val_4 },
      { 1 => nil, 2 => :val_2, 3 => {}, 4 => :val_4}.compact_blank!  )
  end

end
