module Gorillib
  module Model

    #
    # Provides
    #
    module NamedSchema

      #
      # Returns the metamodel -- a module extending the type, on which all the
      # model methods are inscribed. This allows you to override the model methods
      # and call +super()+ to get the generic behavior.
      #
      # The metamodel is named for the including class, but with 'Meta::'
      # prepended and 'Type' appended -- so Geo::Place has metamodel
      # "Meta::Geo::PlaceType"
      #
      def metamodel
        return @metamodel if @metamodel
        @metamodel = ::Gorillib::Model::NamedSchema.get_nested_module("Meta::#{self.name}Type")
        self.class_eval{ include(@metamodel) }
        @metamodel
      end

      #
      # QUESTION: should visibility=false *remove* the method from the metamodel?
      def define_metamodel_method(method_name, visibility=:public, clobber=false, &block)
        if (visibility == false) then return               ; end
        if (visibility == true)  then visibility = :public ; end
        return if (not clobber) && instance_method_already_implemented?(method_name)
        Validate.included_in!("visibility", visibility, [:public, :private, :protected])
        metamodel.module_eval{ define_method(method_name, &block) }
        metamodel.module_eval "#{visibility} :#{method_name}", __FILE__, __LINE__
      end

    protected

      # Returns a module for the given names, rooted at Object (so
      # implicity with '::').
      # @example
      #   get_nested_module(["This", "That", "TheOther"])
      #   # This::That::TheOther
      def self.get_nested_module(name)
        name.split('::').inject(Object) do |parent_module, module_name|
          # inherit = false makes these methods be scoped to parent_module instead of universally
          if parent_module.const_defined?(module_name, false)
            parent_module.const_get(module_name, false)
          else
            parent_module.const_set(module_name.to_sym, Module.new)
          end
        end
      end

      # Overrides ActiveModel::AttributeMethods
      # @private
      def instance_method_already_implemented?(method_name)
        warn "The field named '#{method_name}' overrides an existing method" if self.allocate.respond_to?(method_name, true)
      end

    end
  end
end
