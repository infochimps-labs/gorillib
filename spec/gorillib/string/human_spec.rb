require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require File.expand_path('inflector_test_cases', File.dirname(__FILE__))
require 'gorillib/string/human'

include InflectorTestCases

describe String, :string_spec => true do

  describe '#titleize' do
    MixtureToTitleCase.each do |raw, titleized|
      it raw do
        raw.titleize.should == titleized
      end
    end
  end

  describe '#humanize' do
    UnderscoreToHuman.each do |raw, humanized|
      it raw do
        raw.humanize.should == humanized
      end
    end
  end

  describe '#to_sentence' do

    it 'converts plain array to sentence' do
      [].to_sentence.should                      == ""
      ['one'].to_sentence.should                 == "one"
      ['one', 'two'].to_sentence.should          == "one and two"
      ['one', 'two', 'three'].to_sentence.should == "one, two, and three"
    end

    it 'converts sentences with a word connector' do
      ['one', 'two', 'three'].to_sentence(:words_connector => ' ')   .should == "one two, and three"
      ['one', 'two', 'three'].to_sentence(:words_connector => ' & ') .should == "one & two, and three"
      ['one', 'two', 'three'].to_sentence(:words_connector => nil)   .should == "onetwo, and three"
    end

    it 'converts sentences with a last word connector' do
      ['one', 'two', 'three'].to_sentence(:last_word_connector => ', and also ') .should == "one, two, and also three"
      ['one', 'two', 'three'].to_sentence(:last_word_connector => nil)           .should == "one, twothree"
      ['one', 'two', 'three'].to_sentence(:last_word_connector => ' ')           .should == "one, two three"
      ['one', 'two', 'three'].to_sentence(:last_word_connector => ' and ')       .should == "one, two and three"
    end

    it 'converts two elements' do
      ['one', 'two'].to_sentence.should == "one and two"
      ['one', 'two'].to_sentence(:two_words_connector => ' ').should == "one two"
    end

    it 'converts one element' do
      ['one'].to_sentence.should == "one"
    end

    it 'converting one element makes new object' do
      elements = ["one"]
      elements.to_sentence.object_id.should_not == elements[0].object_id
      elements.to_sentence.should_not equal(elements[0])
    end

    it 'converts a non-string element' do
      [1].to_sentence.should == '1'
    end
  end
end
