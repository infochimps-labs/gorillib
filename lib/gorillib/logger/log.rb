require 'logger'

#
# A convenient logger.
#
# define Log yourself to prevent its creation
#
::Log = Logger.new(STDERR) unless defined?(::Log)

def Log.dump *args
  debug args.map(&:inspect).join("\t")
end unless Log.respond_to?(:dump)


