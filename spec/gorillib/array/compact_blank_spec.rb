require 'spec_helper'
require 'gorillib/array/compact_blank'

describe Array, :simple_spec do
  let(:blankish){ double('blankish', :blank? => true) }
  let(:nonblank){ double('nonblank', :blank? => false) }

  describe '#compact_blank' do
    it 'omits nils, like #compact' do
      arr = [nil]
      arr.compact_blank.should == []
      arr.length.should == 1
    end
    it "also omits false, {}, '' and anything else #blank\?" do
      arr = [nil, false, {}, "", blankish]
      arr.compact_blank.should == []
      arr.length.should == 5
    end

    it 'preserves non-blank elements' do
      arr = [nil, 1, nil, 2]
      arr.compact_blank.should == [1, 2]
      arr.length.should == 4
      arr = [nil, 1, false, 2, {}, ""]
      arr.compact_blank.should == [1, 2]
      arr.length.should == 6
    end
  end

  describe '#compact_blank!' do
    it 'removes nils in-place, like #compact!' do
      arr = [nil]
      arr.compact_blank!.should == []
      arr.length.should == 0
    end
    it "removes false, {}, '' and anything else #blank\?" do
      arr = [nil, false, {}, "", blankish]
      arr.compact_blank!.should == []
      arr.length.should == 0
    end

    it 'preserves non-blank elements' do
      arr = [nil, 1, nil, 2]
      arr.compact_blank!.should == [1, 2]
      arr.length.should == 2
      arr = [nil, 1, false, 2, {}, ""]
      arr.compact_blank!.should == [1, 2]
      arr.length.should == 2
    end
  end

end
