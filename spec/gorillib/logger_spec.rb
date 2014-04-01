require 'spec_helper'
require 'gorillib/logger'

describe Gorillib::Logger, simple_spec: true do
  let(:logged_class) do
    module X
      class Y
        include Gorillib::Logger
      end
    end

    X::Y
  end
  let(:expected_logger){ Log4r::Logger[logged_class.name] }

  it 'returns a Log4r logger indexed by class name' do
    logged_class.new.log.should eql(expected_logger)
  end
  it 'returns a Log4r logger indexed by name, if this is a class' do
    logged_class.log.should eql(expected_logger)
  end
end
