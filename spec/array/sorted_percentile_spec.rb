require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/array/sorted_percentile'

describe Array do
  describe '#sorted_percentile' do
    context 'with empty' do
      it 'returns nil' do
        [].sorted_percentile(0.0).should be_nil
      end
    end

    context 'given any array' do
      it 'returns the element closest to the given percentile' do
        ("a".."y").to_a.sorted_percentile(  0.0).should == "a"
        ("a".."y").to_a.sorted_percentile( 50.0).should == "m"
        ("a".."y").to_a.sorted_percentile(100.0).should == "y"
      end
    end

    # (Please do not define behavior for two elements equally close to
    # a given percentile.)

  end
end
