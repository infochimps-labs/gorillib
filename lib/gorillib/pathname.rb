require 'pathname'
require 'gorillib/exception/raisers'

module Gorillib
  module Pathref
    ROOT_PATHS = Hash.new unless defined?(ROOT_PATHS)

    extend self

    def register_path(handle, *pathsegs)
      ArgumentError.arity_at_least!(pathsegs, 1)
      ROOT_PATHS[handle.to_sym] = pathsegs
    end

    def register_paths(handle_paths = {})
      handle_paths.each_pair{|handle, pathsegs| register_path(handle, *pathsegs) }
    end

    def register_default_paths(handle_paths = {})
      handle_paths.each_pair do |handle, pathsegs|
        register_path(handle, *pathsegs) unless ROOT_PATHS.has_key?(handle.to_sym)
      end
    end

    def unregister_path(handle)
      ROOT_PATHS.delete handle.to_sym
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
      relpath_to(*pathsegs).expand_path
    end

    # Expand a path with late-evaluated segments
    # @see `.path_to`
    #
    # Calls cleanpath (removing `//` double slashes and useless `..`s), but does
    # not reference the filesystem or make paths absolute
    #
    def relpath_to(*pathsegs)
      ArgumentError.arity_at_least!(pathsegs, 1)
      pathsegs = pathsegs.map{|ps| expand_pathseg(ps) }.flatten
      self.new(File.join(*pathsegs)).cleanpath(true)
    end
    alias_method :relative_path_to, :relpath_to

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
  extend Gorillib::Pathref
  class << self ; alias_method :new_pathname, :new ; end

  def self.receive(obj)
    return obj if obj.nil?
    obj.is_a?(self) ? obj : new(obj)
  end

  # @return the basename without extension (using self.extname as the extension)
  def corename
    basename(self.extname)
  end

  # @return [String] compact string rendering
  def inspect_compact() to_s.dump ; end

  # FIXME: find out if this is dangerous
  alias_method :to_str, :to_path
end
