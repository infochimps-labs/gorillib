module Gorillib::CheckedPopen
  extend self

  def command_failed(err)
    raise err
  end

  # used for dependency injection in tests
  def _io_class() ::IO ; end ; private :_io_class

  #
  #    IO.checked_popen(commandline, options)              -> io
  #    IO.checked_popen(commandline, options){|io| block } -> obj
  #
  # Runs the specified command as a subprocess, without forking a shell; the
  # subprocess's standard input and output will be connected to the returned
  # <code>IO</code> object.
  #
  # The PID of the started process can be obtained by IO#pid method.
  #
  # @param commandline [Array[String]]    command name and zero or more arguments
  # @param options [Hash{Symbol=>Object}] options for popen and spawn
  #
  # @option options [String] :mode the mode for the process IO; can be modified by the spawn options. default is `"r"`.
  # @option options [String] :external_encoding
  # @param options [Hash] :env -- environment variables to set for the process
  #     name => val : set the environment variable
  #     name => nil : unset the environment variable
  # @param options [boolean] :unsetenv_others -- clears environment variables:
  #       :unsetenv_others => true   : clear environment variables except specified by env
  #       :unsetenv_others => false  : don't clear (default)
  # @param options [Object] :pgroup -- process group:
  #       :pgroup => true or 0 : make a new process group
  #       :pgroup => pgid      : join to specified process group
  #       :pgroup => nil       : don't change the process group (default)
  # @param options [Integer] :rlimit_cpu -- resource limit.  See Process.setrlimit.
  # @param options [Integer] :rlimit_core -- resource limit.  See Process.setrlimit.
  # @param options [Integer] :rlimit_data -- resource limit.  See Process.setrlimit.
  # @param options [Integer] rlimit_resourcename -- ... there are others; see Process.setrlimit.
  #       :rlimit_resourcename => limit
  #       :rlimit_resourcename => [cur_limit, max_limit]
  # @param options [String] chdir -- change into given directory before executing
  # @param options [Integer] umask -- permissions mask
  # @param options [Hash] :in  -- redirection
  # @param options [Hash] :out -- redirection
  # @param options [Hash] :err -- redirection
  #       key:
  #         FD              : single file descriptor in child process
  #         [FD, FD, ...]   : multiple file descriptor in child process
  #       value:
  #         FD                        : redirect to the file descriptor in parent process
  #         string                    : redirect to file with open(string, "r" or "w")
  #         [string]                  : redirect to file with open(string, File::RDONLY)
  #         [string, open_mode]       : redirect to file with open(string, open_mode, 0644)
  #         [string, open_mode, perm] : redirect to file with open(string, open_mode, perm)
  #         [:child, FD]              : redirect to the redirected file descriptor
  #         :close                    : close the file descriptor in child process
  #       FD is one of follows
  #         :in     : the file descriptor 0 which is the standard input
  #         :out    : the file descriptor 1 which is the standard output
  #         :err    : the file descriptor 2 which is the standard error
  #         integer : the file descriptor of specified the integer
  #         io      : the file descriptor specified as io.fileno
  #
  # @param options [boolean] :close_others -- file descriptor inheritance: close non-redirected non-standard fds (3, 4, 5, ...) or not
  #       :close_others => false : inherit fds
  #       :close_others => true  : don't inherit (default)
  #
  # @example set IO encoding
  #   IO.checked_popen(['nkf', '-e', filename], :external_encoding=>"EUC-JP"){|nkf_io|
  #     euc_jp_string = nkf_io.read
  #   }
  #
  # @example merge standard output and standard error using spawn option.  See the document of Kernel.spawn.
  #   IO.popen(["ls", "/"], :err => [:child, :out]){|ls_io|
  #     ls_result_with_error = ls_io.read
  #   }
  #
  # @raise exceptions which <code>IO.pipe</code> and <code>Kernel.spawn</code> raise
  #
  # If a block is given, Ruby will run the command as a child connected to Ruby
  # with a pipe. Ruby's end of the pipe will be passed as a parameter to the
  # block.  At the end of block, Ruby close the pipe and sets <code>$?</code>.
  # In this case <code>IO.popen</code> returns the value of the block.
  #
  # @overload: checked_popen(commandline, options={})
  #   @return the IO object for the process
  # @overload: checked_popen(commandline, options={}, &block)
  #   @return the return value of the block
  #
  def checked_popen(commandline, options={}, &block)
    raise ArgumentError, "commandline must be an array of strings: #{commandline}" unless commandline.is_a?(Array)
    raise ArgumentError, "Don't use this for the forking version: #{commandline} should not start with '-'"  if commandline.first.to_s == '-'
    commandline = commandline.map(&:to_s)
    options     = options.reverse_merge(
      env: {}, mode: nil, fail_action: method(:command_failed),
      out: 1, err: 2
      )
    env         = options.delete(:env)
    mode        = options.delete(:mode)
    fail_action = options.delete(:fail_action)
    command     = commandline.shift
    argv_0      = options.delete(:argv_0){ command }
    check_child_exit_status do
      _io_class.popen([env, [command, argv_0], *commandline], mode, &block)
    end
  rescue Errno::EPIPE => err
    fail_action.call(err)
  end

  # @private
  NO_EXIT_STATUS = OpenStruct.new(:exitstatus => 0)

  def check_child_exit_status
    result = yield
    status = $? || NO_EXIT_STATUS
    unless [0].include?(status.exitstatus)
      raise ArgumentError, "Command exited with status '#{status.exitstatus}'"
    end
    result
  end

end

::IO.class_eval do
  extend Gorillib::CheckedPopen
end
