require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/array/average'

describe Array do
  describe '#average' do
    context 'on non-float array element' do
      it 'raises error' do
        expect { [0.0, :b, 1.0].average }.should raise_error(ArgumentError)
      end
    end

    context 'with empty' do
      it 'returns nil' do
        [].average.should be_nil
      end
    end

    context 'given a numerical array' do
      it 'returns the average of the elements' do
        (1..10).to_a.average.should == 5.5
      end
    end
  end
end
