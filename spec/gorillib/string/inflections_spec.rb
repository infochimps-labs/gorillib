require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require File.expand_path('inflector_test_cases', File.dirname(__FILE__))
require 'gorillib/string/inflections'

include InflectorTestCases

describe String, :string_spec => true do

  describe 'camelize' do
    CamelToUnderscore.each do |cameled, underscored|
      it underscored do
        underscored.camelize.should == cameled
      end
    end

    it 'with lower, downcases the first letter' do
      'Capital'.camelize(:lower).should == 'capital'
    end

    UnderscoreToLowerCamel.each do |underscored, lower_cameled|
      it lower_cameled do
        underscored.camelize(:lower).should == lower_cameled
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |cameled, underscored|
      it underscored do
        underscored.camelize.should == cameled
      end
    end
  end

  describe '#snakeize' do
    UnderscoreToLowerCamel.each do |underscored, snaked|
      it underscored do
        underscored.snakeize.should == snaked
      end
    end
  end

  describe '#underscore' do
    CamelToUnderscore.each do |cameled, underscored|
      it cameled do
        cameled.underscore.should == underscored
      end
    end

    CamelToUnderscoreWithoutReverse.each do |cameled, underscored|
      it underscored do
        cameled.underscore.should == underscored
      end
    end

    CamelWithModuleToUnderscoreWithSlash.each do |cameled, underscored|
      it underscored do
        cameled.underscore.should == underscored
      end
    end

    it "HTMLTidy" do
      "HTMLTidy".underscore.should == "html_tidy"
    end

    it "HTMLTidyGenerator" do
      "HTMLTidyGenerator".underscore.should == "html_tidy_generator"
    end
  end

  describe '#demodulize' do
    it 'strips module part' do
      "MyApplication::Billing::Account".demodulize.should == "Account"
    end
  end

end
