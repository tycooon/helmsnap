# frozen_string_literal: true

class Helmsnap::Command
  Result = Struct.new(:success, :output)

  def self.call(...)
    new(...).call
  end

  def initialize(cmd, stdout: $stdout, stderr: $stderr, allow_failure: false)
    self.cmd = cmd
    self.stdout = stdout
    self.stderr = stderr
    self.allow_failure = allow_failure
  end

  def call
    puts "\e[1m\e[33m#{cmd}\e[0m\e[22m"
    run_command
  end

  private

  attr_accessor :cmd, :stdout, :stderr, :allow_failure

  def run_command
    Open3.popen3(cmd) do |_in, out, err, wait_thr|
      output = +""

      while (chunk = out.gets)
        stdout.print(chunk)
        output << chunk
      end

      exit_status = wait_thr.value
      success = exit_status.success?

      if !success && !allow_failure
        stderr.print(err.read)
        abort "Command failed with status #{exit_status.to_i}"
      end

      stdout.puts
      Result.new(success, output)
    end
  end
end
