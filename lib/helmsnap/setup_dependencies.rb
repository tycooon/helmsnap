# frozen_string_literal: true

class Helmsnap::SetupDependencies
  def self.call(...)
    new(...).call
  end

  def initialize(chart_path)
    self.chart_path = chart_path
  end

  def call
    dep_list = run_cmd("helm", "dependency", "list", "--max-col-width", 0, chart_path).output

    dep_list.scan(%r{file://(.+?)\t}) do |dep_path|
      run_cmd("helm", "dependency", "update", "--skip-refresh", chart_path.join(dep_path.first))
    end

    dep_list.scan(%r{(https?://.+?)\t}) do |dep_path|
      run_cmd("helm", "repo", "add", Digest::MD5.hexdigest(dep_path.first), dep_path.first)
    end

    run_cmd("helm", "dependency", "update", "--skip-refresh", chart_path)
  end

  private

  attr_accessor :chart_path

  def run_cmd(...)
    Helmsnap.run_cmd(...)
  end
end
