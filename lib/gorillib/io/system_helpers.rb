module Gorillib::CheckedPopen
  module_function

  def checked_popen(command, mode, fail_action, io_class=IO)
    check_child_exit_status do
      io_class.popen(command, mode) do |process|
        yield(process)
      end
    end
  rescue Errno::EPIPE
    fail_action.call
  end

  # @private
  NO_EXIT_STATUS = OpenStruct.new(:exitstatus => 0)

  def check_child_exit_status
    result = yield
    status = $? || NO_EXIT_STATUS
    unless [0, 172].include?(status.exitstatus)
      raise ArgumentError, "Command exited with status '#{status.exitstatus}'"
    end
    result
  end

end

::IO.class_eval do
  include Gorillib::CheckedPopen
end
