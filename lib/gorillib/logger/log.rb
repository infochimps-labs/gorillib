#
# A convenient logger.
#
# to override its creation, simply define the top-level constant `::Log`
#
unless defined?(::Log)
  require 'logger'
  ::Log = Logger.new($stderr)
end

def Log.dump *args
  self.debug([
      args.map(&:inspect),
      caller.first
    ].join("\t"))
end unless Log.respond_to?(:dump)



# TODO: allow swappable loggers more cleanly

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
