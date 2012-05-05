require 'gorillib/object/blank'
require 'gorillib/array/extract_options'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/hash/slice'
require 'gorillib/type/extended'
require 'set'

require 'pathname'
require 'time'

module Gorillib

  module Factory
    class FactoryMismatchError < ArgumentError ; end

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
        options.slice(*redefinable_methods).each do |meth, value_or_block|
          redefine(meth, value_or_block)
        end
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
          else block = ->(*){ val }
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

    class IdentityFactory < BaseFactory
      def native?(obj)
        true
      end
      def blankish?(obj)
        false
      end
      def receive(obj)
        return nil  if blankish?(obj)
        obj
      rescue NoMethodError => err
        mismatched!(obj, err.message, err.backtrace)
      end
    end
    ::Whatever = IdentityFactory

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
    end

    class BinaryFactory < StringFactory
      def convert(obj)
        super.force_encoding("BINARY")
      end
    end

    class SymbolFactory < ConvertingFactory
      self.product = Symbol
      def convert(obj)      obj.to_sym                end
    end

    class RegexpFactory < ConvertingFactory
      self.product = Regexp
      def convert(obj)      Regexp.new(obj)           end
    end

    class IntegerFactory < ConvertingFactory
      self.product = Integer
      def convert(obj)      obj.to_i                  end
    end
    class BignumFactory < IntegerFactory
      self.product = Bignum
    end
    class FloatFactory < ConvertingFactory
      self.product = Float
      def convert(obj)      obj.to_f                  end
    end
    class ComplexFactory < ConvertingFactory
      self.product = Complex
      def convert(obj)      obj.to_c                  end
    end
    class RationalFactory < ConvertingFactory
      self.product = Rational
      def convert(obj)      obj.to_r                  end
    end

    class TimeFactory < ConvertingFactory
      self.product = Time
      def convert(obj)
        Time.parse(obj).utc
      end
    end

    # __________________________________________________________________________
    
    class ClassFactory  < NonConvertingFactory ; self.product = Class      ; end
    class ModuleFactory < NonConvertingFactory ; self.product = Module     ; end
    class TrueFactory   < NonConvertingFactory ; self.product = TrueClass  ; end
    class FalseFactory  < NonConvertingFactory ; self.product = FalseClass ; end

    class NilFactory    < NonConvertingFactory
      self.product       = NilClass
      self.blankish_vals = []
    end

    class BooleanFactory < ConvertingFactory
      self.product       = [TrueClass, FalseClass]
      self.blankish_vals = [nil]
      def native?(obj)     obj.equal?(true) || obj.equal?(false) ; end
      def convert(obj)     (obj.to_s == "false") ? false : true ; end
    end

    #
    #
    #

    class EnumerableFactory < ConvertingFactory
      # [#receive] factory for converting objects
      attr_reader :items_factory
      self.redefinable_methods += [:convert_value, :empty_product]
      self.blankish_vals = Set.new([ nil, [] ])

      def initialize(items_factory=IdentityFactory, options={})
        @items_factory = items_factory
        super(options)
      end

      def native?(obj)
        false
      end

      def empty_product
        product.new
      end

      def convert_value(val)
        items_factory.receive(val)
      end

      def convert(obj)
        obj.each do |val|
          empty_product << val
        end
      end
    end

    class ArrayFactory < EnumerableFactory
      self.product = Array
    end

    class SetFactory < EnumerableFactory
      self.product = Set
      self.blankish_vals += [ Set.new ]
    end

    class HashFactory < EnumerableFactory
      self.redefinable_methods += [:convert_key]
      self.product = Hash
      self.blankish_vals += [ {} ]

      def convert_key(val)
        val.to_sym
      end

      def convert(obj)
        hsh = empty_product
        obj.each_pair do |key, val|
          hsh[convert_key(key)] = convert_value(val)
        end
        hsh
      end
    end

    class RangeFactory < NonConvertingFactory
      self.product       = NilClass
      self.blankish_vals = [ nil, [] ]
    end

    # __________________________________________________________________________

    class AppliedFactory < ConvertingFactory
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
      def native(val)
        false
      end
      def convert(obj)
        callable.call(obj)
      end
    end


  end

end
