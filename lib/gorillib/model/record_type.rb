module Gorillib
  module RecordType

    # Provides a set of class methods for defining a field schema and instance
    # methods for reading and writing attributes.
    #
    # @example Usage
    #   class Person
    #     include Gorillib::Meta::RecordType
    #     field :name, String, :doc => 'Full name of person'
    #   end
    #
    #   person = Person.new
    #   person.name = "Bob Dobbs, Jr"
    #
    module Attributes
      extend ActiveSupport::Concern

      # Two records are equal if they have the same class and their attributes
      # are equal.
      #
      # @example Compare for equality.
      #   model == other
      #
      # @param [ActiveAttr::Attributes, Object] other The other model to compare
      #
      # @return [true, false] True if attributes are equal and other is instance
      #   of the same Class, false if not.
      #
      # @since 0.2.0
      def ==(other)
        return false unless other.instance_of? self.class
        attributes == other.attributes
      end

      # Returns a Hash of all attributes
      #
      # @example Get attributes
      #   person.attributes # => { :name => "Ben Poweski" }
      #
      # @return [Hash{Symbol => Object}] The Hash of all attributes
      #
      def attributes
        Hash[ self.class.field_names.map{|key| [key, read_attribute(key)] } ]
      end
      alias_method :to_hash, :attributes

      # Returns the class name plus its attributes
      #
      # @return [String] Human-readable presentation of the attributes
      #
      def inspect
        str = "#<" << self.class.name
        str << " " unless attribute_descriptions.empty?
        str << attributes.map{|attr, val| "#{attr}: #{value.inspect}" }.join(", ")
        str << ">"
        str
      end

      # Read a value from the model's attributes.
      #
      # @example Read an attribute with read_attribute
      #   person.read_attribute(:name)
      # @example Read an attribute with bracket syntax
      #   person[:name]
      #
      # @param [String, Symbol, #to_s] name The name of the attribute to get.
      #
      # @return [Object] The value of the attribute.
      #
      # @raise [UnknownAttributeError] if the attribute is unknown
      #
      def read_attribute(name)
        if self.class.has_field?(name)
          send(name.to_s)
        else
          raise UnknownFieldError, "unknown field: #{name}"
        end
      end
      alias_method :[], :read_attribute

      # Write the value of a single attribute
      #
      # @example Write the attribute with write_attribute
      #   person.write_attribute(:name, "Benjamin")
      # @example Write an attribute with bracket syntax
      #   person[:name] = "Benjamin"
      #
      # @param [String, Symbol, #to_s] name The name of the attribute to update.
      # @param [Object] value The value to set for the attribute.
      #
      # @raise [UnknownAttributeError] if the attribute is unknown
      #
      # @since 0.2.0
      def write_attribute(name, value)
        if self.class.has_field?(name)
          send("#{name}=", value)
        else
          raise UnknownAttributeError, "unknown attribute: #{name}"
        end
      end
      alias_method :[]=, :write_attribute

    protected

      # Overrides ActiveModel::AttributeMethods
      # @private
      def attribute_method?(attr_name)
        self.class.has_field?(attr_name)
      end

      module ClassMethods
        included do
          class_attribute :fields unless self.respond_to?(:fields)
          self.fields ||= Hash.new
        end

        # Defines an field
        #
        # For each field that is defined, a getter and setter will be added as
        # an instance method to the model. An Field instance will be added to
        # result of the fields class method.
        #
        # @example
        #   field :height, Integer
        #
        # @param [Symbol] name                   -- The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]`
        # @param [Class]  type                   -- The field's type (required)
        # @option options [String] doc           -- Documentation string for the field (optional)
        # @option options [Proc, Object] default -- Default value, or proc that instance can evaluate to find default value
        #
        # @raise [DangerousAttributeError] if the attribute name conflicts with
        #   existing methods
        #
        def field(name, type, options={})
          field_def = Gorillib::Model::Field.new(name, type, options)
          fields[field_def.name] = field_def
          define_field_methods(field_def)
          field_def
        end

        # Array of field names as Symbols
        #
        # @return [Array<String>] The attribute names
        def field_names
          fields.keys
        end

        # Returns the class name plus its attribute names
        #
        # @example Inspect the model's definition.
        #   Person.inspect #=> Person[first_name, last_name]
        def inspect
          "#{self.name}[#{ field_names.join(", ") }]"
        end

        # def meta_module
        #   "Meta::Type::#{self.name}Type"
        # end
        #
        # def meta_module_method(name, &block)
        # end
        #
        # def define_field_methods(field)
        #   meta_module_method("receive_#{field}") do
        #
        #   end
        #   meta_module.module_eval{ attr_accessor(field.name) }
        # end

      protected

        # Methods deprecated on the Object class which can be safely overridden
        DEPRECATED_OBJECT_METHODS = %w[ id type ]

        # Overrides ActiveModel::AttributeMethods
        # @private
        def instance_method_already_implemented?(method_name)
          deprecated_object_method = DEPRECATED_OBJECT_METHODS.include?(method_name.to_s)
          already_implemented = !deprecated_object_method && self.allocate.respond_to?(method_name, true)
          raise DangerousAttributeError, %Q{An attribute method named "#{method_name}" would conflict with an existing method} if already_implemented
          false
        end

      private

        # assign fields to subclasses
        #
        # FIXME: can't add fields to superclass after subclass was made
        def inherited(subclass)
          super
          subclass.fields = fields.dup
        end
      end
    end

  end
end
