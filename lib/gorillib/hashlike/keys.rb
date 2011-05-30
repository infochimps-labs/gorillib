module Gorillib
  module Hashlike
    module Keys
      # Return a new hash with all keys converted to strings.
      def stringify_keys
        dup.stringify_keys!
      end unless method_defined?(:stringify_keys)

      # Destructively convert all keys to strings.
      def stringify_keys!
        keys.each do |key|
          self[key.to_s] = delete(key)
        end
        self
      end unless method_defined?(:stringify_keys!)

      # Return a new hash with all keys converted to symbols, as long as
      # they respond to +to_sym+.
      def symbolize_keys
        dup.symbolize_keys!
      end unless method_defined?(:symbolize_keys)

      # Destructively convert all keys to symbols, as long as they respond
      # to +to_sym+.
      def symbolize_keys!
        keys.each do |key|
          self[(key.to_sym rescue key) || key] = delete(key)
        end
        self
      end unless method_defined?(:symbolize_keys!)

      # Validate all keys in a hash match *valid keys, raising ArgumentError on a mismatch.
      # Note that keys are NOT treated indifferently, meaning if you use strings for keys but assert symbols
      # as keys, this will fail.
      #
      # ==== Examples
      #   { :name => "Rob", :years => "28" }.assert_valid_keys(:name, :age) # => raises "ArgumentError: Unknown key(s): years"
      #   { :name => "Rob", :age => "28" }.assert_valid_keys("name", "age") # => raises "ArgumentError: Unknown key(s): name, age"
      #   { :name => "Rob", :age => "28" }.assert_valid_keys(:name, :age) # => passes, raises nothing
      def assert_valid_keys(*valid_keys)
        unknown_keys = keys - [valid_keys].flatten
        raise(ArgumentError, "Unknown key(s): #{unknown_keys.join(", ")}") unless unknown_keys.empty?
      end unless method_defined?(:assert_valid_keys)
    end
    # # @return [Hash] the object as a Hash with symbolized keys.
    # def symbolize_keys() to_hash ; end
    # # @return [Hash] the object as a Hash with string keys.
    # def stringify_keys() to_hash.stringify_keys ; end
    #
    # # Used to provide the same interface as Hash.
    # # @return This object unchanged.
    # def symbolize_keys!; self end
    #
    # # Used to provide the same interface as Hash.
    # # @return This object unchanged.
    # def stringify_keys!; self end
    #
  end
end
