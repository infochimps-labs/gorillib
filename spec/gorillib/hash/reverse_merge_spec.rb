require File.expand_path('../../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/reverse_merge'

describe Hash, :hashlike_spec => true do
  describe 'reverse_merge' do

    before do
      @defaults = { :a => "x", :b => "y", :c => 10 }.freeze
      @options  = { :a => 1, :b => 2 }
      @expected = { :a => 1, :b => 2, :c => 10 }
    end

    it 'Should merge defaults into options, creating a new hash' do
      @options.reverse_merge(@defaults).should == @expected
      @options.should_not == @expected
    end


    it 'Should merge! defaults into options, replacing options.' do
      @merged = @options.dup
      @merged.reverse_merge!(@defaults).should == @expected
      @merged.should == @expected
    end
  end
end
