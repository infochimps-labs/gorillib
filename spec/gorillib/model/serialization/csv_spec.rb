require 'spec_helper'
require 'support/model_test_helpers'

require 'multi_json'
#
require 'gorillib/model'
require 'gorillib/builder'
require 'gorillib/model/serialization/csv'

describe Gorillib::Model::LoadFromCsv, :model_spec, :builder_spec do

  context ".load_csv" do

    let(:expected_engine) do 
      {:name=>:Wankel, :carburetor=>:no, :volume=>1, :cylinders=>982, :owner=>"who_am_i"}
    end

    before :each do
      engine_class.class_eval { include Gorillib::Model::LoadFromCsv }
      csv_file = double('csv_file')
      csv_file.stub(:shift) {}
      csv_file.stub(:each).and_yield(expected_engine.values)
      CSV.should_receive(:open).and_yield(csv_file)
    end

    it "loads from file" do
      engine_class.load_csv('test').to_wire().first.keep_if{|k,| k != :_type}.should
        eql(expected_engine)
     end

     it "loads from file with block" do
       expect { |b| engine_class.load_csv('test', &b) }.to yield_with_args(engine_class)
     end
  end
end
