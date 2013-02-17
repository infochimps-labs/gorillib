#You must include childprocess in your gemfile. 
#Gorillib (intentionally) does not do so.
require 'childprocess'

module Gorillib
  module System
    module Runner
      extend self

      def run *args
        command = args.delete_at 0
        opts = args.delete_at -1 if args[-1].is_a? Hash
        process = ChildProcess.build(command,*args)
        process.io.inherit!
        process.start
        process
      end
    end
  end
end
