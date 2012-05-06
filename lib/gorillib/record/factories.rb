def Gorillib::Factory(*args)
  ::Gorillib::Factory.factory_for(*args)
end

module Gorillib

  module Factory
    class FactoryMismatchError < ArgumentError ; end

    class << self
      def factory_for(type)
        case
        when type.is_a?(Proc) || type.is_a?(Method) then return Gorillib::Factory::ApplyProcFactory.new(type)
        when type.respond_to?(:receive)             then return type
        when factories.include?(type)               then return factories[type]
        else raise "Don't know which factory makes a #{type}"
        end
      end

      def factories
        @factories ||= Gorillib::Collection.new.tap{|f| f.key_method = :name }
      end
      private :factories

      def register_factory(factory, *handles)
        if handles.blank?
          handles = [factory.handle, factory.product]
        end
        handles.each{|handle| factories[handle] = factory }
      end
    end

    class BaseFactory
      # [Class] The type of objects produced by this factory
      class_attribute :product

      # [Array<Symbol>] methods that can be redefined by passing a block to an
      # instance No not add to your superclass' value in-place; instead, use
      # `self.redefinable_methods += [...]`.
      # @see #redefine
      class_attribute :redefinable_methods, :instance_writer => false
      self.redefinable_methods = Set.new([:blankish?, :convert])

      # [Array<Object>] objects considered to be equivalent to `nil`
      class_attribute :blankish_vals
      self.blankish_vals = Set.new([ nil, "" ]) # note: [] {} and false are NOT blankish by default

      def initialize(options={})
        @product       = options.delete(:product)       if options.has_key?(:product)
        @blankish_vals = options.delete(:blankish_vals) if options.has_key?(:blankish_vals)
        options.extract!(*redefinable_methods).each do |meth, value_or_block|
          redefine(meth, value_or_block)
        end
        warn "Unknown options #{options.keys}" unless options.empty?
      end

      def self.handle
        Gorillib::Inflector.underscore(product.name).to_sym
      end

      def self.receive(*args, &block)
        self.new.receive(*args, &block)
      end

      # A `native` object does not need any transformation; it is accepted directly.
      # By default, an object is native if it `is_a?(product)`
      #
      # @param   [Object]      obj the object to convert and receive
      # @returns [true, false] true if the item does not need conversion
      def native?(obj)
        obj.is_a?(product)
      end
      def self.native?(obj) self.new.native?(obj) ; end

      # A `blankish` object should be converted to `nil`, not a value
      #
      # @param   [Object]      obj the object to convert and receive
      # @returns [true, false] true if the item is equivalent to a nil value
      def blankish?(obj)
        blankish_vals.include?(obj)
      end
      def self.blankish?(obj) self.new.blankish?(obj) ; end

      def redefine(meth, *args, &block)
        raise ArgumentError, "Cannot redefine #{meth} -- only #{redefinable_methods.inspect} are redefinable" unless redefinable_methods.include?(meth)
        if args.present?
          val = args.first
          case
          when block_given? then raise ArgumentError, "Pass a block or a value, not both"
          when val.is_a?(Proc) || val.is_a?(Method) then block = val
          else block = ->(*){ val.try_dup }
          end
        end
        define_singleton_method(meth, &block)
        self
      end

    protected

      # Raises a FactoryMismatchError.
      def mismatched!(obj, message=nil, *args)
        message ||= "item cannot be converted to #{product}"
        message <<  (" got #{obj.inspect}" rescue ' (and is uninspectable)')
        raise FactoryMismatchError, message, *args
      end

      def self.register_factory!(*args)
        Gorillib::Factory.register_factory(self, *args)
      end
    end

    class ConvertingFactory < BaseFactory
      def receive(obj)
        return nil  if blankish?(obj)
        return obj  if native?(obj)
        convert(obj)
      rescue NoMethodError, TypeError, RangeError => err
        mismatched!(obj, err.message, err.backtrace)
      end
    protected
      # Convert a receivable object to the factory's product type. This method
      # should convert an object to `native?` form or die trying; any
      # polymorphism (such as converting an empty string to nil) happens in
      # other methods called by `receive`.
      #
      # @param [Object] obj the object to convert.
      def convert(obj)
        obj.dup
      end
    end

    class IdenticalFactory < BaseFactory
      self.redefinable_methods = []
      self.blankish_vals       = []
      def native?(obj)   true  ; end
      def blankish?(obj) false ; end
      def receive(obj)
        obj
      end
      register_factory!(:identical, :whatever)
    end
    ::Whatever = IdenticalFactory

    # __________________________________________________________________________
    #
    # A NonConvertingFactory accepts objects that are *already* native, and
    # throws a mismatch error for anything else.
    #
    # @example
    #   ff = Gorillib::Factory::NonConvertingFactory.new(:product => String, :blankish_vals => [nil])
    #   ff.receive(nil)    #=> nil
    #   ff.receive("bob")  #=> "bob"
    #   ff.receive(:bob)   #=> Gorillib::Factory::FactoryMismatchError: must be an instance of String, got 3
    #
    class NonConvertingFactory < BaseFactory
      self.blankish_vals = [nil]

      def receive(obj)
        return nil  if blankish?(obj)
        return obj  if native?(obj)
        mismatched!(obj, "must be an instance of #{product},")
      rescue NoMethodError => err
        mismatched!(obj, err.message, err.backtrace)
      end
    end

    #
    #
    #

    class StringFactory < ConvertingFactory
      self.product = String
      self.blankish_vals -= [""]
      def native?(obj)      obj.respond_to?(:to_str)  end
      def convert(obj)      obj.to_s                  end
      register_factory!
    end

    class BinaryFactory < StringFactory
      def convert(obj)
        super.force_encoding("BINARY")
      end
      register_factory!(:binary)
    end

    class SymbolFactory < ConvertingFactory
      self.product = Symbol
      def convert(obj)      obj.to_sym                end
      register_factory!
    end

    class RegexpFactory < ConvertingFactory
      self.product = Regexp
      def convert(obj)      Regexp.new(obj)           end
      register_factory!
    end

    class IntegerFactory < ConvertingFactory
      self.product = Integer
      def convert(obj)      obj.to_i                  end
      register_factory!(:int, :integer, Integer)
    end
    class BignumFactory < IntegerFactory
      self.product = Bignum
      register_factory!
    end
    class FloatFactory < ConvertingFactory
      self.product = Float
      def convert(obj)      obj.to_f                  end
      register_factory!
    end
    class ComplexFactory < ConvertingFactory
      self.product = Complex
      def convert(obj)      obj.to_c                  end
      register_factory!
    end
    class RationalFactory < ConvertingFactory
      self.product = Rational
      def convert(obj)      obj.to_r                  end
      register_factory!
    end

    class TimeFactory < ConvertingFactory
      self.product = Time
      def convert(obj)
        Time.parse(obj).utc
      end
      register_factory!
    end

    # __________________________________________________________________________

    class ClassFactory  < NonConvertingFactory ; self.product = Class      ; register_factory! ; end
    class ModuleFactory < NonConvertingFactory ; self.product = Module     ; register_factory! ; end
    class TrueFactory   < NonConvertingFactory ; self.product = TrueClass  ; register_factory!(:true, TrueClass) ; end
    class FalseFactory  < NonConvertingFactory ; self.product = FalseClass ; register_factory!(:false, FalseClass) ; end

    class NilFactory    < NonConvertingFactory
      self.product       = NilClass
      self.blankish_vals = []
      register_factory!(:nil, NilClass)
    end

    class BooleanFactory < ConvertingFactory
      self.product       = [TrueClass, FalseClass]
      self.blankish_vals = [nil]
      def native?(obj)     obj.equal?(true) || obj.equal?(false) ; end
      def convert(obj)     (obj.to_s == "false") ? false : true ; end
      register_factory!(:boolean)
    end

    #
    #
    #

    class EnumerableFactory < ConvertingFactory
      # [#receive] factory for converting items
      attr_reader :items_factory
      self.redefinable_methods += [:empty_product]
      self.blankish_vals = Set.new([ nil ])

      def initialize(options={})
        @items_factory = Gorillib::Factory.factory_for( options.delete(:items){ IdenticalFactory.new } )
        super(options)
      end

      def native?(obj)
        false
      end

      def empty_product
        product.new
      end

      def convert(obj)
        clxn = empty_product
        obj.each do |val|
          clxn << items_factory.receive(val)
        end
        clxn
      end
    end

    class ArrayFactory < EnumerableFactory
      self.product = Array
      register_factory!
    end

    class SetFactory < EnumerableFactory
      self.product = Set
      register_factory!
    end

    class HashFactory < EnumerableFactory
      # [#receive] factory for converting keys
      attr_reader :keys_factory
      self.product = Hash

      def initialize(options={})
        @keys_factory = Gorillib::Factory( options.delete(:keys){ Whatever.new } )
        super(options)
      end

      def convert(obj)
        hsh = empty_product
        obj.each_pair do |key, val|
          hsh[keys_factory.receive(key)] = items_factory.receive(val)
        end
        hsh
      end
      register_factory!
    end

    class RangeFactory < NonConvertingFactory
      self.product       = Range
      self.blankish_vals = [ nil, [] ]
      register_factory!
    end

    # __________________________________________________________________________

    class ApplyProcFactory < ConvertingFactory
      attr_reader :callable
      self.blankish_vals = Set.new([nil])

      def initialize(callable=nil, options={}, &block)
        if block_given?
          raise ArgumentError, "Pass a block or a value, not both" unless callable.nil?
          callable = block
        end
        @callable = callable
        super(options)
      end
      def native?(val)
        false
      end
      def convert(obj)
        callable.call(obj)
      end
      register_factory!(:proc)
    end


  end

end
