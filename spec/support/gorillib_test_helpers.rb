require 'gorillib/utils/capture_output'
require 'gorillib/utils/nuke_constants'

shared_examples_for 'a model' do

  context 'initialize' do
    it "has no required args" do
      obj = smurf_class.new
      obj.compact_attributes.should == {}
    end
    it "takes the last hashlike arg as the attributes" do
      obj = smurf_class.new :smurfiness => 3, :weapon => :smurfchucks
      obj.compact_attributes.should == { :smurfiness => 3, :weapon => :smurfchucks }
    end

    context 'positional args' do
      before do
        smurf_class.fields[:smurfiness].position = 0
        smurf_class.fields[:weapon    ].position = 1
      end
      it "takes all preceding args as positional, clobbering values set in attrs" do
        obj = smurf_class.new 7,   :smurfing_stars
        obj.compact_attributes.should == { :smurfiness => 7, :weapon => :smurfing_stars }
        obj = smurf_class.new 7,   :smurfing_stars, :smurfiness => 3, :weapon => :smurfchucks
        obj.compact_attributes.should == { :smurfiness => 7, :weapon => :smurfing_stars }
      end
      it "does nothing special with a nil positional arg -- it clobbers anything there setting the attribute to nil" do
        obj = smurf_class.new nil, :smurfiness => 3
        obj.compact_attributes.should == { :smurfiness => nil }
      end
      it "raises an error if too many positional args are given" do
        ->{ smurf_class.new 7, :smurfing_stars, :azrael }.should raise_error(ArgumentError, /wrong number of arguments.*3.*0\.\.2/)
      end
      it "always takes the last hash arg as the attrs -- even if it is in the positional slot of a hash field" do
        smurf_class.field :hashie, Hash, :position => 2
        obj = smurf_class.new({:smurfiness => 3, :weapon => :smurfiken})
        obj.compact_attributes.should == { :smurfiness => 3, :weapon => :smurfiken }
        obj = smurf_class.new(3, :smurfiken, { :weapon => :bastard_smurf })
        obj.compact_attributes.should == { :smurfiness => 3, :weapon => :smurfiken }
        obj = smurf_class.new(3, :smurfiken, {:this => :that}, { :weapon => :bastard_smurf })
        obj.compact_attributes.should == { :smurfiness => 3, :weapon => :smurfiken, :hashie => {:this => :that} }
      end
      it "skips fields that are not positional args" do
        smurf_class.fields[:weapon].unset_attribute(:position)
        smurf_class.field :color, String, :position => 1
        smurf_class.new(99, 'cerulean').compact_attributes.should == { :smurfiness => 99, :color => 'cerulean' }
      end
    end
  end

  context 'receive' do
    let(:my_attrs){ { :smurfiness => 900, :weapon => :wood_smurfer } }
    let(:subklass){ class ::Gorillib::Test::SubSmurf < smurf_class ; end ; ::Gorillib::Test::SubSmurf }

    it "returns nil if given a single nil arg" do
      smurf_class.receive(nil).should == nil
    end
    it "returns the object if given a single object of the model class" do
      smurf_class.receive(poppa_smurf).should equal(poppa_smurf)
    end
    it "raises an error if the attributes are not hashlike" do
      ->{ smurf_class.receive('DURRRR') }.should raise_error(ArgumentError, /attributes .* like a hash: "DURRRR"/)
    end
    context "with hashlike args," do
      before{ Gorillib::Factory.send(:factories).reject!{|th, type| th.to_s =~ /gorillib\.test/ }}

      it "instantiates the object, passing it the attrs and block" do
        my_attrs = { :smurfiness => 900, :weapon => :wood_smurfer }
        smurf_class.should_receive(:new).with(my_attrs)
        smurf_class.receive(my_attrs)
      end
      it "retrieves the right factory if :_type is present" do
        my_attrs = self.my_attrs.merge(:_type => 'gorillib.test.smurf')
        smurf_class.should_receive(:new).with(my_attrs)
        smurf_class.receive(my_attrs)
      end
      it "retrieves the right factory if :_type is present" do
        my_attrs = self.my_attrs.merge(:_type => 'gorillib.test.sub_smurf')
        subklass.should_receive(:new).with(my_attrs)
        smurf_class.receive(my_attrs)
      end
      it 'complains if the given type is not right' do
        mock_factory = mock ; mock_factory.stub(:receive! => {}, :receive => mock, :new => mock_factory)
        mock_factory.should_receive(:<=).and_return(false)
        smurf_class.should_receive(:warn).with(/factory .* is not a type of Gorillib::Test::Smurf/)
        smurf_class.receive(:my_field => 12, :acme => 3, :_type => mock_factory)
      end
    end
  end
end


shared_examples_for "a model field" do |field_name|
  it('gives the model a field'){ subject.class.should have_field(field_name) }

  context '#read_attribute' do
    it "if set, returns the value" do
      subject.write_attribute(field_name, sample_val)
      subject.read_attribute(field_name).should == sample_val
    end
    it "if unset, calls #read_unset_attribute" do
      subject.should_receive(:read_unset_attribute).with(field_name).and_return(mock_val)
      subject.read_attribute(field_name).should == mock_val
    end
    it "does **not** raise an error if the field does not exist (require 'model/lint' if you want it to)" do
      ->{ subject.read_attribute(:fnord) }.should_not raise_error(Gorillib::Model::UnknownFieldError, /unknown field: fnord/)
    end
  end

  context '#write_attribute' do
    it('sets the value') do
      subject.write_attribute(field_name, sample_val)
      subject.read_attribute(field_name).should == sample_val
    end
    it('returns the new value') do
      subject.write_attribute(field_name, sample_val).should == sample_val
    end
    it "does **not** raise an error if the field does not exist (require 'model/lint' if you want it to)" do
      ->{ subject.write_attribute(:fnord, 8) }.should_not raise_error(Gorillib::Model::UnknownFieldError, /unknown field: fnord/)
    end
  end

  context '#attribute_set?' do
    it('is true if the attribute has been set') do
      subject.write_attribute(field_name, sample_val)
      subject.attribute_set?(field_name).should be_true
    end
    it('is true if the attribute has been set, even to nil or false') do
      subject.write_attribute(field_name, nil)
      subject.attribute_set?(field_name).should be_true
    end
    it('is false if never written') do
      subject.attribute_set?(field_name).should be_false
    end
    it "does **not** raise an error if the field does not exist (require 'model/lint' if you want it to)" do
      ->{ subject.attribute_set?(:fnord) }.should_not raise_error(Gorillib::Model::UnknownFieldError, /unknown field: fnord/)
    end
  end

  context "#receive_XX" do
    it('returns the model itself') do
      subject.send("receive_#{field_name}", raw_val).should == subject
    end
    it('type-converts the object') do
      subject.send("receive_#{field_name}", raw_val)
      subject.read_attribute(field_name).should     == sample_val
      subject.read_attribute(field_name).should_not equal(sample_val)
    end
    it('uses a compatible object directly') do
      subject.send("receive_#{field_name}", sample_val)
      subject.read_attribute(field_name).should equal(sample_val)
    end
  end
end
