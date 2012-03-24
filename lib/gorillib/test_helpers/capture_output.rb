module Gorillib
  module TestHelpers
    module_function

    #
    # Temporarily sets the global variables $stderr and $stdout to a capturable StringIO;
    # restores them at the end, even if there is an error
    #
    def capture_output
      local_stdout = StringIO.new('', 'w')
      local_stderr = StringIO.new('', 'w')

      begin
        old_stdout = $stdout ; $stdout = local_stdout
        old_stderr = $stderr ; $stderr = local_stderr

        yield

        $stdout = old_stdout
        $stderr = old_stderr
        return [local_stdout, local_stderr]
      ensure
        $stdout = old_stdout
        $stderr = old_stderr
      end
    end

    alias_method :quiet_output, :capture_output
  end
end
