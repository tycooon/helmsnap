# frozen_string_literal: true

class Helmsnap::Env
  attr_reader :name

  def initialize(name)
    self.name = name
  end

  def release_paths
    @release_paths ||= begin
      json = Helmsnap.run_cmd("helmfile", "--environment", name, "list", "--output", "json").output
      YAML.load(json).map { |x| Pathname.new(x.fetch("chart")) }
    end
  end

  private

  attr_writer :name
end
