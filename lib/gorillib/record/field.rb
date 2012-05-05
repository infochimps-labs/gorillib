module Gorillib
  module Record

    # Represents a field for reflection
    #
    # @example Usage
    #   Gorillib::Record::Field.new(:name => 'problems', type => Integer, :doc => 'Count of problems')
    #
    #
    class Field
      include Gorillib::Record
      remove_possible_method(:type)

      # [Gorillib::Record] Record owning this field
      attr_reader :record

      # [Hash] all options passed to the field not recognized by one of its own current fields
      attr_reader :extra_attributes

      # Note: `Gorillib::Record::Field` is assembled in two pieces, so that it
      # can behave as a record itself. Defining `name` here, along with some
      # fudge in #initialize, provides enough functionality to bootstrap.
      # The fields are then defined properly at the end of the file.

      attr_reader :name

      # @param [#to_sym]                name    Field name
      # @param [#receive]               type    Factory for field values. To accept any object as-is, specify `Object` as the type.
      # @param [Gorillib::Record]       record   Field's owner
      # @param [Hash{Symbol => Object}] options Extended attributes
      # @option options [String] doc Description of the field's purpose
      # @option options [true, false, :public, :protected, :private] :reader   Visibility for the reader (`#foo`) method; `false` means don't create one.
      # @option options [true, false, :public, :protected, :private] :writer   Visibility for the writer (`#foo=`) method; `false` means don't create one.
      # @option options [true, false, :public, :protected, :private] :receiver Visibility for the receiver (`#receive_foo`) method; `false` means don't create one.
      #
      def initialize(name, type, record, options={})
        Validate.identifier!(name)
        @record            = record
        @name             = name.to_sym
        @type             = type
        @visibility       = [:reader, :writer, :receiver].inject({}){|acc,meth| acc[meth] = options.delete(meth) if options.has_key?(meth) ; acc }
        @doc              = options.delete(:name){ "#{name} field" }
        receive!(options)
      end

      # __________________________________________________________________________

      # @return [String] the field name
      def to_s
        name.to_s
      end

      # @return [String] Human-readable presentation of the field definition
      def inspect
        args = [name.inspect, type.to_s]
        "field(#{args.join(", ")})"
      end

      def to_hash
        attributes.merge!(@visibility).merge!(@extra_attributes)
      end

      def ==(val)
        super && (val.extra_attributes == self.extra_attributes) && (val.record == self.record)
      end

      def self.receive(hsh)
        name  = hsh.fetch(:name)
        type  = hsh.fetch(:type)
        record = hsh.fetch(:record)
        new(name, type, record, hsh)
      end

    protected

      #
      #
      #
      def inscribe_methods(record)
        fn = self.name
        record.__send__(:define_meta_module_method, fn,              visibility(:reader)  ){      read_attribute(fn)       }
        record.__send__(:define_meta_module_method, "#{fn}=",        visibility(:writer)  ){|val| write_attribute(fn, val) }
        record.__send__(:define_meta_module_method, "receive_#{fn}", visibility(:receiver)){|val| write_attribute(fn, val) }
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

      # remove the attr_reader method (needed for scaffolding), leaving the meta_module method to remain
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
