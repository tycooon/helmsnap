# frozen_string_literal: true

class Helmsnap::Command
  def self.call(...)
    new(...).call
  end

  def initialize(cmd)
    self.cmd = cmd
  end

  def call
    puts "\e[1m\e[33m#{cmd}\e[0m\e[22m"

    Open3.popen3(cmd) do |_stdin, stdout, stderr, wait_thr|
      output = +""

      while (chunk = stdout.gets)
        $stdout.print(chunk)
        output << chunk
      end

      exit_status = wait_thr.value

      unless exit_status.success?
        $stderr.print(stderr.read)
        abort "Command failed with status #{exit_status.to_i}"
      end

      puts
      output
    end
  end

  private

  attr_accessor :cmd
end
