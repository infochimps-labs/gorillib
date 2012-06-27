require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/array/sorted_median'

describe Array do
  describe '#sorted_median' do
    context 'with empty' do
      it 'returns nil' do
        [].sorted_median.should be_nil
      end
    end

    context 'given any array' do
      it 'returns the middle element of odd-sized arrays' do
        ("a".."y").to_a.sorted_median.should == "m"
      end
    end
  end
end
