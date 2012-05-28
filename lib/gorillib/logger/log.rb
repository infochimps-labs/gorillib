require 'logger'

#
# A convenient logger.
#
# define Log yourself to prevent its creation
#
::Log = Logger.new($stderr) unless defined?(::Log)

# unless defined?(Log)
#   require 'log4r'
#   Log = Log4r::Logger.new('wukong')
#   Log.outputters = Log4r::Outputter.stderr
#   # require 'logger'
#   # Log = Logger.new(STDERR)
# end

# require 'log_buddy'; LogBuddy.init :log_to_stdout => false, :logger => Log
# LogBuddy::Utils.module_eval do
#   def arg_and_blk_debug(arg, blk)
#     result = eval(arg, blk.binding)
#     result_str = obj_to_string(result, :quote_strings => true)
#     LogBuddy.debug(%[#{arg} = #{result_str}])
#   end
# end


def Log.dump *args
  self.debug([
      args.map(&:inspect),
      caller.first
    ].join("\t"))
end unless Log.respond_to?(:dump)
