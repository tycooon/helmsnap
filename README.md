# Helmsnap

## About

Helmsnap is a tool for generating and checking helm chart snapshots. Example:

```sh
# This will generate snapshots using helm template command
helmsnap generate -c helm/mychart -s helm/snapshots -f helm/values/production.yaml

# This will generate snapshots in some temp directory and check (diff) them against existing snapshots in `helm/snapshots` directory
helmsnap check -c helm/mychart -s helm/snapshots -f helm/values/production.yaml

# Get the full description of possible arguments
helmsnap --help
```

The typical usage flow:

1. You generate some snapshots using `helmsnap generate` command and check them into your git repo.
2. You add `helmsnap check` command to your CI (or run it manually on every commit).
3. In case snapshots differ, you should carefully check the updates and either fix your chart or update the snapshots using `helmsnap generate`.

## Features

### Helm dependency management

Helmsnap will automically rebuild your chart dependencies on every snapshot generation or check. In case your dependency is using url to some local helm repo and you don't have a proper repo added, it will add it automically which is useful in CI. It also will detect local dependencies (those that start with `file://`) and rebuild their dependencies as well.

### Timestamp replacement

Helmsnap will automically replace all occurencies of patterns that look like timestamps (format like `2022-01-01 00:00:00.000`) in your templates. This is useful in case you have some annotations like `releaseTime` that would break your snapshots checks otherwise.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "helmsnap"
```

And then execute:

```sh
bundle install
```

Or install it yourself as:

```sh
gem install helmsnap
```

Alaternatively, you can use a [Docker image](https://github.com/tycooon/helmsnap/pkgs/container/helmsnap) with Ruby, helm and helmsnap gem preinstalled.

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
