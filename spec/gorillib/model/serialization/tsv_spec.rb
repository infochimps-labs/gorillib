require 'spec_helper'
require 'support/model_test_helpers'

require 'multi_json'
#
require 'gorillib/model'
require 'gorillib/builder'
require 'gorillib/model/serialization/tsv'

describe Gorillib::Model, :model_spec, :builder_spec do

  context ".load_tsv" do
    # it "respects blank characters at end of line, so '1\\t2\\t\\t\\t becomes [\"1\",\"2\",\"\",\"\",\"\"]" do
    #   # make sure
    # end
  end
end
