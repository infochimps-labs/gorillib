require 'logger'

#
# A convenient logger.
#
# define Log yourself to prevent its creation
#
::Log = Logger.new($stderr) unless defined?(::Log)

def Log.dump *args
  self.debug([
      args.map(&:inspect),
      caller.first
    ].join("\t"))
end unless Log.respond_to?(:dump)
