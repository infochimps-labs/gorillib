require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/hash/keys'

class HashSymbolizeKeysTest < Test::Unit::TestCase

  class IndifferentHash < HashWithIndifferentAccess
  end

  class SubclassingArray < Array
  end

  class SubclassingHash < Hash
  end


  def setup
    @strings = { 'a' => 1, 'b' => 2 }
    @symbols = { :a  => 1, :b  => 2 }
    @mixed   = { :a  => 1, 'b' => 2 }
    @fixnums = {  0  => 1,  1  => 2 }
    if RUBY_VERSION < '1.9.0'
      @illegal_symbols = { "\0" => 1, "" => 2, [] => 3 }
    else
      @illegal_symbols = { [] => 3 }
    end
  end

  def test_methods
    h = {}
    assert_respond_to h, :symbolize_keys
    assert_respond_to h, :symbolize_keys!
    assert_respond_to h, :stringify_keys
    assert_respond_to h, :stringify_keys!
  end

  def test_symbolize_keys
    assert_equal @symbols, @symbols.symbolize_keys
    assert_equal @symbols, @strings.symbolize_keys
    assert_equal @symbols, @mixed.symbolize_keys
  end

  def test_symbolize_keys!
    assert_equal @symbols, @symbols.dup.symbolize_keys!
    assert_equal @symbols, @strings.dup.symbolize_keys!
    assert_equal @symbols, @mixed.dup.symbolize_keys!
  end

  def test_symbolize_keys_preserves_keys_that_cant_be_symbolized
    assert_equal @illegal_symbols, @illegal_symbols.symbolize_keys
    assert_equal @illegal_symbols, @illegal_symbols.dup.symbolize_keys!
  end

  def test_symbolize_keys_preserves_fixnum_keys
    assert_equal @fixnums, @fixnums.symbolize_keys
    assert_equal @fixnums, @fixnums.dup.symbolize_keys!
  end

  def test_stringify_keys
    assert_equal @strings, @symbols.stringify_keys
    assert_equal @strings, @strings.stringify_keys
    assert_equal @strings, @mixed.stringify_keys
  end

  def test_stringify_keys!
    assert_equal @strings, @symbols.dup.stringify_keys!
    assert_equal @strings, @strings.dup.stringify_keys!
    assert_equal @strings, @mixed.dup.stringify_keys!
  end

  def test_symbolize_keys_for_hash_with_indifferent_access
    assert_instance_of Hash, @symbols.with_indifferent_access.symbolize_keys
    assert_equal @symbols, @symbols.with_indifferent_access.symbolize_keys
    assert_equal @symbols, @strings.with_indifferent_access.symbolize_keys
    assert_equal @symbols, @mixed.with_indifferent_access.symbolize_keys
  end

  def test_symbolize_keys_bang_for_hash_with_indifferent_access
    assert_raise(NoMethodError) { @symbols.with_indifferent_access.dup.symbolize_keys! }
    assert_raise(NoMethodError) { @strings.with_indifferent_access.dup.symbolize_keys! }
    assert_raise(NoMethodError) { @mixed.with_indifferent_access.dup.symbolize_keys! }
  end

  def test_symbolize_keys_preserves_keys_that_cant_be_symbolized_for_hash_with_indifferent_access
    assert_equal @illegal_symbols, @illegal_symbols.with_indifferent_access.symbolize_keys
    assert_raise(NoMethodError) { @illegal_symbols.with_indifferent_access.dup.symbolize_keys! }
  end

  def test_symbolize_keys_preserves_fixnum_keys_for_hash_with_indifferent_access
    assert_equal @fixnums, @fixnums.with_indifferent_access.symbolize_keys
    assert_raise(NoMethodError) { @fixnums.with_indifferent_access.dup.symbolize_keys! }
  end

  def test_hash_subclass
    flash = { "foo" => SubclassingHash.new.tap { |h| h["bar"] = "baz" } }.with_indifferent_access
    assert_kind_of SubclassingHash, flash["foo"]
  end

  def test_assert_valid_keys
    assert_nothing_raised do
      { :failure => "stuff", :funny => "business" }.assert_valid_keys([ :failure, :funny ])
      { :failure => "stuff", :funny => "business" }.assert_valid_keys(:failure, :funny)
    end

    assert_raise(ArgumentError, "Unknown key: failore") do
      { :failore => "stuff", :funny => "business" }.assert_valid_keys([ :failure, :funny ])
      { :failore => "stuff", :funny => "business" }.assert_valid_keys(:failure, :funny)
    end
  end

end
