
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
        hsh[fn] = read_attribute(fn)
        hsh
      end
    end

    def attribute_values
      self.class.field_names.map{|fn| read_attribute(fn) }
    end

    # Returns a Hash of all attributes *that have been set*
    #
    # @example Get attributes (smurfette is unarmed)
    #   smurfette.attributes         # => { :name => "Smurfette", :weapon => nil }
    #   smurfette.compact_attributes # => { :name => "Smurfette" }
    #
    # @return [{Symbol => Object}] The Hash of all *set* attributes
    def compact_attributes
      self.class.field_names.inject(Hash.new) do |hsh, fn|
        hsh[fn] = read_attribute(fn) if attribute_set?(fn)
        hsh
      end
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
      if hsh.respond_to?(:attributes)
        hsh = hsh.attributes
      else
        Gorillib::Model::Validate.hashlike!(hsh){ "attributes hash for #{self.inspect}" }
        hsh = hsh.dup
      end
      self.class.field_names.each do |field_name|
        if    hsh.has_key?(field_name)      then val = hsh.delete(field_name)
        elsif hsh.has_key?(field_name.to_s) then val = hsh.delete(field_name.to_s)
        else next ; end
        self.send("receive_#{field_name}", val)
      end
      handle_extra_attributes(hsh)
      self
    end

    def handle_extra_attributes(attrs)
      @extra_attributes ||= Hash.new
      @extra_attributes.merge!(attrs)
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
      Gorillib::Model::Validate.hashlike!(hsh){ "attributes hash for #{self.inspect}" }
      self.class.field_names.each do |field_name|
        if    hsh.has_key?(field_name)      then val = hsh[field_name]
        elsif hsh.has_key?(field_name.to_s) then val = hsh[field_name.to_s]
        else next ; end
        write_attribute(field_name, val)
      end
      self
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
      attr_name = "@#{field_name}"
      if instance_variable_defined?(attr_name)
        instance_variable_get(attr_name)
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
      instance_variable_defined?("@#{field_name}")
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

    # override inspect_helper (not this) in your descendant class
    # @return [String] Human-readable presentation of the attributes
    def inspect(detailed=true)
      inspect_helper(detailed, compact_attributes)
    end

    # assembles just the given attributes into the inspect string.
    # @return [String] Human-readable presentation of the attributes
    def inspect_helper(detailed, attrs)
      str = "#<" << self.class.name.to_s
      if detailed && attrs.present?
        str << " "
        str << attrs.map do |attr, val|
          "#{attr}=#{val.is_a?(Gorillib::Model) || val.is_a?(Gorillib::Collection) ? val.inspect(false) : val.inspect}"
        end.join(", ")
      end
      str << ">"
    end
    private :inspect_helper

  protected

    module ClassMethods

      def typename
        Gorillib::Inflector.underscore(self.name||'anon').gsub(%r{/}, '.')
      end

      #
      # Receive external data, type-converting and creating contained models as necessary
      #
      # @return [Gorillib::Model] the new object
      def receive(attrs={}, &block)
        return nil if attrs.nil?
        return attrs if attrs.is_a?(self)
        Gorillib::Model::Validate.hashlike!(attrs){ "attributes for #{self.inspect}" }
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

        #
        # fields.has_key?(field_name.to_sym)
        #

        fields.has_key?(field_name)
      end

      # @return [Array<Symbol>] The attribute names
      def field_names
        @_field_names ||= fields.keys
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
          klass.__send__(:remove_instance_variable, '@_fields')      if (klass <= self) && klass.instance_variable_defined?('@_fields')
          klass.__send__(:remove_instance_variable, '@_field_names') if (klass <= self) && klass.instance_variable_defined?('@_field_names')
        end
      end

      # define the reader method `#foo` for a field named `:foo`
      def define_attribute_reader(field_name, field_type, visibility)
        define_meta_module_method(field_name, visibility) do
          begin
            read_attribute(field_name)
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name}") rescue nil ; raise ; end
        end
      end

      # define the writer method `#foo=` for a field named `:foo`
      def define_attribute_writer(field_name, field_type, visibility)
        define_meta_module_method("#{field_name}=", visibility) do |val|
          write_attribute(field_name, val)
        end
      end

      # define the present method `#foo?` for a field named `:foo`
      def define_attribute_tester(field_name, field_type, visibility)
        field = fields[field_name]
        define_meta_module_method("#{field_name}?", visibility) do
          attribute_set?(field_name) || field.has_default?
        end
      end

      def define_attribute_receiver(field_name, field_type, visibility)
        define_meta_module_method("receive_#{field_name}", visibility) do |val|
          begin
            val = field_type.receive(val)
            write_attribute(field_name, val)
            self
          rescue StandardError => err ; err.polish("#{self.class}.#{field_name} type #{type} on #{val}") rescue nil ; raise ; end
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
