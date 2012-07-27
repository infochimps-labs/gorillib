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

    def initialize(*args, &block)
      attrs = self.class.attrs_hash_from_args(args)
      receive!(attrs, &block)
    end

    # Returns a Hash of all attributes
    #
    # @example Get attributes
    #   person.attributes # => { :name => "Emmet Brown", :title => "Dr" }
    #
    # @return [{Symbol => Object}] The Hash of all attributes
    def attributes
      self.class.field_names.inject(Hash.new) do |hsh, fn|
        hsh[fn] = read_attribute(fn)
        hsh
      end
    end

    # @return [Array[Object]] all the attributes, in field order, with `nil` where unset
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
    # @return [nil] nothing
    def receive!(hsh={})
      if hsh.respond_to?(:attributes)
        hsh = hsh.compact_attributes
      else
        Gorillib::Model::Validate.hashlike!(hsh){ "attributes for #{self.inspect}" }
        hsh = hsh.dup
      end
      self.class.field_names.each do |field_name|
        if    hsh.has_key?(field_name)      then val = hsh.delete(field_name)
        elsif hsh.has_key?(field_name.to_s) then val = hsh.delete(field_name.to_s)
        else next ; end
        self.send("receive_#{field_name}", val)
      end
      handle_extra_attributes(hsh)
      nil
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
      Gorillib::Model::Validate.hashlike!(hsh){ "attributes for #{self.inspect}" }
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

    # override to_inspectable (not this) in your descendant class
    # @return [String] Human-readable presentation of the attributes
    def inspect
      str = '#<' << self.class.name.to_s
      attrs = to_inspectable
      if attrs.present?
        str << '(' << attrs.map{|attr, val| "#{attr}=#{val.respond_to?(:inspect_compact) ? val.inspect_compact : val.inspect}" }.join(", ") << ')'
      end
      str << '>'
    end

    def inspect_compact
      str = "#<#{self.class.name.to_s}>"
    end

    # assembles just the given attributes into the inspect string.
    # @return [String] Human-readable presentation of the attributes
    def to_inspectable
      compact_attributes
    end
    private :to_inspectable

  protected

    module ClassMethods

      #
      # A readable handle for this field
      #
      def typename
        @typename ||= Gorillib::Inflector.underscore(self.name||'anon').gsub(%r{/}, '.')
      end

      #
      # Receive external data, type-converting and creating contained models as necessary
      #
      # @return [Gorillib::Model] the new object
      def receive(attrs={}, &block)
        return nil if attrs.nil?
        return attrs if native?(attrs)
        #
        Gorillib::Model::Validate.hashlike!(attrs){ "attributes for #{self.inspect}" }
        klass = attrs.has_key?(:_type) ? Gorillib::Factory(attrs[:_type]) : self
        warn "factory #{klass} is not a type of #{self} as specified in #{attrs}" unless klass <= self
        #
        klass.new(attrs, &block)
      end

      # A `native` object does not need any transformation; it is accepted directly.
      # By default, an object is native if it `is_a?` this class
      #
      # @param  obj [Object] the object that will be received
      # @return [true, false] true if the item does not need conversion
      def native?(obj)
        obj.is_a?(self)
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
        fields.has_key?(field_name)
      end

      # @return [Array<Symbol>] The attribute names
      def field_names
        @_field_names ||= fields.keys
      end

      def positionals
        @_positionals ||= assemble_positionals
      end

      def assemble_positionals
        positionals = fields.values.keep_if{|fld| fld.position? }.sort_by!{|fld| fld.position }
        return [] if positionals.empty?
        if (positionals.map(&:position) != (0..positionals.length-1).to_a) then raise ConflictingPositionError, "field positions #{positionals.map(&:position).join(",")} for #{positionals.map(&:name).join(",")} aren't in strict minimal order"  ; end
        positionals.map!(&:name)
      end

      # turn model constructor args (`*positional_args, {attrs}`) into a combined
      # attrs hash. positional_args are mapped to the set of attribute names in
      # order -- by default, the class' field names.
      #
      # Notes:
      #
      # * Positional args always clobber elements of the attribute hash.
      # * Nil positional args are treated as present-and-nil (this might change).
      # * Raises an error if positional args
      #
      # @param [Array[Symbol]] attr_names list of attributes, in order, to map.
      #
      # @return [Hash] a combined, reconciled hash of attributes to set
      def attrs_hash_from_args(args)
        attrs = args.extract_options!
        if args.present?
          ArgumentError.check_arity!(args, 0..positionals.length){ "extracting args #{args} for #{self}" }
          positionals_to_map = positionals[0..(args.length-1)]
          attrs = attrs.merge(Hash[positionals_to_map.zip(args)])
        end
        attrs
      end

      # @return Class name and its attributes
      #
      # @example Inspect the model's definition.
      #   Person.inspect #=> Person[first_name, last_name]
      def inspect
        "#{self.name || 'anon'}[#{ field_names.join(",") }]"
      end
      def inspect_compact() self.name || inspect ; end


    protected

      attr_reader :_own_fields

      # Ensure that classes inherit all their parents' fields, even if fields
      # are added after the child class is defined.
      def _reset_descendant_fields
        ObjectSpace.each_object(::Class) do |klass|
          klass.__send__(:remove_instance_variable, '@_fields')      if (klass <= self) && klass.instance_variable_defined?('@_fields')
          klass.__send__(:remove_instance_variable, '@_field_names') if (klass <= self) && klass.instance_variable_defined?('@_field_names')
          klass.__send__(:remove_instance_variable, '@_positionals') if (klass <= self) && klass.instance_variable_defined?('@_positionals')
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
