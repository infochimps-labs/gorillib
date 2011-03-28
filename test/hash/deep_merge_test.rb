require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/hash/deep_merge'

class HashDeepMergeTest < Test::Unit::TestCase

  def test_deep_merge
    hash_1 = { :a => "a", :b => "b", :c => { :c1 => "c1", :c2 => "c2", :c3 => { :d1 => "d1" } } }
    hash_2 = { :a => 1, :c => { :c1 => 2, :c3 => { :d2 => "d2" } } }
    expected = { :a => 1, :b => "b", :c => { :c1 => 2, :c2 => "c2", :c3 => { :d1 => "d1", :d2 => "d2" } } }
    assert_equal expected, hash_1.deep_merge(hash_2)

    hash_1.deep_merge!(hash_2)
    assert_equal expected, hash_1
  end

  # def test_deep_dup
  #   hash = { :a => { :b => 'b' } }
  #   dup = hash.deep_dup
  #   dup[:a][:c] = 'c'
  #   assert_equal nil, hash[:a][:c]
  #   assert_equal 'c', dup[:a][:c]
  # end
  #
  # def test_deep_dup_initialize
  #   zero_hash = Hash.new 0
  #   hash = { :a => zero_hash }
  #   dup = hash.deep_dup
  #   assert_equal 0, dup[:a][44]
  # end
end
