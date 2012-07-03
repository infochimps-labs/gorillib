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

  end
end
