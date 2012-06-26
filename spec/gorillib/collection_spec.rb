require 'spec_helper'
#
require 'gorillib/model'
require 'gorillib/collection/model_collection'
require 'gorillib/collection/list_collection'
require 'model_test_helpers'

shared_context :collection_spec do
  # a collection with the internal :clxn mocked out, and a method 'innards' to
  # let you access it.
  let(:collection_with_mock_innards) do
    coll = described_class.new
    coll.send(:instance_variable_set, :@clxn, mock('clxn hash') )
    coll.send(:define_singleton_method, :innards){ @clxn }
  end
end

shared_examples_for 'a collection' do
  subject{ string_collection }

  context '.receive' do
    it 'makes a new collection, has it #receive! the cargo, returns it' do
      mock_collection = mock('collection')
      mock_cargo      = mock('cargo')
      mock_args       = [mock, mock]
      described_class.should_receive(:new).with(*mock_args).and_return(mock_collection)
      mock_collection.should_receive(:receive!).with(mock_cargo)
      described_class.receive(mock_cargo, *mock_args).should == mock_collection
    end
  end

  context 'empty collection' do
    subject{ described_class.new }
    its(:length){ should == 0 }
    its(:size  ){ should == 0 }
    its(:empty?){ should be true }
    its(:blank?){ should be true }
    its(:values){ should == [] }
    its(:to_a  ){ should == [] }
  end
  context 'non-empty collection' do
    subject{ string_collection }
    its(:length){ should == 4 }
    its(:size  ){ should == 4 }
    its(:empty?){ should be false }
    its(:blank?){ should be false }
  end

  context '#values returns an array' do
    its(:values){ should == %w[wocket in my pocket] }
  end
  context '#to_a returns same as values' do
    its(:to_a  ){ should == %w[wocket in my pocket] }
  end

  context '#each_value' do
    it 'each value in order' do
      result = []
      ret = subject.each_value{|val| result << val.reverse }
      result.should == %w[tekcow ni ym tekcop]
    end
  end

  # context '#receive (array)', :if => :receives_arrays do
  #   it 'adopts the contents of an array'  do
  #     string_collection.receive!(%w[horton hears a who])
  #     string_collection.values.should == %w[wocket in my pocket horton hears a who]
  #   end
  #   it 'does not adopt duplicates' do
  #     string_collection.receive!(%w[red fish blue fish])
  #     string_collection.values.should == %w[wocket in my pocket red fish blue]
  #   end
  # end
  context '#receive (hash)' do
    it 'adopts the values of a hash' do
      string_collection.receive!({horton: "horton", hears: "hears", a: "a", who: "who" })
      string_collection.values.should == %w[wocket in my pocket horton hears a who]
    end
    it 'does not adopt duplicates' do
      string_collection.receive!({red:  'red',  fish: 'fish'})
      string_collection.receive!({blue: 'blue', fish: 'fish'})
      string_collection.values.should == %w[wocket in my pocket red fish blue]
    end
  end

end

shared_examples_for 'a keyed collection' do
  subject{ string_collection }

  context '#[]' do
    it 'retrieves stored objects' do
      subject[1] = mock_val
      subject[1].should equal(mock_val)
    end
  end

  context '#fetch' do
    it 'retrieves an object if present' do
      subject[1] = mock_val
      subject.fetch(1).should equal(mock_val)
    end
    it 'if absent and block given: calls block with label, returning its value' do
      got_here = nil
      subject.fetch(69){ got_here = 'yup' ; mock_val }.should equal(mock_val)
      got_here.should == 'yup'
    end
    it 'if absent and no block given: raises an error' do
      ->{ subject.fetch(69) }.should raise_error IndexError, /(key not found: 69|index 69 outside)/
    end
  end

  context '#delete' do
    it 'retrieves an object if present' do
      subject[1] = mock_val
      subject.delete(1).should equal(mock_val)
      subject.values.should_not include(mock_val)
    end
    it 'if absent and block given: calls block with label, returning its value' do
      got_here = nil
      subject.delete(69){ got_here = 'yup' ; mock_val }.should equal(mock_val)
      got_here.should == 'yup'
    end
    it 'if absent and no block given: returns nil' do
      subject.delete(69).should be nil
    end
  end
end

shared_examples_for 'an auto-keyed collection' do
  subject{ string_collection }

  it 'retrieves things by their label' do
    string_collection[:pocket].should == "pocket"
    string_collection['pocket'].should == nil
    shouty_collection['POCKET'].should == "pocket"
    shouty_collection['pocket'].should == nil
  end

  it 'gets label from key if none supplied' do
    string_collection[:marvin].should be nil
    string_collection << 'marvin'
    string_collection[:marvin].should == 'marvin'
    shouty_collection << 'marvin'
    shouty_collection['MARVIN'].should == 'marvin'
  end

  context '#receive!' do
    it 'extracts labels given an array' do
      subject.receive!(%w[horton hears a who])
      subject[:horton].should == 'horton'
    end
    it 'replaces labels in-place, preserving order' do
      shouty_collection.receive!(%w[in MY pocKET wocKET])
      shouty_collection['WOCKET'].should == 'wocKET'
      shouty_collection.values.should == %w[wocKET in MY pocKET]
    end
  end

  context '#<<' do
    it 'adds element under its natural label, at end' do
      subject << 'marvin'
      subject.values.last.should == 'marvin'
      subject[:marvin].should == 'marvin'
    end
    it 'replaces duplicate values' do
      val = 'wocKET'
      shouty_collection['WOCKET'].should     == 'wocket'
      shouty_collection['WOCKET'].should_not equal(val)
      shouty_collection << val
      shouty_collection['WOCKET'].should     == 'wocKET'
      shouty_collection['WOCKET'].should     equal(val)
    end
  end

end

describe 'collections:', :model_spec, :collection_spec do

  describe Gorillib::ListCollection do
    let(:string_collection){ described_class.receive(%w[wocket in my pocket]) }
    it_behaves_like 'a collection'
    # it_behaves_like 'a keyed collection'
  end

  describe Gorillib::Collection, :receives_arrays => false do
    let(:string_collection){ described_class.receive({:wocket  => 'wocket', :in  => 'in', :my  => 'my', :pocket  => 'pocket'}) }
    let(:shouty_collection){ described_class.receive({'WOCKET' => 'wocket', 'IN' => 'in', 'MY' => 'my', 'POCKET' => 'pocket'}) }
    it_behaves_like 'a collection', :receives_arrays => false
    it_behaves_like 'a keyed collection'

    # I only want the 'adopts the contents of an array' to run when the
    # it_behaves_like group says it should be part of the specs.
    it "needs travis's rspec help on the 'adopts the contents of an array' spec"

  end

  describe Gorillib::ModelCollection do
    let(:string_collection){ described_class.receive(%w[wocket in my pocket], :to_sym, String) }
    let(:shouty_collection){ described_class.receive(%w[wocket in my pocket], :upcase, String) }
    it_behaves_like 'a collection'
    it_behaves_like 'a keyed collection'
    it_behaves_like 'an auto-keyed collection'
  end
end
