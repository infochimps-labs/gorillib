require 'pathname'
require 'date'
require 'set'
require 'gorillib/model/factories'

class ::Long      < ::Integer ; end
class ::Double    < ::Float   ; end
class ::Binary    < ::String  ; end

class ::Guid      < ::String  ; end
class ::IpAddress < ::String  ; end
class ::Hostname  < ::String  ; end

class ::EpochTime < ::Integer   ; end
class ::IntTime   < ::EpochTime ; end

module Gorillib
  module Factory
    class GuidFactory      < StringFactory ; self.product = ::Guid      ; register_factory! ; end
    class HostnameFactory  < StringFactory ; self.product = ::Hostname  ; register_factory! ; end
    class IpAddressFactory < StringFactory ; self.product = ::IpAddress ; register_factory! ; end

    class DateFactory  < ConvertingFactory
      self.product = Date
      FLAT_DATE_RE = /\A\d{8}Z?\z/
      register_factory!
      #
      def convert(obj)
        case obj
        when FLAT_DATE_RE  then product.new(obj[0..3].to_i, obj[4..5].to_i, obj[6..7].to_i)
        when Time          then Date.new(obj.year, obj.month, obj.day)
        when String        then Date.parse(obj)
        else                    mismatched!(obj)
        end
      rescue ArgumentError => err
        raise if err.is_a?(TypeMismatchError)
        warn "Cannot parse time #{obj}: #{err}"
        return nil
      end
    end

    class Boolean10Factory < BooleanFactory
      def self.typename() :boolean_10 ; end
      register_factory!   :boolean_10
      #
      def convert(obj)
        case obj.to_s
        when "0" then false
        when "1" then true
        else        super
        end
      end
    end

    class EpochTimeFactory < ConvertingFactory
      self.product = Integer
      def self.typename() :epoch_time ; end
      register_factory!   :epoch_time, EpochTime
      #
      def convert(obj)
        case obj
        when Numeric           then obj.to_f
        when Time              then obj.to_f
        when /\A\d{14}Z?\z/    then Time.parse(obj)
        when String            then Time.parse_safely(obj).to_f
        end
      end
    end

    class IntTimeFactory < EpochTimeFactory
      def self.typename() :int_time ; end
      register_factory!   :int_time, IntTime
      #
      def convert(obj)
        result = super
        result.nil? ? nil : result.to_i
      end
    end

    class SetFactory < EnumerableFactory
      self.product = Set
      register_factory!
    end

  end
end
