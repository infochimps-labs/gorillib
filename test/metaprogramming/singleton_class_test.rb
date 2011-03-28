require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/metaprogramming/singleton_class'

class KernelTest < Test::Unit::TestCase
  def test_singleton_class
    o = Object.new
    assert_equal class << o; self end, o.singleton_class
  end
end
