require File.dirname(__FILE__)+'/../abstract_unit'
require 'gorillib/string/inflections'
require File.dirname(__FILE__)+'/inflector_test_cases'

class InflectorTest < Test::Unit::TestCase
  include InflectorTestCases

  def test_camelize
    CamelToUnderscore.each do |cameled, underscored|
      assert_equal(cameled, underscored.camelize)
    end
  end

  def test_camelize_with_lower_downcases_the_first_letter
    assert_equal('capital', 'Capital'.camelize(:lower))
  end

  def test_snakeize
    UnderscoreToLowerCamel.each do |underscored, snaked|
      assert_equal(snaked, underscored.snakeize)
    end
  end

  def test_underscore_to_lower_camel
    UnderscoreToLowerCamel.each do |underscored, lower_cameled|
      assert_equal(lower_cameled, underscored.camelize(:lower))
    end
  end

  def test_underscore
    CamelToUnderscore.each do |cameled, underscored|
      assert_equal(underscored, cameled.underscore)
    end
    CamelToUnderscoreWithoutReverse.each do |cameled, underscored|
      assert_equal(underscored, cameled.underscore)
    end
    assert_equal "html_tidy", "HTMLTidy".underscore
    assert_equal "html_tidy_generator", "HTMLTidyGenerator".underscore
  end

  def test_camelize_with_module
    CamelWithModuleToUnderscoreWithSlash.each do |cameled, underscored|
      assert_equal(cameled, underscored.camelize)
    end
  end

  def test_underscore_with_slashes
    CamelWithModuleToUnderscoreWithSlash.each do |cameled, underscored|
      assert_equal(underscored, cameled.underscore)
    end
  end

  def test_demodulize
    assert_equal "Account", "MyApplication::Billing::Account".demodulize
  end

end
