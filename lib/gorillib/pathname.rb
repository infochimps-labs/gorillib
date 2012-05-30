require 'pathname'
require 'gorillib/exception/raisers'

module Gorillib::Pathname
  module Pathref
    ROOT_PATHS = Hash.new unless defined?(ROOT_PATHS)

    extend self

    def register_path(handle, *pathsegs)
      ArgumentError.arity_at_least!(pathsegs, 1)
      ROOT_PATHS[handle] = pathsegs
    end

    def register_paths(pairs = {})
      pairs.each_pair{ |handle, pathsegs| register_path(handle, *pathsegs) }
    end

    def unregister_path handle
      ROOT_PATHS.delete handle
    end
    
    # Expand a path with late-evaluated segments.
    # Calls expand_path -- '~' becomes $HOME, '..' is expanded, etc.
    #
    # @example A symbol represents a segment to expand
    #     Pathname.register_path(:conf_dir, '/etc/delorean')
    #     Pathname.path_to(:conf_dir)                  # '/etc/delorean'
    #     Pathname.path_to(:conf_dir, modacity.conf)   # '/etc/delorean/modacity.conf'
    #
    # @example References aren't expanded until they're read
    #     Pathname.register_path(:conf_dir, '/etc/delorean')
    #     Pathname.register_path(:modacity, :conf_dir, 'modacity.conf')
    #     Pathname.path_to(:modacity)                  # '/etc/delorean/modacity.conf'
    #     # if we change the conf_dir, everything under it changes as well
    #     Pathname.register_path(:conf_dir, '~/.delorean.d')
    #     Pathname.path_to(:modacity)                  # '/home/flip/delorean.d/modacity.conf'
    #
    # @example References can be relative, and can hold symbols themselves
    #     Pathname.register_path(:conf_dir, '/etc', :appname, :environment)
    #     Pathname.register_path(:appname, 'happy_app')
    #     Pathname.register_path(:environment, 'dev')
    #     Pathname.path_to(:conf_dir)                  # '/etc/happy_app/dev'
    #
    # @param  [Array<[String,Symbol]>] pathsegs 
    #   any mixture of strings (literal sub-paths) and symbols (interpreted as references)
    # @return [Pathname] A single expanded Pathname
    #
    def path_to(*pathsegs)
      relative_path_to(*pathsegs).expand_path
    end

    # Expand a path with late-evaluated segments
    # @see `.path_to`
    #
    # Calls cleanpath (removing `//` double slashes and useless `..`s), but does
    # not reference the filesystem or make paths absolute
    #
    def relative_path_to(*pathsegs)
      ArgumentError.arity_at_least!(pathsegs, 1)
      pathsegs = pathsegs.map{|ps| expand_pathseg(ps) }.flatten
      new(File.join(*pathsegs)).cleanpath(true)
    end

  protected
    # Recursively expand a path handle 
    # @return [Array<String>] an array of path segments, suitable for .join
    def expand_pathseg(handle)
      return handle unless handle.is_a?(Symbol)
      pathsegs = ROOT_PATHS[handle] or raise ArgumentError, "Don't know how to expand path reference '#{handle.inspect}'."
      pathsegs.map{|ps| expand_pathseg(ps) }.flatten
    end
  end
end

class Pathname
  extend Gorillib::Pathname::Pathref
end
