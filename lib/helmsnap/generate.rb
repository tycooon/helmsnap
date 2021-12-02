# frozen_string_literal: true

class Helmsnap::Generate
  def self.call(...)
    new(...).call
  end

  def initialize(chart_path:, snapshots_path:, values_path:)
    self.chart_path = chart_path
    self.snapshots_path = snapshots_path
    self.values_path = values_path
  end

  def call
    Helmsnap::SetupDependencies.call(chart_path)

    FileUtils.rmtree(snapshots_path)

    run_cmd(
      "helm", "template", chart_path, "--values", values_path, "--output-dir", snapshots_path
    )

    snapshots_path.glob(["**/*yaml", "**/*.yml"]).each do |path|
      content = path.read
      content.gsub!(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\.\d+/, "2022-01-01 00:00:00.000") or next
      path.write(content)
    end
  end

  private

  attr_accessor :chart_path, :snapshots_path, :values_path

  def run_cmd(...)
    Helmsnap.run_cmd(...)
  end
end
