require 'spec_helper'
#
require 'gorillib/model'
require 'gorillib/model/field'
require 'gorillib/model/defaults'
#
require 'model_test_helpers'

module Gorillib::Test       ; end
module Meta::Gorillib::Test ; end

describe Gorillib::Collection, :model_spec => true do
  it 'needs more tests'
  let(:collection_with_mock_clxn) do
    coll = described_class.new
    coll.send(:define_singleton_method, :mock_clxn){ @clxn }
    coll.send(:instance_variable_set, :@clxn, mock('clxn hash') )
  end

end
