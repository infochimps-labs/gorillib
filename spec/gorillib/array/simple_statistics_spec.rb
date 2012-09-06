require 'spec_helper'
require 'gorillib/array/simple_statistics'

describe Array, :simple_spec do
  let(:seven_squares){ [ 1, 4, 9, 16, 25, 36, 49] }
  let(:five_squares ){ [   1, 4,  16,  36, 49   ] }
  let(:one_element  ){ [          16            ] }
  subject{ seven_squares }

  describe '#average' do
    it('is nil for empty array'){ [].average.should be_nil }
    it('is the numeric mean') do
      five_squares.average.should  eql 21.2
      seven_squares.average.should eql 20.0
      one_element.average.should   eql 16.0
    end
    it('is is uptyped by its elements') do
      five_squares.map(&:to_f).average.should eql 21.2
      [ Complex(1.0,2.0), Complex(3,4), Complex(5) ].average.should eql Complex(3.0,2.0)
      [ Complex(1,2),     Complex(3,4), Complex(5) ].average.should eql (Complex(9,6) / 3.0)
    end
    context 'on non-float array element' do
      it 'raises error' do
        expect{ [0.0, :b, 1.0].average }.to raise_error(TypeError, /:b can\'t be coerced into Float/)
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

  describe '#at_fraction' do
    it('is nil for empty array'){ [].at_fraction(0.5).should be_nil }
    it 'indexes correctly' do
      seven_squares.at_fraction(0  ).should == 1
      seven_squares.at_fraction(0.5).should == 16
      seven_squares.at_fraction(1.0).should == 49
      five_squares.at_fraction(0.75).should == 36
    end
    it 'returns the value the nth of the way along' do
      (0..6).map{|nth| seven_squares.at_fraction(nth/6.0).should == seven_squares[nth] }
    end

    it 'raises if the fraction is not a number between 0.0 and 1.0' do
      expect{ subject.at_fraction(1.0001) }.to raise_error(ArgumentError, /between 0.0 and 1\.0: got 1\.0001/)
      expect{ subject.at_fraction(-1)     }.to raise_error(ArgumentError, /between 0.0 and 1\.0: got -1/)
      expect{ subject.at_fraction('1.1')  }.to raise_error(ArgumentError, /between 0.0 and 1\.0: got \"1.1\"/)
    end
  end

  describe '#take_nths' do
    it 'gives elements at 0.5/n, 1.5/n, 2.5/n ... n-0.5/n' do
      five_squares.take_nths(2).should   == [   4,         36   ]
      five_squares.take_nths(3).should   == [   4,   16,   36   ]
      five_squares.take_nths(4).should   == [   4,   16,   36,49]
      five_squares.take_nths(5).should   == [1, 4,   16,   36,49]
      seven_squares.take_nths(1).should  == [        16         ]
      seven_squares.take_nths(2).should  == [      9,      36   ]
      seven_squares.take_nths(3).should  == [   4,   16,   36   ]
      seven_squares.take_nths(4).should  == [   4, 9,   25,36   ]
      seven_squares.take_nths(5).should  == [   4, 9,16,25,36   ]
      seven_squares.take_nths(6).should  == [   4, 9,16,25,36,49]
      seven_squares.take_nths(99).should == seven_squares
      seven_squares.take_nths(0).should  == []
      [].take_nths(3).should == []
    end
    context 'with empty' do
      it 'returns an empty array' do
        [].take_nths(1).should be_empty
      end
    end
    context 'given any array' do
      it ('returns a sample of the given size as close to evenly ' \
          'distributed over the array as possible') do
        nths = (1..100).to_a.take_nths(26)
        deltas = nths[0..-2].zip(nths[1..-1]).map{|a,b| b-a}
        deltas.max.should <= 4
        deltas.min.should >= 3
      end
    end
    context 'given an undersized array' do
      it 'does not return the same element more than once' do
        ("a".."z").to_a.take_nths(27).should == ("a".."z").to_a
      end
    end
  end

  describe '#sorted_median' do
    it 'takes the halfway-th element' do
      five_squares.sorted_median.should eql 16
      seven_squares.sorted_median.should eql 16
    end
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

    it 'takes fractional index at pct/100' do
      five_squares .sorted_percentile(50).should eql 16
      seven_squares.sorted_percentile(10).should eql  4
      seven_squares.sorted_percentile(50).should eql 16
      seven_squares.sorted_percentile(90).should eql 36
      seven_squares.sorted_percentile(100).should eql 49
    end
    it 'returns nil on empty array' do
      [].sorted_median.should be nil
    end
  end


end
