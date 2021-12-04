# frozen_string_literal: true

class Helmsnap::Config
  attr_reader :envs, :snapshots_path

  DEFAULT_ENV = "default"

  def initialize(config_path)
    yaml = YAML.load_file(config_path.to_s)
    self.envs = parse_envs(yaml)
    self.snapshots_path = parse_snaphots_path(yaml)
  end

  private

  attr_writer :envs, :snapshots_path

  def parse_envs(yaml)
    # TODO: check value type
    value = yaml.fetch("envs", [DEFAULT_ENV])
    value.map { |x| Helmsnap::Env.new(x) }
  end

  def parse_snaphots_path(yaml)
    # TODO: chekc value type/presence
    Pathname.new(yaml.fetch("snapshotsPath"))
  end
end
