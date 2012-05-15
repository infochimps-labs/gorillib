require 'spec_helper'
require 'gorillib/object/try'

class Foo
  def i_am_a_method_hooray param='hooray'
    "i was called! #{param}!"
  end
end

describe Object, :simple_spec => true do
  describe '#try' do
    it 'returns nil if item does not #respond_to? method' do
      Foo.new.try(:i_am_not_a_method).should be_nil
      Foo.new.respond_to?(:i_am_not_a_method).should be_false
    end
    it 'calls the method (with args) if the item does #respond_to? it' do
      Foo.new.try(:i_am_a_method_hooray).should == "i was called! hooray!"
      Foo.new.try(:i_am_a_method_hooray, 'yay').should == "i was called! yay!"
    end
  end
end
