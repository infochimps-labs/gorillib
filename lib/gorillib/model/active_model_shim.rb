require "active_model"

module Gorillib
  module Model

    # Provides the minimum functionality to pass the ActiveModel lint tests
    #
    # @example Usage
    #   class Person
    #     include Gorillib::Model::ActiveModelShim
    #   end
    #
    module ActiveModelShim
      extend  Gorillib::Concern
      extend  ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations

      # @return [false]
      def persisted?
        false
      end
    end

  end
end
