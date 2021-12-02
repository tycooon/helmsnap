# frozen_string_literal: true

class Helmsnap::Command
  Result = Struct.new(:success, :output)

  def self.call(...)
    new(...).call
  end

  def initialize(cmd, stdout: $stdout, stderr: $stderr, allow_failure: false)
    self.cmd = cmd
    self.output = +""
    self.stdout = stdout
    self.stderr = stderr
    self.allow_failure = allow_failure
  end

  def call
    Helmsnap::Console.info(stdout, "> #{cmd}")
    run_command
  end

  private

  attr_accessor :cmd, :output, :stdout, :stderr, :allow_failure

  def run_command
    Open3.popen3(cmd) do |_in, out, err, wait_thr|
      while (chunk = out.gets)
        Helmsnap::Console.print(stdout, chunk)
        output << chunk
      end

      exit_status = wait_thr.value
      success = exit_status.success?
      handle_error!(exit_status, err.read) unless success

      Helmsnap::Console.print(stdout, "\n")
      Result.new(success, output)
    end
  rescue SystemCallError => error
    handle_error!(error.errno, error.message)
    Result.new(false, error.message)
  end

  def handle_error!(exit_status, err_output)
    Helmsnap::Console.error(stderr, err_output)

    if allow_failure
      output << err_output
    else
      Helmsnap::Console.error(stderr, "Command failed with status #{exit_status.to_i}")
      exit 1
    end
  end
end
