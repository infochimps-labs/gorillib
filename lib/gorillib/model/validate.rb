module Gorillib
  module Model
    module Validate
      module_function

      VALID_NAME_RE = /\A[A-Za-z_][A-Za-z0-9_]+\z/
      def identifier!(name)
        raise TypeError,     "can't convert #{name.class} into Symbol" unless name.respond_to? :to_sym
        raise ArgumentError, "Name must start with [A-Za-z_] and subsequently contain only [A-Za-z0-9_]" unless name =~ VALID_NAME_RE
      end

      def hashlike!(desc, val)
        return true if val.respond_to?(:[]) && val.respond_to?(:has_key?)
        raise ArgumentError, "#{desc} should be something that behaves like a hash: {#{val.inspect}}"
      end

      def included_in!(desc, val, colxn)
        raise ArgumentError, "#{desc} must be one of #{colxn.inspect}: got #{val.inspect}" unless colxn.include?(val)
      end
    end
  end
end
