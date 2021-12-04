# frozen_string_literal: true

class Helmsnap::Env
  attr_reader :name, :release_paths

  def initialize(name)
    self.name = name
    self.release_paths = get_release_paths
  end

  private

  attr_writer :name, :release_paths

  def get_release_paths
    json = Helmsnap.run_cmd("helmfile", "--environment", name, "list", "--output", "json").output
    YAML.load(json).map { |x| x.fetch("chart") }
  end
end
