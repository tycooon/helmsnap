# frozen_string_literal: true

class Helmsnap::SetupDependencies < Helmsnap::Service
  def initialize(config)
    super()
    self.config = config
  end

  def call
    config.envs.flat_map(&:release_paths).uniq.each do |chart_path|
      setup!(chart_path)
    end
  end

  private

  attr_accessor :config

  def setup!(chart_path)
    dep_list = run_cmd("helm", "dependency", "list", "--max-col-width", 0, chart_path).output

    dep_list.scan(%r{file://(.+?)\t}) do |dep_path|
      run_cmd("helm", "dependency", "update", "--skip-refresh", chart_path.join(dep_path.first))
    end

    dep_list.scan(%r{(https?://.+?)\t}) do |dep_path|
      run_cmd("helm", "repo", "add", Digest::MD5.hexdigest(dep_path.first), dep_path.first)
    end

    run_cmd("helm", "dependency", "update", "--skip-refresh", chart_path)
  end
end
