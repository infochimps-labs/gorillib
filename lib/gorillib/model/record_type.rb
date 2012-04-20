module Meta
  module Type

    # Provides a set of class methods for defining a field schema and instance
    # methods for reading and writing attributes.
    #
    # @example Usage
    #   class Person
    #     include Gorillib::Meta::RecordType
    #
    #     field :name,   String,  :doc => 'Full name of person'
    #     field :height, Float,   :doc => 'Height in meters'
    #   end
    #
    #   person      = Person.new
    #   person.name = "Bob Dobbs, Jr"
    #   puts person  #=> #<Person name="Bob Dobbs, Jr">
    #
    module RecordType

      extend Gorillib::Concern

      # Returns a Hash of all attributes
      #
      # @example Get attributes
      #   person.attributes # => { :name => "Ben Poweski" }
      #
      # @return [Hash{Symbol => Object}] The Hash of all attributes
      #
      # FIXME: should this be made to only include unset attributes? or to return UnsetNull for unset attributes?
      #
      def attributes
        self.class.field_names.inject({}) do |hsh, fn|
          hsh[fn] = read_attribute(fn) ; hsh
        end
      end

      # Read a value from the model's attributes.
      #
      # @example Reading an attribute
      #   person.read_attribute(:name)
      #
      # @param [String, Symbol, #to_s] fn The name of the attribute to get.
      #
      # @return [Object] The value of the attribute.
      #
      # @raise [UnknownAttributeError] if the attribute is unknown
      #
      def read_attribute(fn)
        if self.class.has_field?(fn)
          send(fn.to_s)
        else
          raise UnknownFieldError, "unknown field: #{fn}"
        end
      end

      # Write the value of a single attribute.
      #
      # @example Writing an attribute
      #   person.write_attribute(:name, "Benjamin")
      #
      # @param [String, Symbol, #to_s] fn The fn of the attribute to update.
      # @param [Object] value The value to set for the attribute.
      #
      # @raise [UnknownAttributeError] if the attribute is unknown
      #
      def write_attribute(fn, value)
        if self.class.has_field?(fn)
          send("#{fn}=", value)
        else
          raise UnknownAttributeError, "unknown attribute: #{fn}"
        end
      end

      def unset_attribute(fn)
        write_attribute(fn, nil)
      end

      def attribute_set?
        true
      end

      def attribute_default(fn)
        val = field.default
        case val
        when nil  then nil
        when Proc then (val.arity == 0) ? instance_exec(&val) : val.call(self, fn)
        else           val.try_dup
        end
      end

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
      def ==(other)
        return false unless other.instance_of?(self.class)
        attributes == other.attributes
      end

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

    protected

      module ClassMethods

        # Defines a new field
        #
        # For each field that is defined, a getter and setter will be added as
        # an instance method to the model. An Field instance will be added to
        # result of the fields class method.
        #
        # @example
        #   field :height, Integer
        #
        # @param [Symbol] fn                     -- The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]`
        # @param [Class]  type                   -- The field's type (required)
        # @option options [String] doc           -- Documentation string for the field (optional)
        # @option options [Proc, Object] default -- Default value, or proc that instance can evaluate to find default value
        #
        # @macro [attach] property
        #   @return [$2] the $1 property ($3)
        #
        # @raise [DangerousAttributeError] if the field name conflicts with
        #   existing methods
        #
        def field(fn, type, options={})
          field_def = ::Gorillib::Model::Field.new(fn, type, options)
          @_fields[field_def.name] = field_def
          define_field_methods(field_def)
          field_def
        end

        def fields
          fields = {}
          self.ancestors.reverse.each do |ancestor|
            next unless ancestor.instance_variable_defined?('@_fields')
            fields.merge! ancestor.instance_variable_get('@_fields')
          end
          fields
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

      protected

        def define_field_methods(field)
          ivar_name = "@#{field.name}"
          define_metamodel_method(field.name,            field.visibility(:read )){    instance_variable_get(ivar_name)    }
          define_metamodel_method("#{field.name}=",      field.visibility(:write)){|v| instance_variable_set(ivar_name, v) }
          define_metamodel_method("unset_#{field.name}", field.visibility(:unset)){    remove_instance_variable(ivar_name) }
        end

      private

        # assign fields to subclasses
        def inherited(subclass)
          super
          subclass.instance_variable_set('@_fields', {})
        end
      end

      included do
        extend Meta::Schema::NamedSchema
        @_fields = {}
      end
    end

  end
end
