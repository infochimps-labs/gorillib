module Gorillib
  module Model

    # All exceptions defined by Gorillib::Model include this module.
    module Error
    end

    # Exception raised if attempting to assign unknown fields
    class UnknownFieldError < ::NoMethodError
      include Gorillib::Model::Error
    end

    # Exception raised if attempting to define an field whose name conflicts
    # with methods that are already defined
    class DangerousFieldError < ::ScriptError
      include Gorillib::Model::Error
    end

  end
end
