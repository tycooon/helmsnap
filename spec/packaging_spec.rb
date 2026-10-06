# frozen_string_literal: true

require "fileutils"
require "rubygems/package"
require "tmpdir"

RSpec.describe "Runtime gem packaging" do
  it "includes its library and command when the source has no Git metadata" do
    root = File.expand_path("..", __dir__)
    Dir.mktmpdir("helmsnap-runtime-") do |directory|
      %w[helmsnap.gemspec lib exe LICENSE.txt README.md].each do |path|
        FileUtils.cp_r(File.join(root, path), directory)
      end
      Dir.chdir(directory) do
        specification = Gem::Specification.load("helmsnap.gemspec")
        expect(specification.files).to include(
          "lib/helmsnap.rb", "exe/helmsnap", "LICENSE.txt", "README.md"
        )
        expect(specification.executables).to eq(["helmsnap"])
        artifact = Gem::Package.build(specification)
        expect(Gem::Package.new(artifact).contents).to include("lib/helmsnap.rb", "exe/helmsnap")
      end
    end
  end
end
