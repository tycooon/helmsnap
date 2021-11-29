# Helmsnap

## About

Helmsnap is a tool for generating and checking helm chart snapshots. Example:

Generate snapshots (uses `helm template` under the hood):

```sh
helmsnap generate -c helm/mychart -s helm/snapshots -v helm/values/production.yaml
```

Generate snapshots in some temp directory and check (diff) them against existing snapshots in `helm/snapshots` directory:

```sh
helmsnap check -c helm/mychart -s helm/snapshots -v helm/values/production.yaml
```

Get the full description of possible arguments:

```sh
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

Just install a gem and use the provided `helmsnap` binary.

```sh
gem install helmsnap
```

Alaternatively, you can use a [Docker image](https://github.com/tycooon/helmsnap/pkgs/container/helmsnap) with Ruby, helm and helmsnap gem preinstalled. This is useful for CIs or if you don't want to install Ruby locally.

## CI example

Example job for Gitlab CI:

```yaml
check-snapshots:
  stage: test
  image: ghcr.io/tycooon/helmsnap:latest
  script: helmsnap check -c helm/mychart -s helm/snapshots -v helm/values/production.yaml
```

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
