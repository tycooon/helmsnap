# frozen_string_literal: true

class Helmsnap::Generate < Helmsnap::Service
  def initialize(config, snapshots_path: nil)
    super()
    self.config = config
    self.snapshots_path = snapshots_path || config.snapshots_path
  end

  def call
    FileUtils.rmtree(snapshots_path)

    Helmsnap::SetupDependencies.call(config)

    config.envs.each do |env|
      run_cmd(
        "helmfile",
        "--environment",
        env.name,
        "template",
        "--output-dir-template",
        snapshots_path.join(env.name).join("{{ .Release.Name }}"),
        "--skip-deps",
      )
    end

    snapshots_path.glob(["**/*yaml", "**/*.yml"]).each do |path|
      content = path.read
      content.gsub!(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\.\d+/, "2022-01-01 00:00:00.000") or next
      path.write(content)
    end
  end

  private

  attr_accessor :config, :snapshots_path
end
