require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/metaprogramming/singleton_class'

describe 'Singleton Class' do
  it 'returns the singleton class' do
    o = Object.new
    class << o; self end.should == o.singleton_class
  end
end
