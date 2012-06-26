require 'spec_helper'
#
require 'gorillib/model'
require 'gorillib/collection/model_collection'
require 'gorillib/collection/simple_collection'
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

end

describe Gorillib::ModelCollection, :model_spec => true, :collection_spec => true do
  it_behaves_like 'a collection'
end
