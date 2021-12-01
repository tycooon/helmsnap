# frozen_string_literal: true

class Helmsnap::Check
  def self.call(...)
    new(...).call
  end

  def initialize(chart_path:, snapshots_path:, values_path:)
    self.chart_path = chart_path
    self.snapshots_path = snapshots_path
    self.values_path = values_path
  end

  def call
    temp_dir_path = Pathname.new(Dir.mktmpdir)

    Helmsnap::Generate.call(
      chart_path: chart_path,
      snapshots_path: temp_dir_path,
      values_path: values_path,
    )

    result = Helmsnap.run_cmd("which", "colordiff", allow_failure: true)
    util = result.success ? "colordiff" : "diff"

    cmd_parts = [util, "--unified", "--recursive", snapshots_path, temp_dir_path]
    diff = Helmsnap.run_cmd(*cmd_parts, allow_failure: true).output

    diff.strip.empty?
  ensure
    FileUtils.rmtree(temp_dir_path)
  end

  private

  attr_accessor :chart_path, :snapshots_path, :values_path
end
