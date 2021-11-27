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
  spec.required_ruby_version = ">= 2.7.0"

  # spec.metadata["allowed_push_host"] = "TODO: Set to your gem server 'https://example.com'"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci))})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rubocop-config-umbrellio"
end
