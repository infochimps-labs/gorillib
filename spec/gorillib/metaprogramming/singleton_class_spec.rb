require 'spec_helper'
require 'gorillib/metaprogramming/singleton_class'

describe 'Singleton Class', :metaprogramming_spec => true do
  it 'returns the singleton class' do
    o = Object.new
    class << o; self end.should == o.singleton_class
  end

  it 'does not have an effect if already provided by another library.' unless ENV['QUIET_RSPEC']

end
