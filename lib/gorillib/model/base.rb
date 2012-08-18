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
        hsh = hsh.attributes
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
      @_extra_attributes ||= Hash.new
      @_extra_attributes.merge!(attrs)
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

      # @return Class name and its attributes
      #
      # @example Inspect the model's definition.
      #   Person.inspect #=> Person[first_name, last_name]
      def inspect
        "#{self.name || 'anon'}[#{ field_names.join(",") }]"
      end
      def inspect_compact() self.name || inspect ; end

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
