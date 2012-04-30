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
      include Gorillib::Model::Conversion
      include ActiveModel::Validations

      # @return [false]
      def persisted?
        false
      end

      def attribute_method?(attr_name)
        self.class.has_field?(attr_name)
      end

      module ClassMethods
      end # ActiveModelShim::ClassMethods
    end # ActiveModelShim

  end
end
