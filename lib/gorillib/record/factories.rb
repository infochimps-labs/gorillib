module Gorillib

  
  # * (Boolean)
  # * Symbol String
  # * Regexp
  # * Bignum Fixnum Integer Numeric
  # * Float (Double)
  # * Complex Rational
  # * Random
  # * Time
  # * Date
  #
  # * Dir File Pathname 
  # * Whatever -- alias for IdentityFactory
  #
  # * Method, Proc
  # * Range
  #
  # * Hash
  # * Array
  #
  # * Object
  # * Class Module FalseClass TrueClass NilClass
  #
  # These don't have factories because I can't really think of a reasonable use case
  # * DateTime Struct MatchData UnboundMethod IO Enumerator
  #
  # These are *not* decorated because it's not a good idea
  # * BasicObject
  # * Exception Interrupt SignalException SystemExit 
  # * Encoding Data Fiber Mutex ThreadGroup Thread Binding

  
  module Factory
    class FactoryMismatchError < ArgumentError
    end

    module BaseFactory
      attr_reader :product_type
      
      def produces(type)
        @product_type = type
      end

      def expected?(inst)
        inst.is_a?(@product_type)
      end
    end

    #
    #
    #

    module IdentityFactory
      extend BaseFactory
      extend self
      #
      def receive(obj)
        obj
      end
    end
    Whatever = IdentityFactory

    #
    #
    #
    
    module InstanceFactory
      extend BaseFactory
      extend self
      def receive(obj, *args)
        return obj.dup if (args.length == 1) && args.is_a?(self)
      end
    end

    #
    #
    #

    module NonConvertingFactory
      include BaseFactory
      #
      def receive(inst)
        raise FactoryMismatchError, "item must already be a #{product_type} - got '#{inst.inspect}'" unless expected?(inst)
        inst
      end
    end
    
    module ClassFactory  ; extend NonConvertingFactory ; produces Class      ; end
    module ModuleFactory ; extend NonConvertingFactory ; produces Module     ; end
    module NilFactory    ; extend NonConvertingFactory ; produces NilClass   ; end
    module TrueFactory   ; extend NonConvertingFactory ; produces TrueClass  ; end
    module FalseFactory  ; extend NonConvertingFactory ; produces FalseClass ; end

    module ReceiverFactory
      extend BaseFactory
      def self.receive(inst) 
        raise FactoryMismatchError, "item must respond to .receive - got '#{inst.inspect}'" unless inst.respond_to?(:receive)
        inst
      end
    end
    
  end


  # Complex, Rational, 
  # Fiber, Mutex, Thread
  
  
end
