require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/deep_merge'

describe Hash do
  describe '#deep_merge' do
    before do
      @hash_1 =
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, replacing values on the left' do
      @hash_1.deep_merge(
        { :a => 1,            :c => { :val => 2,                                             } }).should ==
        { :a => 1, :b => "b", :c => { :val => 2,     :arr => ['hi'], :hsh => { :d1 => "d1" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, merging hashes where they meet' do
      @hash_1.deep_merge(
        { :a => 1,            :c => { :val => 2,                     :hsh => {              :d2 => "d2" } } }).should ==
        { :a => 1, :b => "b", :c => { :val => 2,     :arr => ['hi'], :hsh => { :d1 => "d1", :d2 => "d2" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, replacing hash on left with value on right' do
      @hash_1.deep_merge(
        { :a => 1,            :c => {                                :hsh => :val } }).should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => :val } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, replacing val on left with hash on right' do
      @hash_1.deep_merge(
        { :a => 1,            :c => { :val => {},                                            } }).should ==
        { :a => 1, :b => "b", :c => { :val => {},    :arr => ['hi'], :hsh => { :d1 => "d1" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, replacing array on left with array on right without merging' do
      @hash_1.deep_merge(
        { :a => 1,            :c => {                :arr => ['whatevs']                          } }).should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['whatevs'], :hsh => { :d1 => "d1" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end
  end

  describe '#deep_merge!' do
    before do
      @hash_1 = {
          :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, replacing values on the left' do
      @hash_1.deep_merge!(
        { :a => 1,            :c => { :val => 2,                                             } }).should ==
        { :a => 1, :b => "b", :c => { :val => 2,     :arr => ['hi'], :hsh => { :d1 => "d1" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => 2,     :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, merging hashes where they meet' do
      @hash_1.deep_merge!(
        { :a => 1,            :c => { :val => 2,                     :hsh => {              :d2 => "d2" } } }).should ==
        { :a => 1, :b => "b", :c => { :val => 2,     :arr => ['hi'], :hsh => { :d1 => "d1", :d2 => "d2" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => 2,     :arr => ['hi'], :hsh => { :d1 => "d1", :d2 => "d2" } } }
    end

    it 'merges, replacing hash on left with value on right' do
      @hash_1.deep_merge!(
        { :a => 1,            :c => {                                :hsh => :val } }).should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => :val } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['hi'], :hsh => :val } }
    end

    it 'merges, replacing val on left with hash on right' do
      @hash_1.deep_merge!(
        { :a => 1,            :c => { :val => {},                                            } }).should ==
        { :a => 1, :b => "b", :c => { :val => {},    :arr => ['hi'], :hsh => { :d1 => "d1" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => {},    :arr => ['hi'], :hsh => { :d1 => "d1" } } }
    end

    it 'merges, replacing array on left with array on right without merging' do
      @hash_1.deep_merge!(
        { :a => 1,            :c => {                :arr => ['whatevs']                          } }).should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['whatevs'], :hsh => { :d1 => "d1" } } }
      @hash_1.should ==
        { :a => 1, :b => "b", :c => { :val => "val", :arr => ['whatevs'], :hsh => { :d1 => "d1" } } }
    end
  end

  describe '#deep_dup' do
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
end
