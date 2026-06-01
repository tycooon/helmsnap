# frozen_string_literal: true

RSpec.describe Helmsnap::SetupDependencies do
  subject(:service) { described_class.new(config, options) }

  let(:options) { Helmsnap::ArgsParser::Args.new(nil, true) }
  let(:config) { instance_double(Helmsnap::Config, envs: [env], credentials: []) }
  let(:env) { instance_double(Helmsnap::Env, release_paths: release_paths) }

  # Intercept all shell commands so the spec never spawns helm/helmfile.
  before do
    allow(Helmsnap).to receive(:run_cmd).and_return(
      instance_double(Helmsnap::Command::Result, success: true, output: ""),
    )
  end

  context "when all releases use local charts" do
    let(:release_paths) { [Pathname.new(__dir__)] } # existing local dir

    it "runs helm dependency list for the local chart" do
      service.call
      expect(Helmsnap).to have_received(:run_cmd).with(
        "helm", "dependency", "list", Pathname.new(__dir__),
        "--max-col-width", 0,
        allow_failure: true, stderr: nil
      )
    end
  end

  context "when a release uses a remote chart (e.g. bitnami/postgresql)" do
    let(:release_paths) { [Pathname.new("bitnami/postgresql")] }

    it "does not run helm dependency list for the remote chart" do
      service.call
      expect(Helmsnap).not_to have_received(:run_cmd).with(
        "helm", "dependency", "list", anything, anything
      )
    end

    it "does not raise" do
      expect { service.call }.not_to raise_error
    end
  end

  context "when releases mix local and remote charts" do
    let(:release_paths) { [Pathname.new("bitnami/postgresql"), Pathname.new(__dir__)] }

    it "processes the local chart and skips the remote one" do
      service.call
      expect(Helmsnap).to have_received(:run_cmd).with(
        "helm", "dependency", "list", Pathname.new(__dir__),
        "--max-col-width", 0,
        allow_failure: true, stderr: nil
      )
      expect(Helmsnap).not_to have_received(:run_cmd).with(
        "helm", "dependency", "list", Pathname.new("bitnami/postgresql").expand_path,
        anything
      )
    end
  end
end
