require 'spec_helper'
require 'model_test_helpers'

require 'gorillib/model'

describe Gorillib::Model, :only, :model_spec do
  let(:smurf_class) do
    class Gorillib::Test::Smurf
      include Gorillib::Model
      field :smurfiness, Integer
      field :weapon,     Symbol
    end
    Gorillib::Test::Smurf
  end
  let(:poppa_smurf  ){ smurf_class.receive(:name => 'Poppa Smurf',   :smurfiness => 9,  :weapon => 'staff') }
  let(:smurfette    ){ smurf_class.receive(:name => 'Smurfette',     :smurfiness => 11, :weapon => 'charm') }

  let(:simple_model) do
    class Gorillib::Test::SimpleModel
      include Gorillib::Model
      field :my_field,  :whatever
      field :str_field, String
      field :sym_field, Symbol
      self
    end
  end
  let(:subclassed_model) do
    class Gorillib::Test::SubclassedModel < simple_model ; field :zyzzyva, Integer; field :acme, Integer ; end
    Gorillib::Test::SubclassedModel
  end
  let(:nested_model) do
    smurf_class = self.smurf_class
    Gorillib::Test::NestedModel = Class.new(simple_model){ field :smurf, smurf_class }
    Gorillib::Test::NestedModel
  end

  let(:described_class){ simple_model }
  let(:example_inst){    described_class.receive(:my_field => 69) }

  #
  # IT BEHAVES LIKE A MODEL
  # (maybe you wouldn't notice if it was just one little line)
  #
  it_behaves_like 'a model'

  # --------------------------------------------------------------------------

  context 'examples' do
    it 'type-converts values' do
      obj = simple_model.receive({
          :my_field => 'accepted as-is', :str_field => :bob, :sym_field => 'converted_to_sym'
        })
      obj.attributes.should == { :my_field => 'accepted as-is', :str_field => 'bob', :sym_field=>:converted_to_sym }
    end
    it 'handles nested structures' do
      deep_obj = nested_model.receive(:str_field => 'deep, man', :smurf => poppa_smurf.attributes)
      deep_obj.attributes.should == { :str_field => 'deep, man', :smurf => poppa_smurf, :sym_field=>nil, :my_field => nil, }
    end
  end

  context ".field" do
    it "describes an attribute" do
      example_inst.compact_attributes.should == { :my_field => 69 }
      example_inst.write_attribute(:my_field, 3).should == 3
      example_inst.compact_attributes.should == { :my_field => 3 }
      example_inst.read_attribute(:my_field).should == 3
    end
    it 'inherits fields from its parent class, even if they are added later' do
      simple_model.field_names.should    == [:my_field, :str_field, :sym_field]
      subclassed_model.field_names.should  == [:my_field, :str_field, :sym_field, :zyzzyva, :acme]
      simple_model.field :banksy, String
      simple_model.field_names.should    == [:my_field, :str_field, :sym_field, :banksy ]
      subclassed_model.field_names.should  == [:my_field, :str_field, :sym_field, :banksy, :zyzzyva, :acme]
    end

    it "supplies a reader method #foo to call read_attribute(:foo)" do
      example_inst.should_receive(:read_attribute).with(:my_field).and_return(mock_val)
      example_inst.my_field.should == mock_val
    end
    it "supplies a writer method #foo= to call write_attribute(:foo)" do
      example_inst.should_receive(:write_attribute).with(:my_field, mock_val)
      (example_inst.my_field = mock_val).should == mock_val
    end
    it "supplies a receiver method #receive_foo to call write_attribute(:foo) and return self" do
      example_inst.should_receive(:write_attribute).with(:my_field, mock_val)
      (example_inst.receive_my_field(mock_val)).should == example_inst
    end
    it "sets visibility of reader with :reader => ()" do
      described_class.field :test_field, Integer, :reader => :private, :writer => false
      described_class.public_instance_methods.should_not  include(:test_field)
      described_class.private_instance_methods.should     include(:test_field)
      described_class.public_instance_methods.should_not  include(:test_field=)
      described_class.private_instance_methods.should_not include(:test_field=)
    end
  end

  context '.field' do
    subject{ described_class.new }
    let(:sample_val){  'bob' }
    let(:raw_val){     :bob  }
    it_behaves_like 'a model field', :str_field
  end

  context '#attributes' do
    it "maps field names to attribute values" do
      example_inst = simple_model.receive({:my_field=>7, :str_field=>'yo', :sym_field=>:sup})
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
      model_with_no_fields = Class.new{ include Gorillib::Model }
      model_with_no_fields.new.attributes.should == {}
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
    it "returns nil with no block given" do
      example_inst.receive!('my_field'=>7, :str_field=>'yo').should be_nil
    end
  end

  context '#== -- two models are equal if' do
    let(:subklass){ Class.new(described_class) }
    let(:obj_2){ described_class.receive(:my_field => 69) }
    let(:obj_3){ subklass.receive(:my_field => 69) }

    it 'they have the same class' do
      example_inst.attributes.should == obj_2.attributes
      example_inst.attributes.should == obj_3.attributes
      example_inst.should     == obj_2
      example_inst.should_not == obj_3
    end
    it 'and the same attributes' do
      example_inst.attributes.should == obj_2.attributes
      example_inst.should            == obj_2
      obj_2.my_field = 100
      example_inst.should_not == obj_2
    end
  end

  context ".fields" do
    it 'is a hash of Gorillib::Model::Field objects' do
      described_class.fields.keys.should  == [:my_field, :str_field, :sym_field]
      described_class.fields.values.each{|f| f.should be_a(Gorillib::Model::Field) }
      described_class.fields.values.map(&:name).should == [:my_field, :str_field, :sym_field]
    end
  end

  context '.has_field?' do
    it 'is true if the field exists' do
      simple_model.has_field?(  :my_field).should be_true
      subclassed_model.has_field?(:my_field).should be_true
      subclassed_model.has_field?(:zyzzyva ).should be_true
    end
    it 'is false if it does not exist' do
      simple_model.has_field?(  :zyzzyva).should be_false
      simple_model.has_field?(  :fnord  ).should be_false
      subclassed_model.has_field?(:fnord  ).should be_false
    end
  end

  context '.field_names' do
    it 'lists fields in order by class, then in order added' do
      described_class.field_names.should   == [:my_field, :str_field, :sym_field]
      subclassed_model.field_names.should  == [:my_field, :str_field, :sym_field, :zyzzyva, :acme]
      described_class.field :banksy, String
      described_class.field_names.should   == [:my_field, :str_field, :sym_field, :banksy ]
      subclassed_model.field_names.should  == [:my_field, :str_field, :sym_field, :banksy, :zyzzyva, :acme]
    end
  end

  context '.typename' do
    it 'has a typename that matches its underscored class name' do
      described_class.typename.should == 'gorillib.test.simple_model'
    end
  end

  describe Gorillib::Model::NamedSchema do
    context ".meta_module" do
      let(:basic_field_names){ [ :my_field, :my_field=, :receive_my_field, :receive_str_field, :receive_sym_field, :str_field, :str_field=, :sym_field, :sym_field= ]}
      let(:anon_class){    Class.new{ include Gorillib::Model ; field :my_field, :whatever } }

      it "is named for the class (if the class is named)" do
        described_class.send(:meta_module).should == Meta::Gorillib::Test::SimpleModelType
      end
      it "is anonymous if the class is anonymous" do
        anon_class.name.should be_nil
        anon_class.send(:meta_module).should be_a(Module)
        anon_class.send(:meta_module).name.should be_nil
      end
      it "carries the field-specfic accessor and receive methods" do
        described_class.send(:meta_module).public_instance_methods.sort.should == basic_field_names
        anon_class.send(:meta_module).public_instance_methods.sort.should      == [:my_field, :my_field=, :receive_my_field]
      end
      it "is injected right after the Gorillib::Model module" do
        described_class.ancestors.first(4).should == [described_class, Meta::Gorillib::Test::SimpleModelType, Gorillib::Model, Object]
        described_class.should < Meta::Gorillib::Test::SimpleModelType
      end
      it "retrieves an existing named module if one exists" do
        Gorillib::Test.should_not be_const_defined(:TestClass)
        module Meta::Gorillib::Test::SimpleModelType ; def kilroy_was_here() '23 skidoo' ; end ; end
        described_class.send(:meta_module).public_instance_methods.sort.should == (basic_field_names + [:kilroy_was_here]).sort
        Gorillib::Test.should be_const_defined(:SimpleModel)
        described_class.send(:meta_module).should == Meta::Gorillib::Test::SimpleModelType
      end
    end
  end

end
