# Helmsnap

## About

Helmsnap is a tool for generating and checking helmfile snapshots. Example:

Generate snapshots (uses `helmfile template` under the hood):

```sh
helmsnap generate
```

Generate snapshots in a temporary directory and check (diff) them against existing snapshots in `helm/snapshots` directory:

```sh
helmsnap check
```

Just build dependencies for each release in a helmfile:

```sh
helmsnap dependencies # or `helmsnap deps`
```

Get the full description of possible arguments:

```sh
helmsnap --help
```

The typical usage flow:

1. You generate some snapshots using `helmsnap generate` command and check them into your git repo.
2. You add `helmsnap check` command to your CI (or run it manually on every commit).
3. In case snapshots differ, you should carefully check the updates and either fix your chart or update the snapshots using `helmsnap generate`.

This tool can also be useful when you are developing a new chart or updating an existing one: you can generate snapshots and see what is rendered without need to deploy the chart in your cluster.

## Configuration

By default, helmsnap will render your helmfile using `default` environment and will place snapshots in `helm/snapshots` directory. If you want to configure that, create a `.helmsnap.yaml` file and put there configuration that looks like this:

```yaml
envs: [staging, production] # `[default]` by default
snapshotsPath: somedir/snapshots # `helm/snapshots` by default
```

You can also override configuration file location using `--config` option.

## Dependencies

- Ruby 3.0+.
- [Helmfile](https://github.com/roboll/helmfile), which in turn relies on [Helm](https://github.com/helm/helm).
- Colordiff or diff utility.

## Features

### Helm dependency management

Helmsnap will automatically rebuild your chart dependencies on every snapshot generation or check. In case your dependency is using url to some local helm repo and you don't have a proper repo added, it will add it automatically which is useful in CI. It also will detect local dependencies (those that start with `file://`) and rebuild their dependencies as well.

### Timestamp replacement

Helmsnap will automatically replace all occurencies of patterns that look like timestamps (format like `2022-01-01 00:00:00.000`) in your templates. This is useful in case you have some annotations like `releaseTime` that would break your snapshots checks otherwise.

## Installation

Just install the gem and use the provided `helmsnap` binary.

```sh
gem install helmsnap
```

Alaternatively, you can use the [Docker image](https://github.com/tycooon/helmsnap/pkgs/container/helmsnap) with Ruby, helm and helmsnap gem preinstalled. This is useful for CIs or if you don't want to install Ruby and Helmfile on your machine. Here is an example docker command that can be used to generate snapshots:

```sh
docker run --rm -it -w /wd -v $PWD:/wd ghcr.io/tycooon/helmsnap helmsnap generate
```

## CI example

Example job for Gitlab CI:

```yaml
check-snapshots:
  stage: test
  image: ghcr.io/tycooon/helmsnap:latest
  script: helmsnap check
```

## Contributing

Bug reports and pull requests are welcome.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
