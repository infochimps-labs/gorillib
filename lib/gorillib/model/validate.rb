module Gorillib
  module Model
    module Validate
      module_function

      VALID_NAME_RE = /\A[A-Za-z_][A-Za-z0-9_]*\z/
      def identifier!(name)
        raise TypeError,     "can't convert #{name.class} into Symbol", caller unless name.respond_to? :to_sym
        raise ArgumentError, "Name must start with [A-Za-z_] and subsequently contain only [A-Za-z0-9_]", caller unless name =~ VALID_NAME_RE
      end

      def hashlike!(val)
        return true if val.respond_to?(:[]) && val.respond_to?(:has_key?)
        raise ArgumentError, "#{block_given? ? yield : 'value'} should be something that behaves like a hash: #{val.inspect}", caller
      end

      def included_in!(desc, val, colxn)
        raise ArgumentError, "#{desc} must be one of #{colxn.inspect}: got #{val.inspect}", caller unless colxn.include?(val)
      end
    end
  end
end
