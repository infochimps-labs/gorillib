module Gorillib
  module Model
    # Represents a field for reflection
    #
    # @example Usage
    #   Gorillib::Model::Field.new(:name => 'problems', type => Integer, :doc => 'Count of problems')
    class Field
      remove_possible_method(:type)

      # [Gorillib::Model] Model owning this field
      attr_reader :model
      # [Symbol] The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]` (required)
      attr_reader :name
      # [Class] The field's type (required)
      attr_reader :type
      # [String] Documentation string for the field (optional)
      attr_accessor :doc
      # [Proc, Object] Default value, or proc that instance can evaluate to find default value
      attr_accessor :default

      def initialize(name, type, model, hsh={})
        Valid.validate_name!(name)
        @model   = model
        @name    = name.to_sym
        @type    = type
        @options = Mash.new
        receive!(hsh)
      end

      def receive!(hsh)
        @options.merge!(hsh)
        @doc     = @options[:doc]
        @default = @options[:default]
      end

      # Compare field definitions
      #
      # @example
      #   field_a <=> field_b
      #
      # @param [Gorillib::Model::Field, Object] other The other
      #   field definition to compare with.
      #
      # @return [-1, 0, 1, nil]
      def <=>(other)
        return nil unless other.is_a?(Gorillib::Model::Field)
        return nil if name == other.name && to_hash != other.to_hash
        self.name.to_s <=> other.name.to_s
      end

      def [](key)
        @options[key.to_sym]
      end

      # The field name
      # @return [String] the field name
      def to_s
        name.to_s
      end

      # The field name
      # @return [Symbol] the field name
      def to_sym
        name
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
        args = [name.inspect, type.to_s, to_hash.map{|key, val| "#{key.inspect} => #{val.inspect}" }.sort]
        "field #{args.join(", ")}"
      end

    protected

      # The field's options
      attr_reader :options

      module Valid
        VALID_NAME_RE = /\A[A-Za-z_][A-Za-z0-9_]+\z/
        def validate_name!(name)
          raise TypeError,     "can't convert #{name.class} into Symbol" unless name.respond_to? :to_sym
          raise ArgumentError, "Name must start with [A-Za-z_] and subsequently contain only [A-Za-z0-9_]" unless name =~ VALID_NAME_RE
        end
      end
      
    end
  end
end
