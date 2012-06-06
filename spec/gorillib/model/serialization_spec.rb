require 'spec_helper'
require 'model_test_helpers'
require 'multi_json'
#
require 'gorillib/model'
require 'gorillib/model/serialization'


describe Gorillib::Model, :model_spec => true do
  subject{ poppa_smurf }

  it '' do
    p subject
    p subject.to_json
  end
end
