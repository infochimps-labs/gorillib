class Hash
  # Slice a hash to include only the given allowed_keys. This is useful for
  # limiting an options hash to valid keys before passing to a method:
  #
  #   def search(criteria = {})
  #     assert_valid_keys(:mass, :velocity, :time)
  #   end
  #
  #   search(options.slice(:mass, :velocity, :time))
  #
  # If you have an array of keys you want to limit to, you should splat them:
  #
  #   valid_keys = [:mass, :velocity, :time]
  #   search(options.slice(*valid_keys))
  def slice(*allowed_keys)
    allowed_keys = allowed_keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
    hash = self.class.new
    allowed_keys.each{|k| hash[k] = self[k] if has_key?(k) }
    hash
  end unless method_defined?(:slice)

  # Replaces the hash with only the given allowed_keys.
  # Returns a hash containing the removed key/value pairs
  # @example
  #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
  #   hsh.slice!(:a, :b)
  #   # => {:c => 3, :d =>4}
  #   hsh
  #   # => {:a => 1, :b => 2}
  def slice!(*allowed_keys)
    allowed_keys = allowed_keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
    omit = slice(*self.keys - allowed_keys)
    hash = slice(*allowed_keys)
    replace(hash)
    omit
  end unless method_defined?(:slice!)

  # This also works, and doesn't require #replace method, but is uglier and
  # wasn't written by Railsians.  I'm not sure that slice! is interesting if
  # you're a duck-typed Hash but not is_a?(Hash), so we'll just leave it at the
  # active_record implementation.
  #
  # def slice!(*allowed_keys)
  #   allowed_keys = allowed_keys.map!{|key| convert_key(key) } if respond_to?(:convert_key)
  #   omit_keys = self.keys - allowed_keys
  #   omit = slice(*omit_keys)
  #   omit_keys.each{|k| delete(k) }
  #   omit
  # end

  # Removes the given allowed_keys from the hash
  # Returns a hash containing the removed key/value pairs
  #
  # @example
  #   hsh = {:a => 1, :b => 2, :c => 3, :d => 4}
  #   hsh.extract!(:a, :b)
  #   # => {:a => 1, :b => 2}
  #   hsh
  #   # => {:c => 3, :d =>4}
  def extract!(*allowed_keys)
    slice!(*self.keys - allowed_keys)
  end unless method_defined?(:extract!)
end

