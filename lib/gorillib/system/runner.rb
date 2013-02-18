#You must include childprocess in your gemfile. 
#Gorillib (intentionally) does not do so.
require 'childprocess'
require 'tempfile'

module Gorillib
  module System
    module Runner
      extend self

      def run(args, options={})
        options = options.reverse_merge(mirror_io: false)
        process = ChildProcess.build(*args)
        out = Tempfile.new('gorillib-runner-out')
        err = Tempfile.new('gorillib-runner-err')
        process.io.stdout = out
        process.io.stderr = err
        process.start
        process.wait
        begin 
          out.rewind ; err.rewind
          res = [out.read, err.read, process.exit_code]
          if options[:mirror_io]
            $stdout.write res[0]
            $stderr.write res[1]
          end
        ensure
          out.close ; err.close
          out.unlink ; err.unlink
        end
        res
      end

    end
  end
end
