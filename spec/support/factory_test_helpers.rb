
#
# Shared examples for testing type factories
#

shared_examples_for :it_converts do |conversion_mapping|
  non_native_ok = conversion_mapping.delete(:non_native_ok)
  conversion_mapping.each do |obj, expected_result|
    it "#{obj.inspect} to #{expected_result.inspect}" do
      actual_result = subject.receive(obj)
      actual_result.should  eql(expected_result)
      subject.native?(  obj).should be_false
      subject.blankish?(obj).should be_false
      unless non_native_ok then subject.native?(actual_result).should be_true  ; end
    end
  end
end

shared_examples_for :it_considers_native do |*native_objs|
  it native_objs.inspect do
    native_objs.each do |obj|
      subject.native?(  obj).should be_true
      actual_result = subject.receive(obj)
      actual_result.should equal(obj)
    end
  end
end

shared_examples_for :it_considers_blankish do |*blankish_objs|
  it blankish_objs.inspect do
    blankish_objs.each do |obj|
      subject.blankish?(obj).should be_true
      subject.receive(obj).should be_nil
    end
  end
end

shared_examples_for :it_is_a_mismatch_for do |*mismatched_objs|
  it mismatched_objs.inspect do
    mismatched_objs.each do |obj|
      ->{ subject.receive(obj) }.should raise_error(Gorillib::Factory::FactoryMismatchError)
    end
  end
end

shared_examples_for :it_is_registered_as do |*keys|
  it "the factory for #{keys}" do
    keys.each do |key|
      Gorillib::Factory(key).should be_a(described_class)
    end
    its_factory = Gorillib::Factory(keys.first)
    Gorillib::Factory.send(:factories).to_hash.select{|key,val| val.equal?(its_factory) }.keys.should == keys
  end
end

# hand it a collection with entries 1, 2, 3 please
shared_examples_for :an_enumerable_factory do
  it "accepts a factory for its items" do
    mock_factory = mock('factory')
    mock_factory.should_receive(:receive).with(1)
    mock_factory.should_receive(:receive).with(2)
    mock_factory.should_receive(:receive).with(3)
    factory = described_class.new(:items => mock_factory)
    factory.receive( collection_123 )
  end
  it "can generate an empty collection" do
    subject.empty_product.should == empty_collection
  end
  it "lets you override the empty collection" do
    ep = mock; ep.should_receive(:try_dup).and_return 'hey'
    subject = described_class.new(:empty_product => ep)
    subject.empty_product.should == 'hey'
    subject = described_class.new(:empty_product => ->{ 'yo' })
    subject.empty_product.should == 'yo'
  end
end
