require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/keys'

describe Hash do
  class SubclassingArray < Array
  end

  class SubclassingHash < Hash
  end

  before do
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

  it 'responds to #symbolize_keys, #symbolize_keys!, #stringify_keys, #stringify_keys!' do
    {}.should respond_to(:symbolize_keys )
    {}.should respond_to(:symbolize_keys!)
    {}.should respond_to(:stringify_keys )
    {}.should respond_to(:stringify_keys!)
  end

  describe '#symbolize_keys' do
    it 'converts keys that are all symbols' do
      @symbols.symbolize_keys.should == @symbols
    end

    it 'converts keys that are all strings' do
      @strings.symbolize_keys.should == @symbols
      @strings['a'].should == 1
    end

    it 'converts keys that are mixed' do
      @mixed.symbolize_keys.should == @symbols
      @mixed['b'].should == 2
    end
  end

  describe '#symbolize_keys!' do
    it 'converts keys that are all symbols' do
      @symbols.symbolize_keys!.should == @symbols
    end

    it 'converts keys that are all strings' do
      @strings.symbolize_keys!.should == @symbols
      @strings[:a].should == 1
    end

    it 'converts keys that are mixed' do
      @mixed.symbolize_keys!.should == @symbols
      @mixed[:b].should == 2
    end

    it 'preserves keys that can not be symbolized' do
      @illegal_symbols.symbolize_keys.should == @illegal_symbols
      @illegal_symbols.dup.symbolize_keys!.should == @illegal_symbols
    end

    it 'preserves fixnum keys' do
      @fixnums.symbolize_keys.should == @fixnums
      @fixnums.dup.symbolize_keys!.should == @fixnums
    end
  end

  describe '#stringify_keys' do
    it 'converts keys that are all symbols' do
      @symbols.stringify_keys.should == @strings
    end

    it 'converts keys that are all strings' do
      @strings.stringify_keys.should == @strings
    end

    it 'converts keys that are mixed' do
      @mixed.stringify_keys.should == @strings
    end
  end

  describe '#stringify_keys!' do
    it 'converts keys that are all symbols' do
      @symbols.dup.stringify_keys!.should == @strings
    end

    it 'converts keys that are all strings' do
      @strings.dup.stringify_keys!.should == @strings
    end

    it 'converts keys that are all mixed' do
      @mixed.dup.stringify_keys!.should == @strings
    end
  end

  describe '#assert_valid_keys' do
    it 'succeeds when valid' do
      { :failure => "stuff", :funny => "business" }.assert_valid_keys([ :failure, :funny ]).should be_nil
      { :failure => "stuff", :funny => "business" }.assert_valid_keys(:failure, :funny).should be_nil
    end
    it 'raises when there are invalid keys' do
      lambda{ { :failore => "stuff", :funny => "business" }.assert_valid_keys([ :failure, :funny ]) }.should raise_error(ArgumentError, "Unknown key(s): failore")
      lambda{ { :failore => "stuff", :funny => "business" }.assert_valid_keys(:failure, :funny)     }.should raise_error(ArgumentError, "Unknown key(s): failore")
    end
  end

end
