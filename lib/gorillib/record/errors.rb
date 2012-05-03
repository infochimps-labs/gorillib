module Gorillib
  module Record

    # All exceptions defined by Gorillib::Record include this module.
    module Error
    end

    # Exception raised if attempting to assign unknown fields
    class UnknownFieldError < ::NoMethodError
      include Gorillib::Record::Error
    end

  end
end
