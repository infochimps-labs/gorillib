module Gorillib
  module Model

    # Represents a field for reflection
    #
    # @example Usage
    #   Gorillib::Model::Field.new(:name => 'problems', type => Integer, :doc => 'Count of problems')
    #
    #
    class Field
      include Gorillib::Record
      remove_possible_method(:type)

      # [Gorillib::Model] Model owning this field
      attr_reader :model

      # [Hash] extended options
      attr_reader :extended_options

      # Note: `Gorillib::Model::Field` is assembled in two pieces, so that it
      # can behave as a record itself. This, and some fudge defined in
      # #initialize, define enough of the functionality to make it work.

      attr_reader :name

      # @param [#to_sym] name Field name
      # @param [#receive] type Factory for field values
      # @param [Gorillib::Record] model Field's owner
      # @param [Hash] options Extended attributes
      # @option options [String] doc Description of the field's purpose
      # @option options [true, false, :public, :protected, :private] :reader   Visibility for the reader (`#foo`) method; `false` means don't create one.
      # @option options [true, false, :public, :protected, :private] :writer   Visibility for the writer (`#foo=`) method; `false` means don't create one.
      # @option options [true, false, :public, :protected, :private] :receiver Visibility for the receiver (`#receive_foo`) method; `false` means don't create one.
      #
      def initialize(name, type, model, options={})
        Validate.identifier!(name)
        @model            = model
        @name             = name.to_sym
        @type             = type
        @visibility       = options.extract!(:reader, :writer, :receiver)
        receive!(options)
        @doc            ||= "#{name} field"
        @extended_options = options.slice!(self.class.field_names)
      end

      # __________________________________________________________________________

      # @return [String] the field name
      def to_s
        name.to_s
      end

      # @return [String] Human-readable presentation of the field definition
      def inspect
        args = [name.inspect, type.to_s] # , attributes.compact.map{|key, val| "#{key.inspect} => #{val.inspect}" }]
        "field(#{args.join(", ")})"
      end

      def to_hash
        attributes.merge!(@visibility).merge!(@extended_options)
      end

      def ==(val)
        super && (val.extended_options == self.extended_options) && (val.model == self.model)
      end

      def self.receive(hsh)
        name  = hsh.fetch(:name)
        type  = hsh.fetch(:type)
        model = hsh.fetch(:model)
        new(name, type, model, hsh)
      end

    protected

      #
      #
      #
      def inscribe_methods(record)
        fn = self.name
        record.define_metamodel_method(fn,              visibility(:reader)  ){      read_attribute(fn)       }
        record.define_metamodel_method("#{fn}=",        visibility(:writer)  ){|val| write_attribute(fn, val) }
        record.define_metamodel_method("receive_#{fn}", visibility(:receiver)){|val| write_attribute(fn, val) }
      end

      #
      # returns the visibility
      #
      # @example reader is protected, no writer:
      #   Foo.field :granuloxity, :reader => :protected, :writer => false
      #
      def visibility(meth_type)
        Validate.included_in!("method type", meth_type, [:reader, :writer, :receiver])
        @visibility[meth_type] || :public
      end

    public

      #
      # Now we can construct the actual fields.
      #

      # Name of this field. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]` (required)
      # @macro [attach] field
      #   @attribute $1
      #   @return [$2] the $1 field $*
      field :name, String, :writer => false, :doc => "The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]` (required)"

      # Factory for the field's values
      field :type, Class

      # Field's description
      field :doc, String

      # remove the attr_reader method (needed for scaffolding), leaving the metamodel method to remain
      remove_possible_method(:name)

    end
  end
end



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
