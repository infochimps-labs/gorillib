class Array
  #
  # Gets value of block on each element;
  # constructs a hash of element-value pairs
  #
  # @return [Hash] hash of key-value pairs
  def hashify
    raise ArgumentError, 'hashify requires a block' unless block_given?
    Hash[ self.map{|el| [el, yield(el)] } ]
  end
end
