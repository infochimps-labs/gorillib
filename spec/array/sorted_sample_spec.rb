require File.expand_path('../spec_helper', File.dirname(__FILE__))
require 'gorillib/array/sorted_sample'

describe Array do
  describe '#sorted_median' do
    context 'with empty' do
      it 'returns an empty array' do
        [].sorted_sample(1).should be_empty
      end
    end

    context 'given an undersized array' do
      it 'does not return the same element more than once' do
        ("a".."z").to_a.sorted_sample(27).should == ("a".."z").to_a
      end
    end

    context 'given any array' do
      it ('returns a sample of the given size as close to evenly ' \
          'distributed over the array as possible') do
        sample = (1..100).to_a.sorted_sample(26)
        puts "!!! #{sample}"
        deltas = sample[0..-2].zip(sample[1..-1]).map{|a,b| b-a}
        deltas.max.should <= 4
        deltas.min.should >= 3
      end
    end
  end
end
