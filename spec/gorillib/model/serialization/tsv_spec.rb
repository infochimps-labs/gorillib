require 'spec_helper'
require 'support/model_test_helpers'

require 'multi_json'
#
require 'gorillib/model'
require 'gorillib/builder'
require 'gorillib/model/serialization/tsv'

describe Gorillib::Model::LoadFromTsv, :model_spec, :builder_spec do

  context ".load_tsv" do

    let(:expected_engine) do
      {:name=>:Wankel, :carburetor=>:no, :volume=>1, :cylinders=>982, :owner=>"who_am_i"}
    end

    before :each do
      engine_class.class_eval { include Gorillib::Model::LoadFromTsv }
      engine_class.should_receive(:_each_raw_line).with(:test, {}).
        and_yield(expected_engine.values.join("\t"))
    end

    it "loads from file" do
      engine_class.load_tsv(:test).to_wire().first.keep_if{|k,| k != :_type}.should
        eql(expected_engine)
     end

     it "loads from file with block" do
       expect { |b| engine_class.load_tsv(:test, &b) }.to yield_with_args(engine_class)
     end
  end
end
