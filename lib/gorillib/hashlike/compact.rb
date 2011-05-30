require 'gorillib/object/blank'
module Gorillib
  module Hashlike
    module Compact

      # returns a compact!ed copy (contains no key/value pairs having nil? values)
      #
      # @example
      #     hsh = { :a => 100, :b => nil, :c => false, :d => "" }
      #     hsh.compact # => { :a => 100, :c => false, :d => "" }
      #     hsh         # => { :a => 100, :b => nil, :c => false, :d => "" }
      #
      # @return [Hashlike]
      #
      def compact
        reject{|key,val| val.nil? }
      end

      # Removes all key/value pairs having nil? values
      #
      # @example
      #     hsh = { :a => 100, :b => nil, :c => false, :d => "" }
      #     hsh.compact # => { :a => 100, :c => false, :d => "" }
      #     hsh         # => { :a => 100, :c => false, :d => "" }
      #
      # @return [Hashlike]
      #
      def compact!
        delete_if{|key,val| val.nil? }
      end

      # returns a compact!ed copy (contains no key/value pairs having blank? values)
      #
      # @example
      #     hsh = { :a => 100, :b => nil, :c => false, :d => "" }
      #     hsh.compact # => { :a => 100 }
      #     hsh         # => { :a => 100, :b => nil, :c => false, :d => "" }
      #
      # @return [Hashlike]
      #
      def compact_blank
        reject{|key,val| val.blank? }
      end

      # Removes all key/value pairs having blank? values
      #
      # @example
      #     hsh = { :a => 100, :b => nil, :c => false, :d => "" }
      #     hsh.compact # => { :a => 100 }
      #     hsh         # => { :a => 100 }
      #
      # @return [Hashlike]
      #
      def compact_blank!
        delete_if{|key,val| val.blank? }
      end

    end
  end
end
