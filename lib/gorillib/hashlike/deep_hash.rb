require 'gorillib/hashlike/deep_merge'
require 'gorillib/hashlike/deep_compact'
require 'gorillib/hashlike/deep_dup'

module Gorillib
  module Hashlike
    module DeepHash

      include Gorillib::Hashlike::DeepMerge
      include Gorillib::Hashlike::DeepCompact
      include Gorillib::Hashlike::DeepDup

      # @param constructor<Object>
      #   The default value for the DeepHash. Defaults to an empty hash.
      #   If constructor is a Hash, adopt its values.
      def initialize(constructor = {})
        if constructor.is_a?(Hash)
          super()
          deep_merge!(constructor) unless constructor.empty?
        else
          super(constructor)
        end
      end

      def self.included(base)
        base.class_eval do
          unless method_defined?(:regular_writer) then alias_method :regular_writer, :[]=  ; end
          unless method_defined?(:regular_update) then alias_method :regular_update, :update  ; end
        end
      end

      # Sets a member value.
      #
      # Given a deep key (one that contains '.'), uses it as a chain of hash
      # memberships. Otherwise calls the normal hash member setter
      #
      # @example
      #   foo = DeepHash.new :hi => 'there'
      #   foo['howdy.doody'] = 3
      #   foo # => { :hi => 'there', :howdy => { :doody => 3 } }
      #
      def []= attr, val
        attr = convert_key(attr)
        val  = convert_value(val)
        attr.is_a?(Array) ? deep_set(*(attr | [val])) : super(attr, val)
      end


      # Gets a member value.
      #
      # Given a deep key (one that contains '.'), uses it as a chain of hash
      # memberships. Otherwise calls the normal hash member getter
      #
      # @example
      #   foo = DeepHash.new({ :hi => 'there', :howdy => { :doody => 3 } })
      #   foo['howdy.doody'] # => 3
      #   foo['hi']          # => 'there'
      #   foo[:hi]           # => 'there'
      #
      def [] attr
        attr = convert_key(attr)
        attr.is_a?(Array) ? deep_get(*attr) : super(attr)
      end

      #
      # Treat hash as tree of hashes:
      #
      #     x = { :a => :val, :subhash => { :b => :val_b } }
      #     x.deep_set(:subhash, :cat, :hat)
      #     # => { :a => :val, :subhash => { :b => :val_b,   :cat => :hat } }
      #     x.deep_set(:subhash, :b, :newval)
      #     # => { :a => :val, :subhash => { :b => :newval, :cat => :hat } }
      #
      #
      def deep_set *args
        val      = args.pop
        last_key = args.pop
        # dig down to last subtree (building out if necessary)
        hsh = self
        args.each  do |key|
          hsh.regular_writer(key, self.class.new) unless hsh.has_key?(key)
          hsh = hsh[key]
        end
        # set leaf value
        hsh[last_key] = val
      end

      #
      # Treat hash as tree of hashes:
      #
      #     x = { :a => :val_a, :subhash => { :b => :val_b } }
      #     x.deep_get(:a)
      #     # => :val_a
      #     x.deep_get(:subhash, :c)
      #     # => nil
      #     x.deep_get(:subhash, :c, :f)
      #     # => nil
      #     x.deep_get(:subhash, :b)
      #     # => nil
      #
      def deep_get *args
        last_key = args.pop
        # dig down to last subtree (building out if necessary)
        hsh = args.inject(self){|h, k| h[k] || self.class.new }
        # get leaf value
        hsh[last_key]
      end

      #
      # Treat hash as tree of hashes:
      #
      #     x = { :a => :val, :subhash => { :a => :val1, :b => :val2 } }
      #     x.deep_delete(:subhash, :a)
      #     #=> :val
      #     x
      #     #=> { :a => :val, :subhash => { :b => :val2 } }
      #
      def deep_delete *args
        last_key  = args.pop                                   # key to delete
        last_hsh  = args.empty? ? self : (deep_get(*args)||{}) # hsh containing that key
        last_hsh.delete(last_key)
      end

      protected
      # @attr key<Object> The key to convert.
      #
      # @attr [Object]
      #   The converted key. A dotted attr ('moon.cheese.type') becomes
      #   an array of sequential keys for deep_set and deep_get
      #
      # @private
      def convert_key(attr)
        case
        when attr.to_s.include?('.')   then attr.to_s.split(".").map{|sub_attr| sub_attr.to_sym }
        when attr.is_a?(Array)         then attr.map{|sub_attr| sub_attr.to_sym }
        else                                attr.to_sym
        end
      end

      # @param value<Object> The value to convert.
      #
      # @return [Object]
      #   The converted value. A Hash or an Array of hashes, will be converted to
      #   their DeepHash equivalents.
      #
      # @private
      def convert_value(value)
        if value.class == Hash   then self.class.new(value)
        elsif value.is_a?(Array) then value.collect{|e| convert_value(e) }
        else                          value
        end
      end
    end

  end
end
