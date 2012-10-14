class Pathname
  # same as `#exist?`
  def exists?(*args) exist?(*args) ; end

  # @example It chains nicely:
  #   # put each file in eg. dest/f/foo.json
  #   Pathname.of(:dest, slug[0..0], "#{slug}.json").mkparent.open('w') do |file|
  #     # ...
  #   end
  #
  # @returns the path itself (not its parent)
  def mkparent
    dirname.mkpath
    return self
  end

  #
  # Executes the block (passing the opened file) if the file does not
  # exist. Ignores the block otherwise. The block is required.
  #
  # @param options
  # @option options[:force] Force creation of the file
  #
  # @returns the path itself (not the file)
  def if_missing(options={}, &block)
    ArgumentError.block_required!(block)
    return self if exist? && (not options[:force])
    #
    mkparent
    open((options[:mode] || 'w'), &block)
    return self
  end

end
