module Meta
  module Schema

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
        @metamodel = Meta::Schema::NamedSchema.get_nested_module("Meta::#{self.name}Type")
        self.class_eval{ include(@metamodel) }
        @metamodel
      end

    protected

      ALLOWED_VISIBILITIES = [:public, :private, :protected].freeze

      # OPTIMIZE: apparently `define_method(:foo){ ... }` is slower than `def foo() ... end`
      def define_metamodel_method(method_name, visibility=:public, &block)
        return if visibility == :none || visibility == false
        raise ArgumentError, "Visibility must be one of #{ ALLOWED_VISIBILITIES.join(', ') }, got '#{ visibility }'" unless ALLOWED_VISIBILITIES.include?(visibility)
        instance_method_already_implemented?(method_name)
        metamodel.module_eval{ define_method(method_name, &block) }
        metamodel.module_eval "#{visibility} :#{method_name}", __FILE__, __LINE__
      end

      # These methods are deprecated on the Object class and so can be safely overridden
      DEPRECATED_OBJECT_METHODS = %w[ id type ]

      # Overrides ActiveModel::AttributeMethods
      # @private
      def instance_method_already_implemented?(method_name)
        deprecated_object_method = DEPRECATED_OBJECT_METHODS.include?(method_name.to_s)
        already_implemented = (not deprecated_object_method) && self.allocate.respond_to?(method_name, true)
        raise ::Gorillib::Model::DangerousFieldError, "A field named '#{method_name}' would conflict with an existing method" if already_implemented
        false
      end

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

    end
  end
end
