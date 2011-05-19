require File.dirname(__FILE__)+'/../spec_helper'
require 'gorillib/object/try'

class Foo
  def i_am_a_method_hooray
    "i was called!"
  end
end

describe Object do
  describe '#try' do
    it 'returns nil if item does not #respond_to? method' do
      Foo.new.try(:i_am_not_a_method).should be_nil
    end
    it 'calls the method if the item does #respond_to? it' do
      Foo.new.try(:i_am_a_method_hooray).should == "i was called!"
    end
  end
end

