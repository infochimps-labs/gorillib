require 'pathname'
require 'gorillib/type/extended'

def Gorillib::Factory(*args)
  ::Gorillib::Factory.receive(*args)
end

module Gorillib

  module Factory
    class FactoryMismatchError < ArgumentError ; end

    def self.receive(type)
      case
      when factories.include?(type)               then return factories[type]
      when type.is_a?(Proc) || type.is_a?(Method) then return Gorillib::Factory::ApplyProcFactory.new(type)
      when type.respond_to?(:receive)             then return factories[type] = type
      when type.is_a?(String)                     then
        return( factories[type] = Gorillib::Inflector.constantize(Gorillib::Inflector.camelize(type.gsub(/\./, '/'))) )
      else raise ArgumentError, "Don't know which factory makes a #{type}"
      end
    end

    private
    def self.factories
      @factories ||= Hash.new
    end
    public

    def self.register_factory(factory, typenames)
      typenames.each{|typename| factories[typename] = factory }
    end

    class BaseFactory
      # [Class] The type of objects produced by this factory
      class_attribute :product

      def initialize(options={})
        @product       = options.delete(:product)       if options.has_key?(:product)
        if options[:blankish]
          define_singleton_method(:blankish, options.delete(:blankish))
        end
        redefine(:convert, options.delete(:convert)) if options.has_key?(:convert)
        warn "Unknown options #{options.keys}" unless options.empty?
      end

      def self.typename
        Gorillib::Inflector.underscore(product.name).to_sym
      end
      def typename ; self.class.typename ; end

      # A `native` object does not need any transformation; it is accepted directly.
      # By default, an object is native if it `is_a?(product)`
      #
      # @param   [Object]      obj the object to convert and receive
      # @return [true, false] true if the item does not need conversion
      def native?(obj)
        obj.is_a?(product)
      end
      def self.native?(obj) self.new.native?(obj) ; end

      # A `blankish` object should be converted to `nil`, not a value
      #
      # @param   [Object]      obj the object to convert and receive
      # @return [true, false] true if the item is equivalent to a nil value
      def blankish?(obj)
        obj.nil? || (obj == "")
      end
      def self.blankish?(obj)
        obj.nil? || (obj == "")
      end

    protected

      def redefine(meth, *args, &block)
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

      # Raises a FactoryMismatchError.
      def mismatched!(obj, message=nil, *args)
        message ||= "item cannot be converted to #{product}"
        message <<  (" got #{obj.inspect}" rescue ' (and is uninspectable)')
        raise FactoryMismatchError, message, *args
      end

      def self.register_factory!(*typenames)
        typenames = [typename, product] if typenames.empty?
        Gorillib::Factory.register_factory(self.new, typenames)
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

    #
    # A NonConvertingFactory accepts objects that are *already* native, and
    # throws a mismatch error for anything else.
    #
    # @example
    #   ff = Gorillib::Factory::NonConvertingFactory.new(:product => String, :blankish => ->(obj){ obj.nil? })
    #   ff.receive(nil)    #=> nil
    #   ff.receive("bob")  #=> "bob"
    #   ff.receive(:bob)   #=> Gorillib::Factory::FactoryMismatchError: must be an instance of String, got 3
    #
    class NonConvertingFactory < BaseFactory
      def blankish?(obj) obj.nil? ; end
      def receive(obj)
        return nil  if blankish?(obj)
        return obj  if native?(obj)
        mismatched!(obj, "must be an instance of #{product},")
      rescue NoMethodError => err
        mismatched!(obj, err.message, err.backtrace)
      end
    end

    class ::Whatever < BaseFactory
      def initialize(options={})
        options.slice!(:convert, :blankish)
        super(options)
      end
      def native?(obj)   true  ; end
      def blankish?(obj) false ; end
      def receive(obj)   obj   ; end
      def self.receive(obj)
        obj
      end
      Gorillib::Factory.register_factory(self, [self, :identical, :whatever])
    end
    IdenticalFactory = ::Whatever unless defined?(IdenticalFactory)

    # __________________________________________________________________________
    #
    #  Concrete Factories
    # __________________________________________________________________________

    class StringFactory < ConvertingFactory
      self.product = String
      def blankish?(obj)    obj.nil? ; end
      def native?(obj)      obj.respond_to?(:to_str)  end
      def convert(obj)      obj.to_s                  end
      register_factory!
    end

    class GuidFactory      < StringFactory ; self.product = ::Guid      ; register_factory! ; end
    class HostnameFactory  < StringFactory ; self.product = ::Hostname  ; register_factory! ; end
    class IpAddressFactory < StringFactory ; self.product = ::IpAddress ; register_factory! ; end

    class BinaryFactory < StringFactory
      def convert(obj)
        super.force_encoding("BINARY")
      end
      register_factory!(:binary)
    end

    class PathnameFactory  < ConvertingFactory
      self.product = ::Pathname
      def convert(obj)      Pathname.new(obj)         end
      register_factory!
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
        case obj
        when String
          Time.parse(obj).utc
        when Numeric
          Time.at(obj).utc
        end
      rescue ArgumentError => err
        warn "Cannot parse time #{obj}: #{err}"
        return nil
      end
      register_factory!
    end

    # __________________________________________________________________________

    class ClassFactory  < NonConvertingFactory ; self.product = Class      ; register_factory! ; end
    class ModuleFactory < NonConvertingFactory ; self.product = Module     ; register_factory! ; end
    class TrueFactory   < NonConvertingFactory ; self.product = TrueClass  ; register_factory!(:true, TrueClass) ; end
    class FalseFactory  < NonConvertingFactory ; self.product = FalseClass ; register_factory!(:false, FalseClass) ; end

    class ExceptionFactory < NonConvertingFactory ; self.product = Exception ; register_factory!(:exception, Exception) ; end

    class NilFactory    < NonConvertingFactory
      self.product       = NilClass
      def blankish?(obj) false ; end
      register_factory!(:nil, NilClass)
    end

    class BooleanFactory < ConvertingFactory
      self.product       = [TrueClass, FalseClass]
      def blankish?(obj)    obj.nil? ; end
      def native?(obj)     obj.equal?(true) || obj.equal?(false) ; end
      def convert(obj)     (obj.to_s == "false") ? false : true ; end
      register_factory!(:boolean)
      def self.typename() :boolean ; end
    end

    #
    #
    #

    class EnumerableFactory < ConvertingFactory
      # [#receive] factory for converting items
      attr_reader :items_factory

      def initialize(options={})
        @items_factory = Gorillib::Factory.receive( options.delete(:items){ Gorillib::Factory(:identical) } )
        redefine(:empty_product, options.delete(:empty_product)) if options.has_key?(:empty_product)
        super(options)
      end

      def blankish?(obj)    obj.nil? ; end
      def native?(obj)      false    ; end

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
        @keys_factory = Gorillib::Factory( options.delete(:keys){ Gorillib::Factory(:identical) } )
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
      def blankish?(obj)    obj.nil? || obj == [] ; end
      register_factory!
    end

    # __________________________________________________________________________

    class ApplyProcFactory < ConvertingFactory
      attr_reader :callable

      def initialize(callable=nil, options={}, &block)
        if block_given?
          raise ArgumentError, "Pass a block or a value, not both" unless callable.nil?
          callable = block
        end
        @callable = callable
        super(options)
      end
      def blankish?(obj)    obj.nil? ; end
      def native?(val)      false    ; end
      def convert(obj)
        callable.call(obj)
      end
      register_factory!(:proc)
    end


  end

end
