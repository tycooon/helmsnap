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

By default, helmsnap will render your helmfile using `default` environment and will place snapshots in `helm/snapshots` directory. If you want to configure that, or you need to provide credentials for access to private helm repos, you can create a `.helmsnap.yaml` file and put there configuration that looks like this:

```yaml
envs: [staging, production] # `[default]` by default
snapshotsPath: somedir/snapshots # `helm/snapshots` by default
credentials: # [] by default
- repo: https://example.com/some/path/to/repo
  username: someuser
  password: somepassword
```

Credentials will be matched by prefix, so if your repo URL is `https://example.com/some/path/to/repo`, you can also put values like `https://example.com/some/path` or `https://example.com` in `credentials.[].repo`.

You can also override configuration file location using `--config` option.

## Dependencies

The Docker runtime rebuilds Helm 4.3.0 and Helmfile 1.8.1 from immutable commits and checksummed source archives using pinned Go 1.27.1. Both builds explicitly update x/crypto to 0.57.0, x/net to 0.59.0, x/text to 0.42.0 and oras-go to 2.6.2, retaining the upstream Kubernetes clients and replacements. For example, `helm version --short` reports `v4.3.0+zapravila.20261006.gbec5b06` and Helmfile reports `v1.8.1+zapravila.20261006`. The tracked metadata patch and regression preserve valid semantic version output; the modified binaries identify their source commits and dirty build state, and their upstream licenses are included. Runtime builds copy only the gem specification, library, executable and public documentation; they do not depend on Git metadata or include checkout credentials and local dependency caches.

Helm 4.3 supports Kubernetes 1.34–1.37 according to [Helm's version policy](https://helm.sh/docs/topics/version_skew/). Rendering local chart snapshots does not establish compatibility with an older live API server. The [upgrade sequence](https://github.com/zapravila-org/mevbot/issues/2183) must supply its separately verified compatible client and cluster-version gate before live operations on earlier versions.

The Docker build runs affected upstream Helm packages and Helmfile's helmexec tests, then refreshes Alpine packages before adding runtime dependencies. The Docker workflow checks packaged tool versions and scans the loaded image with Trivy 0.75.0 against the current vulnerability database before publication. HIGH and CRITICAL findings, including those without a published fix, fail the job; lower severities remain visible but do not block it. The UNKNOWN `GO-2026-5932` advisory for the unmaintained x/crypto OpenPGP package still requires separate migration, so rebuilt dependencies do not establish a vulnerability-free runtime. Branches and pull requests run the checks, and only a push to `master` publishes the workflow image. The separate release workflow preserves versioned gem/image publication. `bundle exec rake` checks the library, packaging from a source tree without Git, and Ruby style.

The default image workflow also verifies install, upgrade, rollback, Helmfile sync and uninstall with ConfigMap value assertions against disposable Kubernetes 1.34 before publication. To repeat it, use `HELMSNAP_DISPOSABLE_CLUSTER=yes bash scripts/check-bridge-cluster.sh /path/to/disposable-kubeconfig default-security` with the rebuilt tools. The same script's default selection retains the separate bridge's exact Kubernetes 1.32 checks; unknown selections fail before creating a namespace.

- Ruby 3.3+.
- [Helmfile](https://github.com/roboll/helmfile), which in turn relies on [Helm](https://github.com/helm/helm).
- Colordiff or diff utility.

### Kubernetes 1.30 prerequisite client

The separate `Dockerfile.early` builds Helm `v3.18.6+zapravila.20261006.gb76a950` and the patched Helmfile 1.8.1 runtime for application prerequisites before the first node-maintenance hop. For example, the worker UID/readiness chart changes must roll out on Kubernetes 1.30 before maintenance can require those probes; waiting until Kubernetes 1.32 would create a circular prerequisite. Helm 3.18 supports Kubernetes 1.30–1.33 according to [the upstream version policy](https://helm.sh/docs/v3/topics/version_skew/), and the build asserts that its Kubernetes client remains 0.33.3.

This is a modified source build, not an unchanged Helm 3.18.6 binary. Checksummed upstream [commit `8fb76d6`](https://github.com/helm/helm/commit/8fb76d6ab555577e98e23b7500009537a471feee) backports [the chart extraction dot-name fix](https://github.com/helm/helm/security/advisories/GHSA-hr2v-4r36-88hr), including metadata/extraction regression tests. A tracked patch resets idle registry connections after TLS changes and preserves one valid version metadata field. Pinned Go 1.27.1 and explicit x/crypto, x/net, x/text, oras-go, containerd 1.7.36, gRPC 1.83.2 and SPDY 0.5.1 updates address embedded dependency findings; selected upstream packages and Helmfile's helmexec tests run during the build. Source licenses and modified-build identities are included.

The dedicated workflow verifies packaging, exact tool identity, current Trivy 0.75.0 HIGH/CRITICAL findings and actual install, upgrade, rollback, Helmfile sync and uninstall against digest-pinned Kubernetes 1.30.13. Only a passing `master` push publishes `ghcr.io/tycooon/helmsnap:helm3.18.6-security-20261006`; default and bridge tags remain separate. Consumers must explicitly select the verified image, pin its published digest and use a matching live client/server gate. Stock Helm 3.18.6 remains refused by the security gate. The UNKNOWN OpenPGP advisory remains tracked separately; the source build does not establish a vulnerability-free runtime or application recovery.

Use `HELMSNAP_DISPOSABLE_CLUSTER=yes bash scripts/check-bridge-cluster.sh /path/to/disposable-kubeconfig early` only against a disposable Kubernetes 1.30 cluster. After prerequisite application rollout, freeze Helm operations during node maintenance, use the separately verified bridge at Kubernetes 1.32, and select the default client from Kubernetes 1.34. The complete order, production health/storage profiles and durable worker quiescence remain in [the upgrade sequence](https://github.com/zapravila-org/mevbot/issues/2183).

### Kubernetes 1.32 bridge

The separate `Dockerfile.bridge` builds Helm `v4.1.4+zapravila.20261006` and Helmfile `v1.8.1+zapravila.20261006` from checksummed upstream source archives. For example, a Kubernetes 1.32 server can use this bridge while the default Helm 4.3 image requires Kubernetes 1.34 or later. Helm 4.1 supports Kubernetes 1.32–1.35. Use the verified early client for prerequisite rollout on Kubernetes 1.30, then freeze Helm operations during the initial infrastructure upgrades in the [upgrade sequence](https://github.com/zapravila-org/mevbot/issues/2183).

The bridge rebuilds both tools with Go 1.27.1 and explicit security updates to x/crypto, x/net, x/text and oras-go. It retains upstream Kubernetes client versions and replacements. The small tracked Helm patch backports the newer release's TLS idle-connection reset and adjusts client metadata and repeatable archive tests for the newer Go toolchain. A regression test also ensures `helm version --short` combines the custom build metadata and source commit into one valid semantic version field, such as `v4.1.4+zapravila.20261006.g05fa379`. Version metadata identifies the modified build rather than an unchanged upstream binary. Upstream licenses are included in the image.

The bridge workflow tests the affected upstream packages, runtime packaging, tool identity, current HIGH/CRITICAL vulnerability findings and actual install, upgrade, rollback, Helmfile sync and uninstall against disposable Kubernetes 1.32. It publishes only `ghcr.io/tycooon/helmsnap:helm4.1.4-security-20261006` after every check passes on `master`; it never changes the default image's tags. Consumers must select the bridge explicitly and pin its published digest. Their live cluster-version gate remains required. Snapshot rendering alone does not prove live API compatibility. The scan still reports the UNKNOWN `GO-2026-5932` advisory for the unmaintained x/crypto OpenPGP package in both binaries, so this image is not vulnerability-free.

To repeat the live check, supply a **disposable** Kubernetes 1.32 cluster and the patched binaries on `PATH`:

```sh
HELMSNAP_DISPOSABLE_CLUSTER=yes bash scripts/check-bridge-cluster.sh /path/to/disposable-kubeconfig
```

The check creates a uniquely named namespace, verifies ConfigMap values through each release operation and removes its namespace on exit. It does not exercise application workloads, storage, controllers or production recovery.

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
