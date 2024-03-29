# frozen_string_literal: true

class Helmsnap::SetupDependencies < Helmsnap::Service
  def initialize(config)
    super()
    self.config = config
    self.processed_paths = Set.new
  end

  def call
    config.envs.flat_map(&:release_paths).each do |chart_path|
      setup!(chart_path)
    end
  end

  private

  attr_accessor :config, :processed_paths

  def setup!(chart_path)
    normalized_path = chart_path.expand_path
    return if processed_paths.include?(normalized_path)
    processed_paths << normalized_path

    dep_list = get_dependency_list(chart_path)

    dep_list.scan(%r{file://(.+?)\s}) do |dep_path|
      subchart_path = chart_path.join(dep_path.first)
      setup!(subchart_path)
    end

    dep_list.scan(%r{(https?://.+?)\s}) do |dep_path|
      run_cmd("helm", "repo", "add", Digest::MD5.hexdigest(dep_path.first), dep_path.first)
    end

    update_deps!(chart_path)
  end

  def get_dependency_list(chart_path)
    base_cmd = ["helm", "dependency", "list", chart_path]

    result = run_cmd(*base_cmd, "--max-col-width", 0, allow_failure: true, stderr: nil)

    if result.success
      result.output
    else
      run_cmd(*base_cmd).output.tap do
        Helmsnap::Console.warning(
          $stderr, "it looks like your Helm binary is outdated, please update.\n"
        )
      end
    end
  end

  def update_deps!(chart_path)
    base_cmd = ["helm", "dependency", "update", chart_path]
    result = run_cmd(*base_cmd, "--skip-refresh", allow_failure: true)
    run_cmd(*base_cmd) unless result.success # Try with deps refresh in case of any failure
    true
  end
end
