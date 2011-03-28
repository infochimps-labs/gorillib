require File.dirname(__FILE__)+'/../abstract_unit'
require File.dirname(__FILE__)+'/inflector_test_cases'
require 'gorillib/string/constantize'

module Ace
  module Base
    class Case
    end
  end
end


class InflectorTest < Test::Unit::TestCase
  include InflectorTestCases

  def test_constantize
    assert_nothing_raised{ assert_equal Ace::Base::Case, "Ace::Base::Case".constantize }
    assert_nothing_raised{ assert_equal Ace::Base::Case, "::Ace::Base::Case".constantize }
    assert_nothing_raised{ assert_equal InflectorTest,   "InflectorTest".constantize }
    assert_nothing_raised{ assert_equal InflectorTest,   "::InflectorTest".constantize }
    assert_raise(NameError){ "UnknownClass"     .constantize }
    assert_raise(NameError){ "An invalid string".constantize }
    assert_raise(NameError){ "InvalidClass\n"   .constantize }
  end

  def test_constantize_does_lexical_lookup
    assert_raise(NameError) { "Ace::Base::InflectorTest".constantize }
  end

end
