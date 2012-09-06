module Gorillib
  module Model

    # All exceptions defined by Gorillib::Model include this module.
    module Error
    end

    # Exception raised if attempting to assign unknown fields
    class UnknownFieldError < ::NoMethodError
      include Gorillib::Model::Error
    end

    class ConflictingPositionError < ::ArgumentError
      include Gorillib::Model::Error
    end

    # Exception raised if deserialized attributes don't have the right shape:
    # for example, a CSV line with too many/too few fields
    class RawDataMismatchError < ::StandardError
      include Gorillib::Model::Error
    end

  end
end
