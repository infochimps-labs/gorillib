module Gorillib
  module TestHelpers
    module_function

    def dummy_stdio(stdin_text=nil)
      stdin = stdin_text.nil? ? $stdin : StringIO.new(stdin_text)
      new_fhs = [stdin,  StringIO.new('', 'w'), StringIO.new('', 'w')]
      old_fhs = [$stdin, $stdout,               $stderr]
      begin
        $stdin, $stdout, $stderr = new_fhs
        yield
      ensure
        $stdin, $stdout, $stderr = old_fhs
      end
      new_fhs[1..2]
    end

    #
    # Temporarily sets the global variables $stderr and $stdout to a capturable StringIO;
    # restores them at the end, even if there is an error
    #
    def capture_output
      dummy_stdio{ yield }
    end

    alias_method :quiet_output, :capture_output
  end
end
