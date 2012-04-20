module Gorillib
  module Model
    # Represents a field for reflection
    #
    # @example Usage
    #   Gorillib::Model::Field.new(:name => 'problems', type => Integer, :doc => 'Count of problems')
    class Field
      remove_possible_method(:type)

      class_attribute :allowed_attr_names
      self.allowed_attr_names = [:doc, :default, :reader, :writer, :unsetter]

      # [Gorillib::Model]    Model owning this field
      attr_reader   :model
      # [Symbol]             The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]` (required)
      attr_reader   :name
      # [Class]              The field's type (required)
      attr_reader   :type
      # [String]             Documentation string for the field (optional)
      attr_accessor :doc
      # [Proc, Object]       Default value, or proc that instance can evaluate to find default value
      attr_accessor :default

      # * aliases
      # * order
      # * dirty
      # * lazy
      # * mass assignable
      # * identifier / index
      # * hook
      # * validates / required
      #   - presence     => true
      #   - uniqueness   => true
      #   - numericality => true             # also :==, :>, :>=, :<, :<=, :odd?, :even?, :equal_to, :less_than, etc
      #   - length       => { :<  => 7 }     # also :==, :>=, :<=, :is, :minimum, :maximum
      #   - format       => { :with => /.*/ }
      #   - inclusion    => { :in => [1,2,3] }
      #   - exclusion    => { :in => [1,2,3] }

      def initialize(name, type, model, hsh={})
        Valid.validate_name!(name)
        @model   = model
        @name    = name.to_sym
        @type    = type
        receive!(hsh)
      end

      def receive!(hsh)
        @options.merge!(hsh)
        self.doc     = @options[:doc]
        self.default = @options[:default]
      end

      def to_hash
        @options
      end

      # __________________________________________________________________________

      def doc
        @doc || "#{name} attribute"
      end

      INSCRIBED_METHOD_TYPES = [:read, :write, :unset]

      def visibility(meth_type)
        raise ArgumentError, "method type must be one of #{INSCRIBED_METHOD_TYPES.join(', ')}" unless INSCRIBED_METHOD_TYPES.include?(meth_type)
        case @options[meth_type]
        when true  then :public
        when nil   then :public
        when false then :none
        else            @options[meth_type]
        end
      end

      # The field name
      # @return [String] the field name
      def to_s
        name.to_s
      end

      # Returns the code that would generate the field definition
      #
      # @example Inspect the field definition
      #   field.inspect
      #
      # @return [String] Human-readable presentation of the field
      #   definition
      #
      # @since 0.6.0
      def inspect
        args = [name.inspect, type.to_s, to_hash.map{|key, val| "#{key.inspect} => #{val.inspect}" }].reject(&:blank?)
        "field(#{args.join(", ")})"
      end

    protected

      module Valid
        VALID_NAME_RE = /\A[A-Za-z_][A-Za-z0-9_]+\z/
        def self.validate_name!(name)
          raise TypeError,     "can't convert #{name.class} into Symbol" unless name.respond_to? :to_sym
          raise ArgumentError, "Name must start with [A-Za-z_] and subsequently contain only [A-Za-z0-9_]" unless name =~ VALID_NAME_RE
        end
      end

    end
  end
end
