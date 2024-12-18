# frozen_string_literal: true

class Helmsnap::Generate < Helmsnap::Service
  def initialize(config, snapshots_path: nil)
    super()
    self.config = config
    self.snapshots_path = snapshots_path || config.snapshots_path
  end

  def call
    Helmsnap::SetupDependencies.call(config)

    Dir.mktmpdir do |tmpdir|
      tmp_path = Pathname.new(tmpdir)
      generate!(tmp_path)
    end
  end

  private

  attr_accessor :config, :snapshots_path

  def generate!(tmp_path)
    config.envs.each do |env|
      run_cmd(
        "helmfile",
        "--environment",
        env.name,
        "template",
        "--output-dir-template",
        tmp_path.join(env.name, "{{ .Release.Name }}"),
        "--skip-deps",
      )
    end

    tmp_path.glob(["**/*yaml", "**/*.yml"]).each do |path|
      content = path.read
      content.gsub!(/\d\d\d\d-\d\d-\d\d \d\d:\d\d:\d\d\.\d+/, "2022-01-01 00:00:00.000")
      content.gsub!(/\d\d\d\d-\d\d-\d\d-\d\d-\d\d-\d\d/, "2022-01-01-00-00-00")
      content.gsub!(/\d\d\d\d-\d\d-\d\d-\d\d-\d\d/, "2022-01-01-00-00")
      path.write(content)
    end

    FileUtils.rmtree(snapshots_path)
    FileUtils.move(tmp_path, snapshots_path)
  end
end
