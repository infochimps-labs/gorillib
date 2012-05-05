require 'gorillib/object/blank'
require 'gorillib/array/extract_options'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/hash/slice'
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
        @blankish_vals = options.delete(:blankish_vals) if options.has_key?(:blankish_vals)
        options.slice(*redefinable_methods).each do |meth, value_or_block|
          redefine(meth, value_or_block)
        end
      end

      def self.receive(*args, &block)
        self.new.receive(*args, &block)
      end

      # A `native` object does not need any transformation; it is simply `dup`d.
      # By default, an object is native if it `is_a?(product)`
      #
      # @param   [Object]      obj the object to convert and receive
      # @returns [true, false] true if the item does not need conversion
      def native?(obj)
        obj.is_a?(product)
      end

      # A `blankish` object should be converted to `nil`, not a value
      #
      # @param   [Object]      obj the object to convert and receive
      # @returns [true, false] true if the item is equivalent to a nil value
      def blankish?(obj)
        blankish_vals.include?(obj)
      end

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
        p block
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


    class IdentityFactory
      def blankish?(obj)
        false
      end
      def receive(obj)
        return nil  if blankish?(obj)
        obj
      end
    end
    Whatever = IdentityFactory

    #
    #
    #
    
    class ConvertingFactory < BaseFactory

      def receive(obj)
        return nil  if blankish?(obj)
        convert(obj)
      rescue NoMethodError, TypeError => err
        mismatched!(obj, err.message, err.backtrace)
      end

    protected

      # Convert a receivable,
      def convert(obj)
        obj.dup
      end
    end

    class StringFactory < ConvertingFactory
      self.product = String
      def native?(obj)      obj.respond_to?(:to_str)  end
      def convert(obj)      obj.to_s                  end
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

    #
    #
    #

    class EnumerableFactory < ConvertingFactory
      # [#receive] factory for converting objects
      attr_reader :items_factory
      self.redefinable_methods += [:convert_value, :empty_product]
      self.blankish_vals = Set.new([nil])
        
      def initialize(items_factory=IdentityFactory)
        @items_factory = items_factory
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
    end

    class HashFactory < EnumerableFactory
      self.redefinable_methods += [:convert_key]
      self.product = Hash

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


    # __________________________________________________________________________

    class NonConvertingFactory < BaseFactory
    end

    class RangeFactory < NonConvertingFactory
    end



  #   #
  #   #
  #   #
  #
  #   #
  #   #
  #   #
  #
  #   module IdentityFactory
  #     extend BaseFactory
  #     extend self
  #     #
  #     def receive(obj)
  #       obj
  #     end
  #   end
  #   Whatever = IdentityFactory
  #
  #   #
  #   #
  #   #
  #
  #   module ItselfFactory
  #     extend BaseFactory
  #     extend self
  #     def receive(obj, *args)
  #       return obj.dup if (args.length == 1) && args.is_a?(self)
  #     end
  #   end
  #
  #   #
  #   #
  #   #
  #
  #   module ConvertingFactory
  #     def receive(obj)
  #       return obj unless mismatched?(obj)
  #       convert(obj)
  #     end
  #   end
  #
  #   module BlankIsNil
  #     def receive(obj, *args)
  #       return nil if obj.blank?
  #       super
  #     end
  #   end
  #
  #   module StringFactory
  #     extend BaseFactory
  #     extend ConvertingFactory
  #     extend BlankIsNil
  #     produces String
  #     def self.convert(obj) obj.to_s ; end
  #   end
  #
  #   module NumericFactory
  #     extend BaseFactory
  #     extend ConvertingFactory
  #     extend BlankIsNil
  #     produces Numeric
  #     def self.convert(obj) obj.to_s ; end
  #   end
  #
  #   module IntegerFactory
  #     extend NumericFactory
  #     produces Fixnum
  #     def self.convert(obj) obj.to_1 ; end
  #   end
  #   LongFactory = IntegerFactory
  #
  #   module FloatFactory
  #     extend NumericFactory
  #     produces Float
  #     def self.convert(obj) obj.to_s ; end
  #   end
  #   DoubleFactory = FloatFactory
  #
  #   #   name      produces       convert   receivable?        converted?     nil    ""   []   {}
  #   [
  #     [ :Boolean, [true,false],  ??,        [true, false],    [true, false],  nil,  nil,  ??,  ??],
  #     [ :Integer, Fixnum,        :to_i,     :to_i,            is_a?(Float),   nil   nil,  err, err],
  #     [ :Float,   Float,         :to_f,     :to_f,            is_a?(Fixnum),  nil   nil,  err, err],
  #     [ :String,  String,        :to_s,     :to_s,            is_a?(String),  nil,  "",   ??,  ??],
  #     [ :Symbol,  Symbol,        :to_s,     :to_s,            is_a?(String),  nil,  nil,  ??,  ??],
  #
  #     [ :Time ],
  #     [ :Regexp, ],
  #
  #
  #     [ :NilClass,  nil,  ],
  #     [ :TrueClass, true,  ],
  #     [ :FalseClass, false,  ],
  #
  #
  #   #
  #   #
  #   #
  #
  #   module NonConvertingFactory
  #     include BaseFactory
  #     #
  #     def receive(val)
  #       raise FactoryMismatchError, "item must already be a #{product} - got '#{val.inspect}'" if mismatched?(val)
  #       val
  #     end
  #   end
  #
  #   module ClassFactory  ; extend NonConvertingFactory ; produces Class      ; end
  #   module ModuleFactory ; extend NonConvertingFactory ; produces Module     ; end
  #   module NilFactory    ; extend NonConvertingFactory ; produces NilClass   ; end
  #   module TrueFactory   ; extend NonConvertingFactory ; produces TrueClass  ; end
  #   module FalseFactory  ; extend NonConvertingFactory ; produces FalseClass ; end
  #
  #   module ReceiverFactory
  #     extend BaseFactory
  #     def self.receive(val)
  #       raise FactoryMismatchError, "item must respond to .receive - got '#{val.inspect}'" unless val.respond_to?(:receive)
  #       val
  #     end
  #   end

  end

end
