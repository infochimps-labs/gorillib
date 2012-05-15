require 'pathname'
require 'gorillib/exception/raisers'

module Gorillib::Pathname
  module Template
    ROOT_PATHS = Hash.new unless defined?(ROOT_PATHS)

    extend self

    def register_path(handle, *pathsegs)
      ArgumentError.arity_at_least!(pathsegs, 1)
      ROOT_PATHS[handle] = pathsegs
    end

    def path_to(*pathsegs)
      ArgumentError.arity_at_least!(pathsegs, 1)
      pathsegs = pathsegs.map{|ps| expand_pathseg(ps) }.flatten
      dir = pathsegs.shift
      new(File.expand_path(File.join(*pathsegs), dir))
    end

  protected
    def expand_pathseg(handle)
      return handle unless handle.is_a?(Symbol)
      pathsegs = ROOT_PATHS[handle] or raise ArgumentError, "Don't know how to expand path reference '#{handle.inspect}'."
      pathsegs.map{|ps| expand_pathseg(ps) }.flatten
    end
  end
end

class Pathname
  extend Gorillib::Pathname::Template
end
