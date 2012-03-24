require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/metaprogramming/singleton_class'

describe 'Singleton Class' do
  it 'returns the singleton class' do
    o = Object.new
    class << o; self end.should == o.singleton_class
  end

  it 'does not have an effect if already provided by another library.' unless ENV['QUIET_RSPEC']

end
