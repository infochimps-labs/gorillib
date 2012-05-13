require File.expand_path('../spec_helper', File.dirname(__FILE__))
#
require 'gorillib/record'
require 'gorillib/record/field'
require 'gorillib/record/defaults'
#
require 'record_test_helpers'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Record, :record_spec => true do
  after(:each){   Gorillib::Test.nuke_constants ; Meta::Gorillib::Test.nuke_constants }

  let(:simple_record){ class Gorillib::Test::TestClass ; include Gorillib::Record ; field :my_field, Whatever ; self ; end }
  let(:anon_class){    Class.new{ include Gorillib::Record ; field :my_field, :whatever } }
  let(:example_inst){ subject.receive(:my_field => 69) }
  let(:example_val){ mock('example val') }
  let(:complex_class) do
    class Gorillib::Test::ComplexRecord
      include Gorillib::Record
      field :my_field,  :whatever
      field :str_field, String
      field :sym_field, Symbol
      self
    end
  end
  let(:complex_subclass){ Gorillib::Test::TestSubclass = Class.new(complex_class){ field :zyzzyva, Integer; field :acme, Integer } }
  subject{ complex_class }

  context 'examples' do
    let(:nested_class){ Class.new(complex_class){ field :another_record, self } }
    it 'type-converts values' do
      obj = complex_class.receive({
          :my_field => 'accepted as-is', :str_field => :bob, :sym_field => 'converted_to_sym'
        })
      obj.attributes.should == { :my_field => 'accepted as-is', :str_field => 'bob', :sym_field=>:converted_to_sym }
    end
    it 'handles nested structures' do
      obj      = nested_class.receive({ :my_field => 69 })
      obj.attributes.should == { :my_field => 69, :str_field => nil, :sym_field=>nil, :another_record => nil }
      deep_obj = nested_class.receive(:my_field => 111, :str_field => 'deep, man',
        :another_record => { :my_field => 69, :another_record => nil })
      deep_obj.attributes.should == { :my_field => 111, :str_field => 'deep, man', :sym_field=>nil, :another_record => obj }
    end
  end

  context ".field" do
    subject{ simple_record }
    it "describes an attribute" do
      example_inst.attributes.should == { :my_field => 69 }
      example_inst.write_attribute(:my_field, 3).should == 3
      example_inst.attributes.should == { :my_field => 3 }
      example_inst.read_attribute(:my_field).should == 3
    end
    it 'inherits fields from its parent class, even if they are added later' do
      complex_class.field_names.should    == [:my_field, :str_field, :sym_field]
      complex_subclass.field_names.should  == [:my_field, :str_field, :sym_field, :zyzzyva, :acme]
      complex_class.field :banksy, String
      complex_class.field_names.should    == [:my_field, :str_field, :sym_field, :banksy ]
      complex_subclass.field_names.should  == [:my_field, :str_field, :sym_field, :banksy, :zyzzyva, :acme]
    end

    it "supplies a reader method #foo to call read_attribute(:foo)" do
      example_inst.should_receive(:read_attribute).with(:my_field).and_return(example_val)
      example_inst.my_field.should == example_val
    end
    it "supplies a writer method #foo= to call write_attribute(:foo)" do
      example_inst.should_receive(:write_attribute).with(:my_field, example_val)
      (example_inst.my_field = example_val).should == example_val
    end
    it "supplies a receiver method #receive_foo to call write_attribute(:foo) and return self" do
      example_inst.should_receive(:write_attribute).with(:my_field, example_val)
      (example_inst.receive_my_field(example_val)).should == example_inst
    end
    it "sets visibility of reader with :reader => ()" do
      subject.field :test_field, Integer, :reader => :private, :writer => false
      subject.public_instance_methods.should_not  include(:test_field)
      subject.private_instance_methods.should     include(:test_field)
      subject.public_instance_methods.should_not  include(:test_field=)
      subject.private_instance_methods.should_not include(:test_field=)
    end
  end

  context '.field' do
    subject{           complex_class.new }
    let(:sample_val){  'bob' }
    let(:raw_val){     :bob  }
    it_behaves_like 'a record field', :str_field
  end

  context '#attributes' do
    it "maps field names to attribute values" do
      example_inst = subject.receive({:my_field=>7, :str_field=>'yo', :sym_field=>:sup})
      example_inst.attributes.should == {:my_field=>7, :str_field=>'yo', :sym_field=>:sup}
    end
    it "includes all field names, set and unset" do
      example_inst.attributes.should == {:my_field=>69, :str_field=>nil, :sym_field=>nil}
      example_inst.receive!(:my_field=>7, :str_field=>'yo')
      example_inst.attributes.should == {:my_field=>7, :str_field=>'yo', :sym_field=>nil}
    end
    it "goes throught the #read_attribute interface" do
      example_inst.should_receive(:read_attribute).with(:my_field).and_return('int')
      example_inst.should_receive(:read_attribute).with(:str_field).and_return('str')
      example_inst.should_receive(:read_attribute).with(:sym_field).and_return('sym')
      example_inst.attributes.should == {:my_field=>'int', :str_field=>'str', :sym_field=>'sym'}
    end
    it "is an empty hash if there are no fields" do
      subject = Class.new{ include Gorillib::Record }
      subject.new.attributes.should == {}
    end
  end

  context '#unset_attribute' do
    it "unsets the attribute" do
      example_inst.attribute_set?(:my_field).should be_true
      example_inst.unset_attribute(:my_field)
      example_inst.attribute_set?(:my_field).should be_false
    end
    it "if set, returns the former value" do
      example_inst.unset_attribute(:my_field ).should == 69
      example_inst.unset_attribute(:str_field).should == nil
    end
    it "raises an error if the field does not exist" do
      ->{ example_inst.unset_attribute(:fnord) }.should raise_error(Gorillib::Record::UnknownFieldError, /unknown field: fnord/)
    end
  end

  context '#update_attributes' do
    it "consumes a map from field names to new values" do
      example_inst.attributes.should == {:my_field=>69, :str_field=>nil, :sym_field=>nil}
      example_inst.update_attributes({:my_field=>7, :str_field=>'yo'})
      example_inst.attributes.should == {:my_field=>7, :str_field=>'yo', :sym_field=>nil}
      example_inst.update_attributes({:str_field=>'ok', :sym_field => :bye})
      example_inst.attributes.should == {:my_field=>7, :str_field=>'ok', :sym_field=>:bye}
    end
    it "takes string or symbol keys" do
      example_inst.update_attributes 'my_field'=>7, :str_field=>'yo'
      example_inst.attributes.should == {:my_field=>7, :str_field=>'yo', :sym_field=>nil}
    end
    it "goes throught the #write_attribute interface" do
      example_inst.should_receive(:write_attribute).with(:my_field,  7)
      example_inst.should_receive(:write_attribute).with(:str_field, 'yo')
      example_inst.update_attributes 'my_field'=>7, :str_field=>'yo'
    end
  end

  context '#receive!' do
    it "consumes a map from field names to new values" do
      example_inst.attributes.should == {:my_field=>69, :str_field=>nil, :sym_field=>nil}
      example_inst.receive!({:my_field=>7, :str_field=>'yo'})
      example_inst.attributes.should == {:my_field=>7, :str_field=>'yo', :sym_field=>nil}
      example_inst.receive!({:str_field=>'ok', :sym_field => :bye})
      example_inst.attributes.should == {:my_field=>7, :str_field=>'ok', :sym_field=>:bye}
    end
    it "takes string or symbol keys" do
      example_inst.receive! 'my_field'=>7, :str_field=>'yo'
      example_inst.attributes.should == {:my_field=>7, :str_field=>'yo', :sym_field=>nil}
    end
    it "goes throught the #write_attribute interface" do
      example_inst.should_receive(:write_attribute).with(:my_field,  7)
      example_inst.should_receive(:write_attribute).with(:str_field, 'yo')
      example_inst.receive! 'my_field'=>7, :str_field=>'yo'
    end
  end

  context '#== -- two records are equal if' do
    let(:subklass){ Class.new(subject) }
    let(:obj_2){ subject.receive(:my_field => 69) }
    let(:obj_3){ subklass.receive(:my_field => 69) }

    it 'they have the same class' do
      example_inst.attributes.should == obj_2.attributes
      example_inst.attributes.should == obj_3.attributes
      example_inst.should     == obj_2
      example_inst.should_not == obj_3
    end
    it 'and the same attributes' do
      example_inst.attributes.should == obj_2.attributes
      example_inst.should     == obj_2
      obj_2.my_field = 100
      example_inst.should_not == obj_2
    end
  end

  context ".fields" do
    it 'is a hash of Gorillib::Record::Field objects' do
      subject.fields.keys.should  == [:my_field, :str_field, :sym_field]
      subject.fields.values.each{|f| f.should be_a(Gorillib::Record::Field) }
      subject.fields.values.map(&:name).should == [:my_field, :str_field, :sym_field]
    end
  end

  context '.has_field?' do
    it 'is true if the field exists' do
      complex_class.has_field?(  :my_field).should be_true
      complex_subclass.has_field?(:my_field).should be_true
      complex_subclass.has_field?(:zyzzyva ).should be_true
    end
    it 'is false if it does not exist' do
      complex_class.has_field?(  :zyzzyva).should be_false
      complex_class.has_field?(  :fnord  ).should be_false
      complex_subclass.has_field?(:fnord  ).should be_false
    end
  end

  context '.field_names' do
    it 'lists fields in order by class, then in order added' do
      subject.field_names.should   == [:my_field, :str_field, :sym_field]
      complex_subclass.field_names.should  == [:my_field, :str_field, :sym_field, :zyzzyva, :acme]
      subject.field :banksy, String
      subject.field_names.should   == [:my_field, :str_field, :sym_field, :banksy ]
      complex_subclass.field_names.should  == [:my_field, :str_field, :sym_field, :banksy, :zyzzyva, :acme]
    end
  end

  context '.typename' do
    it 'has a typename that matches its underscored class name' do
      subject.typename.should == 'gorillib.test.complex_record'
    end
  end

  context '.receive' do
    it 'creates a new instance' do
      obj = example_inst
      subject.should_receive(:new).with().and_return(obj)
      result = subject.receive(:my_field => 12)
      result.should equal(obj)
      result.my_field.should == 12
    end
    it 'calls receive! to set the attributes, and returns the object' do
      obj = example_inst
      subject.should_receive(:new).with().and_return(obj)
      obj.should_receive(:receive!).with(:my_field => 12)
      subject.receive(:my_field => 12).should equal(obj)
    end

    it 'uses the given type if the _type attribute is a factory' do
      obj = complex_class.receive(:my_field => 12, :acme => 3, :_type => complex_subclass)
      obj.should be_a(complex_subclass)
    end

    it 'complains if the given type is not right' do
      mock_factory = mock ; mock_factory.stub(:receive! => {}, :receive => mock, :new => mock_factory)
      mock_factory.should_receive(:<=).and_return(false)
      complex_class.should_receive(:warn).with(/doesn't match type/)
      complex_class.receive(:my_field => 12, :acme => 3, :_type => mock_factory)
    end

    it 'uses the given type if the _type attribute is a typename' do
      complex_subclass.typename.should == 'gorillib.test.test_subclass'
      obj = complex_class.receive(:my_field => 12, :acme => 3, :_type => 'gorillib.test.test_subclass')
      obj.should be_a(complex_subclass)
    end
  end

  describe Gorillib::Record::NamedSchema do
    subject{ simple_record }
    context ".meta_module" do
      it "is named for the class (if the class is named)" do
        subject.send(:meta_module).should == Meta::Gorillib::Test::TestClassType
      end
      it "is anonymous if the class is anonymous" do
        anon_class.name.should be_nil
        anon_class.send(:meta_module).should be_a(Module)
        anon_class.send(:meta_module).name.should be_nil
      end
      it "carries the field-specfic accessor and receive methods" do
        subject.send(:meta_module).public_instance_methods.sort.should    == [:my_field, :my_field=, :receive_my_field]
        anon_class.send(:meta_module).public_instance_methods.sort.should == [:my_field, :my_field=, :receive_my_field]
      end
      it "is injected right after the Gorillib::Record module" do
        subject.ancestors.first(4).should == [subject, Meta::Gorillib::Test::TestClassType, Gorillib::Record, Object]
        subject.should < Meta::Gorillib::Test::TestClassType
      end
      it "retrieves an existing named module if one exists" do
        Gorillib::Test.should_not be_const_defined(:TestClass)
        module Meta::Gorillib::Test::TestClassType ; def kilroy_was_here() '23 skidoo' ; end ; end
        subject.send(:meta_module).public_instance_methods.sort.should == [:kilroy_was_here, :my_field, :my_field=, :receive_my_field]
        Gorillib::Test.should be_const_defined(:TestClass)
        subject.send(:meta_module).should == Meta::Gorillib::Test::TestClassType
      end
    end
  end

end
