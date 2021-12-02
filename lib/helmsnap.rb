# frozen_string_literal: true

require "digest"
require "fileutils"
require "open3"
require "optparse"
require "pathname"
require "shellwords"
require "tmpdir"

require "colorized_string"

module Helmsnap
  require_relative "helmsnap/args_parser"
  require_relative "helmsnap/check"
  require_relative "helmsnap/command"
  require_relative "helmsnap/console"
  require_relative "helmsnap/generate"
  require_relative "helmsnap/setup_dependencies"
  require_relative "helmsnap/runner"
  require_relative "helmsnap/version"

  class Error < StandardError; end

  def self.run_cmd(*cmd_parts, **options)
    cmd = Shellwords.join(cmd_parts)
    Helmsnap::Command.call(cmd, **options)
  end
end
