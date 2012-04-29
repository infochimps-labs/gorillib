require 'gorillib'
require 'gorillib/hash/keys'
require 'gorillib/hash/slice'
require 'gorillib/object/try'
require 'gorillib/array/compact_blank'
require 'gorillib/logger/log'

module Gorillib

  # Provides a set of class methods for defining a field schema and instance
  # methods for reading and writing attributes.
  #
  # @example Usage
  #   class Person
  #     include Gorillib::Record
  #
  #     field :name,   String,  :doc => 'Full name of person'
  #     field :height, Float,   :doc => 'Height in meters'
  #   end
  #
  #   person      = Person.new
  #   person.name = "Bob Dobbs, Jr"
  #   puts person  #=> #<Person name="Bob Dobbs, Jr">
  #
  module Record

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
    # @param [String, Symbol, #to_s] field_name Name of the attribute to get.
    #
    # @return [Object] The value of the attribute.
    #
    # @raise [UnknownAttributeError] if the attribute is unknown
    #
    def read_attribute(field_name)
      check_field(field_name)
      instance_variable_get("@#{field_name}")
    end

    # Write the value of a single attribute.
    #
    # @example Writing an attribute
    #   person.write_attribute(:name, "Benjamin")
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to update.
    # @param [Object] value The value to set for the attribute.
    #
    # @raise [UnknownAttributeError] if the attribute is unknown
    #
    def write_attribute(field_name, value)
      check_field(field_name)
      instance_variable_set("@#{field_name}", value)
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
    def unset_attribute(field_name)
      check_field(field_name)
      remove_instance_variable("@#{field_name}")
    end

    # True if the attribute is set.
    #
    # Note that an attribute can have the value nil but be set.
    #
    # @param [String, Symbol, #to_s] field_name Name of the attribute to check.
    #
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
    # or some such. Use `#update!` if your data is already type safe.
    #
    # @return [Gorillib::Record] the object itself
    def receive!(hsh={})
      if hsh.respond_to?(:attributes) then hsh = hsh.attributes ; end
      Gorillib::Model::Validate.hashlike!("attributes hash", hsh)
      self.class.fields.each do |attr, field|
        if    hsh.has_key?(attr)      then val = hsh[attr]
        elsif hsh.has_key?(attr.to_s) then val = hsh[attr.to_s]
        else next ; end
        self.send(:"receive_#{attr}", val)
      end
      self
    end

    #
    # Accept the given attributes, adopting each value directly.
    #
    # Use `#receive!` to accept 'dirty' data -- from JSON, from a nested hash,
    # or some such. Use `#update!` if your data is already type safe.
    #
    # @return [Gorillib::Record] the object itself
    def update!(hsh={})
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

    # @return [String] Human-readable presentation of the attributes
    def inspect
      str = "#<" << self.class.name
      str << " " << attributes.map{|attr, val| "#{attr}:#{attribute_set?(attr) ? val.inspect : '~'}" }.join(", ") if attributes.present?
      str << ">"
      str
    end

  protected

    # @return [true] if the field exists
    # @raise [UnknownFieldError] if the field is missing 
    def check_field(field_name)
      return true if self.class.has_field?(field_name)
      raise UnknownFieldError, "unknown field: #{field_name}" 
    end

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
      # @param [Symbol] field_name             The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]`
      # @param [Class]  type                   The field's type (required)
      # @option options [String] doc           Documentation string for the field (optional)
      # @option options [Proc, Object] default Default value, or proc that instance can evaluate to find default value
      #
      # @return Gorillib::Model::Field
      def field(field_name, type, options={})
        options = options.symbolize_keys
        fld = ::Gorillib::Model::Field.new(field_name, type, self, options)
        @_own_fields[fld.name] = fld
        _reset_descendant_fields
        fld.send(:inscribe_methods, self)
        fld
      end

      # @return [Hash<Symbol, Gorillib::Model::Field>]
      def fields
        return @_fields if @_fields
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
        "#{self.name}[#{ field_names.join(", ") }]"
      end

    protected

      attr_reader :_own_fields

      # Ensure that classes inherit all their parents' fields, even if fields
      # are added after the child class is defined.
      def _reset_descendant_fields
        ObjectSpace.each_object(::Class) do |klass|
          klass.send(:remove_instance_variable, '@_fields') if klass <= self && klass.instance_variable_defined?('@_fields')
        end
      end
      
      def inherited(base)
        base.instance_eval do
          @_own_fields ||= {}
        end
        super
      end
    end

    def self.included(base)
      base.instance_eval do
        extend Gorillib::Model::NamedSchema
        extend Gorillib::Record::ClassMethods
        @_own_fields ||= {}
      end
      super
    end

  end
end
