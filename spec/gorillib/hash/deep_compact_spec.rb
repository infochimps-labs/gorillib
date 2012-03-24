require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/hash/deep_compact'
require 'gorillib/array/deep_compact'

describe Hash do
  describe 'array/deep_compact and hash/deep_compact' do
    it "should respond to the method deep_compact!" do
      { }.should respond_to :deep_compact!
    end

    it "should return nil if all values evaluate as blank" do
      { :a => nil, :b => "", :c => [], :d => {} }.deep_compact!.should == {}
    end

    it "should return a hash with all blank values removed recursively" do
      @test_hash = {:e=>["", nil, [], {}, "foo", { :a=> [nil, {}, { :c=> ["","",[]] } ], :b => nil }]}
      @test_hash.deep_compact!.should == {:e=>["foo"]}
    end
  end
end

describe Array do
  describe 'array/deep_compact and hash/deep_compact' do
    it "should respond to the method deep_compact!" do
      [ ].should respond_to :deep_compact!
    end

    it "should return nil if all values evaluate as blank" do
      [nil, '', { }, []].deep_compact!.should == []
    end

    it "should return a hash with all blank values removed recursively" do
      @test_arr = ["", nil, [], {}, "foo", { :a=> [nil, {}, { :c=> ["","",[]] } ], :b => nil }]
      @test_arr.deep_compact!.should == ["foo"]
    end
  end
end
