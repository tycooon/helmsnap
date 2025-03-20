# frozen_string_literal: true

class Helmsnap::Check < Helmsnap::Service
  def initialize(config, options)
    super()
    self.config = config
    self.options = options
  end

  def call
    temp_dir_path = Pathname.new(Dir.mktmpdir)

    Helmsnap::Generate.call(config, options, snapshots_path: temp_dir_path)

    result = run_cmd("which", "colordiff", allow_failure: true)
    util = result.success ? "colordiff" : "diff"

    cmd_parts = [util, "--unified", "--recursive", config.snapshots_path, temp_dir_path]
    diff = run_cmd(*cmd_parts, allow_failure: true).output

    diff.strip.empty?
  ensure
    FileUtils.rmtree(temp_dir_path)
  end

  private

  attr_accessor :config, :options
end
