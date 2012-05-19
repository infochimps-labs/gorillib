require 'set'
require 'gorillib/object/blank'
require 'gorillib/object/try'
require 'gorillib/object/try_dup'
require 'gorillib/array/extract_options'
require 'gorillib/hash/keys'
require 'gorillib/hash/slice'
require 'gorillib/string/inflector'
require 'gorillib/exception/raisers'
require 'gorillib/metaprogramming/concern'
require 'gorillib/metaprogramming/class_attribute'
#
require 'gorillib/collection'
require 'gorillib/model/factories'
require 'gorillib/model/named_schema'
require 'gorillib/model/validate'
require 'gorillib/model/errors'

module Gorillib

  # Provides a set of class methods for defining a field schema and instance
  # methods for reading and writing attributes.
  #
  # @example Usage
  #   class Person
  #     include Gorillib::Model
  #
  #     field :name,   String,  :doc => 'Full name of person'
  #     field :height, Float,   :doc => 'Height in meters'
  #   end
  #
  #   person      = Person.new
  #   person.name = "Bob Dobbs, Jr"
  #   puts person  #=> #<Person name="Bob Dobbs, Jr">
  #
  module Model
    extend Gorillib::Concern

    # Returns a Hash of all attributes
    #
    # @example Get attributes
    #   person.attributes # => { :name => "Ben Poweski" }
    #
    # @return [{Symbol => Object}] The Hash of all attributes
    def attributes
      self.class.field_names.inject(Hash.new) do |hsh, fn|
        hsh[fn] = read_attribute(fn) ; hsh
      end
    end

    # Read a value from the model's attributes.
    #
    # @example Reading an attribute
    #   person.read_attribute(:name)
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to get.
    #
    # @raise [UnknownAttributeError] if the attribute is unknown
    # @return [Object] The value of the attribute, or nil if it is unset
    def read_attribute(field_name)
      check_field(field_name)
      if instance_variable_defined?("@#{field_name}")
        instance_variable_get("@#{field_name}")
      else
        read_unset_attribute(field_name)
      end
    end

    # Write the value of a single attribute.
    #
    # @example Writing an attribute
    #   person.write_attribute(:name, "Benjamin")
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to update.
    # @param [Object] val The value to set for the attribute.
    #
    # @raise [UnknownAttributeError] if the attribute is unknown
    # @return [Object] the attribute's value
    def write_attribute(field_name, val)
      check_field(field_name)
      instance_variable_set("@#{field_name}", val)
    end

    # Unset an attribute. Subsequent reads of the attribute will return `nil`,
    # and `attribute_set?` for that field will return false.
    #
    # @example Unsetting an attribute
    #   obj.write_attribute(:foo, nil)
    #   [ obj.read_attribute(:foo), obj.attribute_set?(:foo) ] # => [ nil, true ]
    #   person.unset_attribute(:height)
    #   [ obj.read_attribute(:foo), obj.attribute_set?(:foo) ] # => [ nil, false ]
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to unset.
    #
    # @raise [UnknownAttributeError] if the attribute is unknown
    # @return [Object] the former value if it was set, nil if it was unset
    def unset_attribute(field_name)
      check_field(field_name)
      if instance_variable_defined?("@#{field_name}")
        val = instance_variable_get("@#{field_name}")
        remove_instance_variable("@#{field_name}")
        return val
      else
        return nil
      end
    end

    # True if the attribute is set.
    #
    # Note that an attribute can have the value nil but be set.
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to check.
    #
    # @raise [UnknownAttributeError] if the attribute is unknown
    # @return [true, false]
    def attribute_set?(field_name)
      check_field(field_name)
      instance_variable_defined?("@#{field_name}")
    end

    #
    # Accept the given attributes, converting each value to the appropriate
    # type, constructing included models and collections, and other triggers as
    # defined.
    #
    # Use `#receive!` to accept 'dirty' data -- from JSON, from a nested hash,
    # or some such. Use `#update_attributes` if your data is already type safe.
    #
    # @param [{Symbol => Object}] hsh The values to receive
    # @return [Gorillib::Model] the object itself
    def receive!(hsh={})
      if hsh.respond_to?(:attributes) then hsh = hsh.attributes ; end
      Gorillib::Model::Validate.hashlike!("attributes hash for #{self}", hsh)
      hsh = hsh.symbolize_keys
      self.class.fields.each do |field_name, field|
        next unless hsh.has_key?(field_name)
        self.public_send(:"receive_#{field_name}", hsh[field_name])
      end
      @extra_attributes ||= Hash.new
      @extra_attributes.merge!( hsh.reject{|field_name,val| self.class.has_field?(field_name) } )
      self
    end

    #
    # Accept the given attributes, adopting each value directly.
    #
    # Use `#receive!` to accept 'dirty' data -- from JSON, from a nested hash,
    # or some such. Use `#update_attributes` if your data is already type safe.
    #
    # @param [{Symbol => Object}] hsh The values to update with
    # @return [Gorillib::Model] the object itself
    def update_attributes(hsh)
      if hsh.respond_to?(:attributes) then hsh = hsh.attributes ; end
      Gorillib::Model::Validate.hashlike!("attributes hash", hsh)
      self.class.fields.each do |attr, field|
        if    hsh.has_key?(attr)      then val = hsh[attr]
        elsif hsh.has_key?(attr.to_s) then val = hsh[attr.to_s]
        else next ; end
        write_attribute(attr, val)
      end
      self
    end

    # Two models are equal if they have the same class and their attributes
    # are equal.
    #
    # @example Compare for equality.
    #   model == other
    #
    # @param [Gorillib::Model, Object] other The other model to compare
    #
    # @return [true, false] True if attributes are equal and other is instance of the same Class
    def ==(other)
      return false unless other.instance_of?(self.class)
      attributes == other.attributes
    end

    # @return [String] Human-readable presentation of the attributes
    def inspect(show_attrs=true)
      str = "#<" << self.class.name.to_s
      if show_attrs && (attr_names = self.class.field_names).present?
        str << " " << attr_names.map{|attr| "#{attr}=#{inspect_attr(attr)}" }.join(", ")
      end
      str << ">"
      str
    end

    def inspect_attr(attr)
      return '~' if not attribute_set?(attr)
      val = read_attribute(attr)
      val.is_a?(Gorillib::Model) || val.is_a?(Gorillib::Collection) ? val.inspect(false) : val.inspect
    end

  protected

    # @return [true] if the field exists
    # @raise [UnknownFieldError] if the field is missing
    def check_field(field_name)
      return true if self.class.has_field?(field_name)
      raise UnknownFieldError, "unknown field: #{field_name}"
    end

    module ClassMethods

      def typename
        Gorillib::Inflector.underscore(self.name).gsub(%r{/}, '.')
      end

      #
      # Receive external data, type-converting and creating contained models as necessary
      #
      # @return [Gorillib::Model] the new object
      def receive(attrs={}, &block)
        return nil if attrs.nil?
        return attrs if attrs.is_a?(self)
        klass = attrs.has_key?(:_type) ? Gorillib::Factory(attrs[:_type]) : self
        warn "factory #{self} doesn't match type specified in #{attrs}" unless klass <= self
        obj = klass.new
        obj.receive!(attrs, &block)
        obj
      end

      # Defines a new field
      #
      # For each field that is defined, a getter and setter will be added as
      # an instance method to the model. An Field instance will be added to
      # result of the fields class method.
      #
      # @example
      #   field :height, Integer
      #
      # @param [Symbol] field_name             The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]`
      # @param [Class]  type                   The field's type (required)
      # @option options [String] doc           Documentation string for the field (optional)
      # @option options [Proc, Object] default Default value, or proc that instance can evaluate to find default value
      #
      # @return Gorillib::Model::Field
      def field(field_name, type, options={})
        options = options.symbolize_keys
        field_type = options.delete(:field_type){ ::Gorillib::Model::Field }
        fld = field_type.new(field_name, type, self, options)
        @_own_fields[fld.name] = fld
        _reset_descendant_fields
        fld.send(:inscribe_methods, self)
        fld
      end

      # @return [{Symbol => Gorillib::Model::Field}]
      def fields
        return @_fields if defined?(@_fields)
        @_fields = ancestors.reverse.inject({}){|acc, ancestor| acc.merge!(ancestor.try(:_own_fields) || {}) }
      end

      # @return [true, false] true if the field is defined on this class
      def has_field?(field_name)
        fields.has_key?(field_name.to_sym)
      end

      # @return [Array<Symbol>] The attribute names
      def field_names
        fields.keys
      end

      # @return Class name and its attributes
      #
      # @example Inspect the model's definition.
      #   Person.inspect #=> Person[first_name, last_name]
      def inspect
        "#{self.name || 'anon'}[#{ field_names.join(", ") }]"
      end

    protected

      attr_reader :_own_fields

      # Ensure that classes inherit all their parents' fields, even if fields
      # are added after the child class is defined.
      def _reset_descendant_fields
        ObjectSpace.each_object(::Class) do |klass|
          klass.__send__(:remove_instance_variable, '@_fields') if klass <= self && klass.instance_variable_defined?('@_fields')
        end
      end

      def define_attribute_reader(field)
        field_name = field.name
        define_meta_module_method(field_name, field.visibility(:reader)) do
          read_attribute(field_name)
        end
      end

      def define_attribute_writer(field)
        field_name = field.name
        define_meta_module_method("#{field_name}=", field.visibility(:writer)) do |val|
          write_attribute(field_name, val)
        end
      end

      def define_attribute_tester(field)
        field_name = field.name
        define_meta_module_method("#{field_name}?", field.visibility(:tester)) do
          attribute_set?(field_name)
        end
      end

      def define_attribute_receiver(field)
        field_name = field.name
        type       = field.type
        define_meta_module_method("receive_#{field_name}", field.visibility(:receiver)) do |val|
          val = type.receive(val)
          write_attribute(field_name, val)
          self
        end
      end

      def inherited(base)
        base.instance_eval do
          @_own_fields ||= {}
        end
        super
      end
    end

    self.included do |base|
      base.instance_eval do
        extend Gorillib::Model::NamedSchema
        extend Gorillib::Model::ClassMethods
        @_own_fields ||= {}
      end
    end

  end
end
