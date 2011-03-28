class Hash
  #
  # Create a hash from an array of keys and corresponding values.
  #
  def self.zip(keys, values, default=nil, &block)
    hash = block_given? ? Hash.new(&block) : Hash.new(default)
    keys.zip(values){|key,val| hash[key]=val }
    hash
  end unless respond_to?(:zip)
end
