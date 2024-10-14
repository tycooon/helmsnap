# frozen_string_literal: true

class Helmsnap::SetupDependencies < Helmsnap::Service
  REPO_NAME_PREFIX = "helmsnap-"

  def initialize(config)
    super()
    self.config = config
    self.processed_paths = Set.new
  end

  def call
    clear_existing_repos!

    config.envs.flat_map(&:release_paths).each do |chart_path|
      setup!(chart_path)
    end
  end

  private

  attr_accessor :config, :processed_paths

  def clear_existing_repos!
    result = run_cmd("helm", "repo", "ls").output

    result.scan(/#{REPO_NAME_PREFIX}\S+/o) do |repo_name|
      run_cmd("helm", "repo", "remove", repo_name)
    end
  end

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
      url = dep_path.first

      if (credentials = config.credentials[url])
        extra_args = ["--username", credentials.username, "--password", credentials.password]
      end

      repo_name = "#{REPO_NAME_PREFIX}#{Digest::MD5.hexdigest(url)}"
      run_cmd("helm", "repo", "add", repo_name, url, *extra_args)
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
