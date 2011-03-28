require File.dirname(__FILE__)+'/../abstract_unit'
require File.dirname(__FILE__)+'/inflector_test_cases'
require 'gorillib/string/human'

class InflectorTest < Test::Unit::TestCase
  include InflectorTestCases

  def test_titleize
    MixtureToTitleCase.each do |before, titleized|
      assert_equal(titleized, before.titleize)
    end
  end

  MixtureToTitleCase.each do |before, titleized|
    define_method "test_titleize_#{before}" do
      assert_equal(titleized, before.titleize )
    end
  end

  def test_humanize
    UnderscoreToHuman.each do |underscored, human|
      assert_equal(human, underscored.humanize )
    end
  end
end

class ArrayExtToSentenceTests < Test::Unit::TestCase
  def test_plain_array_to_sentence
    assert_equal "", [].to_sentence
    assert_equal "one", ['one'].to_sentence
    assert_equal "one and two", ['one', 'two'].to_sentence
    assert_equal "one, two, and three", ['one', 'two', 'three'].to_sentence
  end

  def test_to_sentence_with_words_connector
    assert_equal "one two, and three", ['one', 'two', 'three'].to_sentence(:words_connector => ' ')
    assert_equal "one & two, and three", ['one', 'two', 'three'].to_sentence(:words_connector => ' & ')
    assert_equal "onetwo, and three", ['one', 'two', 'three'].to_sentence(:words_connector => nil)
  end

  def test_to_sentence_with_last_word_connector
    assert_equal "one, two, and also three", ['one', 'two', 'three'].to_sentence(:last_word_connector => ', and also ')
    assert_equal "one, twothree", ['one', 'two', 'three'].to_sentence(:last_word_connector => nil)
    assert_equal "one, two three", ['one', 'two', 'three'].to_sentence(:last_word_connector => ' ')
    assert_equal "one, two and three", ['one', 'two', 'three'].to_sentence(:last_word_connector => ' and ')
  end

  def test_two_elements
    assert_equal "one and two", ['one', 'two'].to_sentence
    assert_equal "one two", ['one', 'two'].to_sentence(:two_words_connector => ' ')
  end

  def test_one_element
    assert_equal "one", ['one'].to_sentence
  end

  def test_one_element_not_same_object
    elements = ["one"]
    assert_not_equal elements[0].object_id, elements.to_sentence.object_id
  end

  def test_one_non_string_element
    assert_equal '1', [1].to_sentence
  end
end
