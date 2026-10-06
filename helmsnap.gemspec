# frozen_string_literal: true

require_relative "lib/helmsnap/version"

Gem::Specification.new do |spec|
  spec.name = "helmsnap"
  spec.version = Helmsnap::VERSION
  spec.authors = ["Yuri Smirnov"]
  spec.email = ["tycooon@yandex.ru"]

  spec.summary = "A tool for creating and checking helm chart snapshots."
  spec.homepage = "https://github.com/tycooon/helmsnap"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.3.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*.rb", "exe/*", "LICENSE.txt", "README.md"].select { |path| File.file?(path) }
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "colorize", "~> 1.1"
end
