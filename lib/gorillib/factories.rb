require 'pathname'
require 'time'
require 'gorillib/metaprogramming/class_attribute'
require 'gorillib/string/inflector'
require 'gorillib/exception/raisers'
require 'gorillib/hash/compact'
require 'gorillib/object/try_dup'

def Gorillib::Factory(*args)
  ::Gorillib::Factory.find(*args)
end

module Gorillib

  module Factory
    class FactoryMismatchError < TypeMismatchError ; end

    def self.find(type)
      case
      when factories.include?(type)               then return factories[type]
      when type.respond_to?(:receive)             then return type
      when type.is_a?(Proc) || type.is_a?(Method) then return Gorillib::Factory::ApplyProcFactory.new(type)
      when type.is_a?(String)                     then
        return( factories[type] = Gorillib::Inflector.constantize(Gorillib::Inflector.camelize(type.gsub(/\./, '/'))) )
      else raise ArgumentError, "Don't know which factory makes a #{type}"
      end
    end

    def self.factory_for(type, options={})
      return find(type) if options.compact.blank?
      klass = factory_klasses[type] or raise "You can only supply options #{options} to a Factory-mapped class"
      klass.new(options)
    end

    def self.register_factory(factory, typenames)
      typenames.each{|typename| factories[typename] = factory }
    end

    def self.register_factory_klass(factory_klass, typenames)
      typenames.each{|typename| factory_klasses[typename] = factory_klass }
    end

    private
    def self.factories()       @factories       ||= Hash.new end
    def self.factory_klasses() @factory_klasses ||= Hash.new end
    public

    #
    # A gorillib Factory should answer to the following:
    #
    # * `typename`  -- a handle (symbol, lowercased-underscored) naming this type
    # * `native?`   -- native objects do not need type-conversion
    # * `blankish?` -- blankish objects are type-converted to a `nil` value
    # * `product`   -- the class of objects produced when non-blank
    # * `receive`   -- performs the actual conversion
    #
    class BaseFactory
      # [Class] The type of objects produced by this factory
      class_attribute :product

      def initialize(options={})
        @product       = options.delete(:product){ self.class.product }
        define_blankish_method(options.delete(:blankish)) if options.has_key?(:blankish)
        redefine(:convert, options.delete(:convert)) if options.has_key?(:convert)
        warn "Unknown options #{options.keys}" unless options.empty?
      end

      def self.typename
        @typename ||= Gorillib::Inflector.underscore(product.name).to_sym
      end
      def typename ; self.class.typename ; end

      # A `native` object does not need any transformation; it is accepted directly.
      # By default, an object is native if it `is_a?(product)`
      #
      # @param  obj [Object] the object that will be received
      # @return [true, false] true if the item does not need conversion
      def native?(obj)
        obj.is_a?(@product)
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

      # performs the actual conversion
      def receive(*args)
        NoMethodError.abstract_method(self)
      end

    protected

      def define_blankish_method(blankish)
        FactoryMismatchError.check_type!(blankish, [Proc, Method, :include?])
        if   blankish.respond_to?(:include?)
        then meth = ->(val){ blankish.include?(val) }
        else meth = blankish ; end
        define_singleton_method(:blankish?, meth)
      end

      def redefine(meth, *args, &block)
        if args.present?
          val = args.first
          case
          when block_given? then raise ArgumentError, "Pass a block or a value, not both"
          when val.is_a?(Proc) || val.is_a?(Method) then block = val
          else block = ->(*){ val.try_dup }
          end
        end
        self.define_singleton_method(meth, &block)
        self
      end

      # Raises a FactoryMismatchError.
      def mismatched!(obj, message=nil, *args)
        message ||= "item cannot be converted to #{product}"
        FactoryMismatchError.mismatched!(obj, product, message, *args)
      end

      def self.register_factory!(*typenames)
        typenames = [typename, product] if typenames.empty?
        Gorillib::Factory.register_factory_klass(self,     typenames)
        Gorillib::Factory.register_factory(      self.new, typenames)
      end
    end

    class ConvertingFactory < BaseFactory
      def receive(obj)
        return nil  if blankish?(obj)
        return obj  if native?(obj)
        convert(obj)
      rescue NoMethodError, TypeError, RangeError, ArgumentError => err
        mismatched!(obj, err.message, err.backtrace)
      end
    protected
      # Convert a receivable object to the factory's product type. This method
      # should convert an object to `native?` form or die trying; any variant
      # types (eg nil for an empty string) are handled elsewhere by `receive`.
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

    # __________________________________________________________________________
    #
    #  Generic Factories
    # __________________________________________________________________________

    #
    # Factory that accepts whatever given and uses it directly -- no nothin'
    #
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


    # Manufactures objects from their raw attributes hash
    #
    # The hash must have a value for `:_type`, used to retrieve the actual factory
    #
    class ::GenericModel < BaseFactory
      def blankish?(obj) obj.nil? ; end
      def native?(obj)   false  ; end
      def receive(attrs, &block)
        Gorillib::Model::Validate.hashlike!(attrs){ "attributes for typed object" }
        klass = Gorillib::Factory(attrs.fetch(:_type){ attrs.fetch("_type") })
        #
        klass.new(attrs, &block)
      end
      def self.receive(obj) allocate.receive(obj) end
      register_factory!(GenericModel, :generic)
    end

    # __________________________________________________________________________
    #
    #  Concrete Factories
    # __________________________________________________________________________

    class StringFactory < ConvertingFactory
      self.product = String
      def blankish?(obj)    obj.nil?                 end
      def native?(obj)      obj.respond_to?(:to_str) end
      def convert(obj)      String(obj)              end
      register_factory!
    end

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

    #
    # In the following, we use eg `Float(val)` and not `val.to_f` --
    # they round-trip things
    #
    #     Float("0x1.999999999999ap-4") # => 0.1
    #     "0x1.999999999999ap-4".to_f   # => 0
    #

    FLT_CRUFT_CHARS  = ',fFlL'
    FLT_NOT_INT_RE   = /[\.eE]/

    #
    # Converts arg to a Fixnum or Bignum.
    #
    # * Numeric types are converted directly, with floating point numbers being truncated
    # * Strings are interpreted using `Integer()`, so:
    #   ** radix indicators (0, 0b, and 0x) are HONORED -- '011' means 9, not 11; '0x22' means 0, not 34
    #   ** They must strictly conform to numeric representation or an error is raised (which differs from the behavior of String#to_i)
    # * Non-string values will be converted using to_int, and to_i.
    #
    # @example
    #   IntegerFactory.receive(123.999)    #=> 123
    #   IntegerFactory.receive(Time.new)   #=> 1204973019
    #
    # @example IntegerFactory() handles floating-point numbers correctly (as opposed to `Integer()` and GraciousIntegerFactory)
    #   IntegerFactory.receive("98.6")     #=> 98
    #   IntegerFactory.receive("1234.5e3") #=> 1_234_500
    #
    # @example IntegerFactory has love for your hexadecimal, and disturbingly considers 0-prefixed numbers to be octal.
    #   IntegerFactory.receive("0x1a")     #=> 26
    #   IntegerFactory.receive("011")      #=> 9
    #
    # @example IntegerFactory() is not as gullible, or generous as GraciousIntegerFactory
    #   IntegerFactory.receive("7eleven")  #=> (error)
    #   IntegerFactory.receive("nonzero")  #=> (error)
    #   IntegerFactory.receive("123_456L") #=> (error)
    #
    # @note returns Bignum or Fixnum (instances of either are `is_a?(Integer)`)
    class IntegerFactory < ConvertingFactory
      self.product = Integer
      def convert(obj)
        Integer(obj)
      end
      register_factory!(:int, :integer, Integer)
    end

    #
    # Converts arg to a Fixnum or Bignum.
    #
    # * Numeric types are converted directly, with floating point numbers being truncated
    # * Strings are interpreted using `#to_i`, so:
    #   ** radix indicators (0, 0b, and 0x) are IGNORED -- '011' means 11, not 9; '0x22' means 0, not 34
    #   ** Strings will be very generously interpreted
    # * Non-string values will be converted using to_i
    #
    # @example
    #     GraciousIntegerFactory.receive(123.999)    #=> 123
    #     GraciousIntegerFactory.receive(Time.new)   #=> 1204973019
    #
    # @example GraciousIntegerFactory quietly mangles your floating-pointish strings
    #     GraciousIntegerFactory.receive("123.4e-3") #=> 123
    #     GraciousIntegerFactory.receive("1e9")      #=> 1
    #
    # @example GraciousIntegerFactory does not care for your hexadecimal
    #     GraciousIntegerFactory.receive("0x1a")     #=> 0
    #     GraciousIntegerFactory.receive("011")      #=> 11
    #
    # @example GraciousIntegerFactory is generous (perhaps too generous) where IntegerFactory() is not
    #     GraciousIntegerFactory.receive("123_456L") #=> 123_456
    #     GraciousIntegerFactory.receive("7eleven")  #=> 7
    #     GraciousIntegerFactory.receive("nonzero")  #=> 0
    #
    # @note returns Bignum or Fixnum (instances of either are `is_a?(Integer)`)
    class GraciousIntegerFactory < IntegerFactory
      # See examples/benchmark before 'improving' this method.
      def convert(obj)
        if ::String === obj then
          obj = obj.to_s.tr(::Gorillib::Factory::FLT_CRUFT_CHARS, '') ;
          obj = ::Kernel::Float(obj) if ::Gorillib::Factory::FLT_NOT_INT_RE === obj ;
        end
        ::Kernel::Integer(obj)
      end
      register_factory!(:gracious_int)
    end

    # Same behavior (and conversion) as IntegerFactory, but specifies its
    # product as `Bignum`.
    #
    # @note returns Bignum or Fixnum (instances of either are `is_a?(Integer)`)
    class BignumFactory < IntegerFactory
      self.product = Bignum
      register_factory!
    end

    # Returns arg converted to a float.
    # * Numeric types are converted directly
    # * Strings strictly conform to numeric representation or an error is raised (which differs from the behavior of String#to_f)
    # * Strings in radix format (an exact hexadecimal encoding of a number) are properly interpreted.
    # * Octal is not interpreted! This means an IntegerFactory receiving '011' will get 9, a FloatFactory 11.0
    # * Other types are converted using obj.to_f.
    #
    # @example
    #   FloatFactory.receive(1)                     #=> 1.0
    #   FloatFactory.receive("123.456")             #=> 123.456
    #   FloatFactory.receive("0x1.999999999999ap-4" #=> 0.1
    #
    # @example FloatFactory is strict in some cases where GraciousFloatFactory is not
    #   FloatFactory.receive("1_23e9f")             #=> (error)
    #
    # @example FloatFactory() is not as gullible as GraciousFloatFactory
    #   FloatFactory.receive("7eleven")             #=> (error)
    #   FloatFactory.receive("nonzero")             #=> (error)
    #
    class FloatFactory < ConvertingFactory
      self.product = Float
      def convert(obj) Float(obj) ; end
      register_factory!
    end

    # Returns arg converted to a float.
    # * Numeric types are converted directly
    # * Strings can have ',' (which are removed) or end in `/LlFf/` (pig format);
    #   they should other conform to numeric representation or an error is raised.
    #   (this differs from the behavior of String#to_f)
    # * Strings in radix format (an exact hexadecimal encoding of a number) are properly interpreted.
    # * Octal is not interpreted! This means an IntegerFactory receiving '011' will get 9, a FloatFactory 11.0
    # * Other types are converted using obj.to_f.
    #
    # @example
    #   GraciousFloatFactory.receive(1)                     #=> 1.0
    #   GraciousFloatFactory.receive("123.456")             #=> 123.456
    #   GraciousFloatFactory.receive("0x1.999999999999ap-4" #=> 0.1
    #   GraciousFloatFactory.receive("1_234.5")             #=> 1234.5
    #
    # @example GraciousFloatFactory is generous in some cases where FloatFactory is not
    #   GraciousFloatFactory.receive("1234.5f")             #=> 1234.5
    #   GraciousFloatFactory.receive("1,234.5")             #=> 1234.5
    #   GraciousFloatFactory.receive("1234L")               #=> 1234.0
    #
    # @example GraciousFloatFactory is not as gullible as #to_f
    #   GraciousFloatFactory.receive("7eleven")             #=> (error)
    #   GraciousFloatFactory.receive("nonzero")             #=> (error)
    #
    class GraciousFloatFactory < FloatFactory
      self.product = Float
      def convert(obj)
        if String === obj then obj = obj.to_s.tr(FLT_CRUFT_CHARS,'') ; end
        super(obj)
      end
      register_factory!(:gracious_float)
    end

    class ComplexFactory < ConvertingFactory
      self.product = Complex
      def convert(obj)
        if obj.respond_to?(:to_ary)
          x_y = obj.to_ary
          mismatched!(obj, "expected tuple to be a pair") unless (x_y.length == 2)
          Complex(* x_y)
        else
          Complex(obj)
        end
      end
      register_factory!
    end
    class RationalFactory < ConvertingFactory
      self.product = Rational
      def convert(obj)
        if obj.respond_to?(:to_ary)
          x_y = obj.to_ary
          mismatched!(obj, "expected tuple to be a pair") unless (x_y.length == 2)
          Rational(* x_y)
        else
          Rational(obj)
        end
      end
      register_factory!
    end

    class TimeFactory < ConvertingFactory
      self.product = Time
      FLAT_TIME_RE = /\A\d{14}Z?\z/ unless defined?(Gorillib::Factory::TimeFactory::FLAT_TIME_RE)
      def native?(obj) super(obj) && obj.utc_offset == 0 ; end
      def convert(obj)
        case obj
        when FLAT_TIME_RE  then product.utc(obj[0..3].to_i, obj[4..5].to_i, obj[6..7].to_i, obj[8..9].to_i, obj[10..11].to_i, obj[12..13].to_i)
        when Time          then obj.getutc
        when Date          then product.utc(obj.year, obj.month, obj.day)
        when String        then product.parse(obj).utc
        when Numeric       then product.at(obj)
        else                    mismatched!(obj)
        end
      rescue ArgumentError => err
        raise if err.is_a?(TypeMismatchError)
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
      def self.typename() :boolean ; end
      self.product       = [TrueClass, FalseClass]
      def blankish?(obj)   obj.nil? ; end
      def native?(obj)     obj.equal?(true) || obj.equal?(false) ; end
      def convert(obj)     (obj.to_s == "false") ? false : true ; end
      register_factory!   :boolean
    end

    #
    #
    #

    class EnumerableFactory < ConvertingFactory
      # [#receive] factory for converting items
      attr_reader :items_factory

      def initialize(options={})
        @items_factory = Gorillib::Factory( options.delete(:items){ :identical } )
        redefine(:empty_product, options.delete(:empty_product)) if options.has_key?(:empty_product)
        super(options)
      end

      def blankish?(obj)    obj.nil? ; end
      def native?(obj)      false    ; end

      def empty_product
        @product.new
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
