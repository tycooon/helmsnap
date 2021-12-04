# frozen_string_literal: true

class Helmsnap::Config
  attr_reader :envs, :snapshots_path

  DEFAULT_ENV = "default"
  DEFAULT_SNAPSHOTS_PATH = "helm/snapshots"

  def initialize(config_path)
    if config_path.exist?
      yaml = YAML.load_file(config_path.to_s)
    else
      yaml = {}
    end

    self.envs = parse_envs(yaml)
    self.snapshots_path = parse_snaphots_path(yaml)
  end

  private

  attr_writer :envs, :snapshots_path

  def parse_envs(yaml)
    value = yaml.fetch("envs", [DEFAULT_ENV])
    value.map { |x| Helmsnap::Env.new(x) }
  end

  def parse_snaphots_path(yaml)
    Pathname.new(yaml.fetch("snapshotsPath", DEFAULT_SNAPSHOTS_PATH))
  end
end
