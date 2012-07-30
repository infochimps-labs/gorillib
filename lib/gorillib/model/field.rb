module Gorillib
  module Model

    # Represents a field for reflection
    #
    # @example Usage
    #   Gorillib::Model::Field.new(:name => 'problems', type => Integer, :doc => 'Count of problems')
    #
    #
    class Field
      include Gorillib::Model
      remove_possible_method(:type)

      # [Gorillib::Model] Model owning this field
      attr_reader :model

      # [Hash] all options passed to the field not recognized by one of its own current fields
      attr_reader :_extra_attributes

      # Note: `Gorillib::Model::Field` is assembled in two pieces, so that it
      # can behave as a model itself. Defining `name` here, along with some
      # fudge in #initialize, provides enough functionality to bootstrap.
      # The fields are then defined properly at the end of the file.

      attr_reader :name
      attr_reader :type

      class_attribute :visibilities, :instance_writer => false
      self.visibilities = { :reader => :public, :writer => :public, :receiver => :public, :tester => false }

      # @param [#to_sym]                name    Field name
      # @param [#receive]               type    Factory for field values. To accept any object as-is, specify `Object` as the type.
      # @param [Gorillib::Model]       model   Field's owner
      # @param [Hash{Symbol => Object}] options Extended attributes
      # @option options [String] doc Description of the field's purpose
      # @option options [true, false, :public, :protected, :private] :reader   Visibility for the reader (`#foo`) method; `false` means don't create one.
      # @option options [true, false, :public, :protected, :private] :writer   Visibility for the writer (`#foo=`) method; `false` means don't create one.
      # @option options [true, false, :public, :protected, :private] :receiver Visibility for the receiver (`#receive_foo`) method; `false` means don't create one.
      #
      def initialize(model, name, type, options={})
        Validate.identifier!(name)
        type_opts         = options.extract!(:blankish, :empty_product, :items, :keys, :of)
        type_opts[:items] = type_opts.delete(:of) if type_opts.has_key?(:of)
        #
        @model            = model
        @name             = name.to_sym
        @type             = Gorillib::Factory.factory_for(type, type_opts)
        default_visabilities = visibilities
        @visibilities     = default_visabilities.merge( options.extract!(*default_visabilities.keys) )
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
        args = [name.inspect, type.to_s, attributes.reject{|k,v| k =~ /^(name|type)$/}.inspect[1..-2] ]
        "field(#{args.join(", ")})"
      end
      def inspect_compact
        "field(#{name})"
      end

      def to_hash
        attributes.merge!(@visibility).merge!(@_extra_attributes)
      end

      def ==(val)
        super && (val._extra_attributes == self._extra_attributes) && (val.model == self.model)
      end

      def self.receive(hsh)
        name  = hsh.fetch(:name)
        type  = hsh.fetch(:type)
        model = hsh.fetch(:model)
        new(model, name, type, hsh)
      end

      #
      # returns the visibility
      #
      # @example reader is protected, no writer:
      #   Foo.field :granuloxity, :reader => :protected, :writer => false
      #
      def visibility(meth_type)
        Validate.included_in!("method type", meth_type, @visibilities.keys)
        @visibilities[meth_type]
      end

    protected

      #
      #
      #
      def inscribe_methods(model)
        model.__send__(:define_attribute_reader,   self.name, self.type, visibility(:reader))
        model.__send__(:define_attribute_writer,   self.name, self.type, visibility(:writer))
        model.__send__(:define_attribute_tester,   self.name, self.type, visibility(:tester))
        model.__send__(:define_attribute_receiver, self.name, self.type, visibility(:receiver))
      end

    public

      #
      # Now we can construct the actual fields.
      #

      field :position, Integer, :tester => true,       :doc => "Indicates this is a positional initialization arg -- you can pass it as a plain value in the given slot to #initialize"

      # Name of this field. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]` (required)
      # @macro [attach] field
      #   @attribute $1
      #   @return [$2] the $1 field $*
      field :name, String, position: 0, writer: false, doc: "The field name. Must start with `[A-Za-z_]` and subsequently contain only `[A-Za-z0-9_]` (required)"

      field :type, Class,  position: 1,                doc: "Factory to generate field's values"

      field :doc,  String,                             doc: "Field's description"

      # remove the attr_reader method (needed for scaffolding), leaving the meta_module method to remain
      remove_possible_method(:name)

    end


    class SimpleCollectionField < Gorillib::Model::Field
      field :item_type,        Class, default: Whatever, doc: "Factory for collection items"
      # field :collection_attrs, Hash,  default: Hash.new, doc: "Extra attributes to pass to the collection on creation -- eg. key_method"

      def initialize(model, name, type, options={})
        super
        collection_type = self.type
        item_type       = self.item_type
        key_method      = options[:key_method] if options[:key_method]
        raise "Please supply an item type for #{self.inspect} -- eg 'collection #{name.inspect}, of: FooClass'" unless item_type
        self.default ||= ->{ collection_type.new(item_type: item_type, belongs_to: self, key_method: key_method) }
      end

      def inscribe_methods(model)
        super
        model.__send__(:define_collection_receiver, self)
      end
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
