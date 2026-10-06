FROM golang:1.27.1-alpine3.24@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS helm-builder

RUN apk add --no-cache git bash
WORKDIR /source
ADD --checksum=sha256:e113bad2e11b9920a2d1ad2c1ee8b1881796330ba02e2673f5312ba10990800e https://codeload.github.com/helm/helm/tar.gz/bec5b06ed841fe5269972d864d5177944fd5970f /tmp/helm.tar.gz
RUN tar -xzf /tmp/helm.tar.gz --strip-components=1 && rm /tmp/helm.tar.gz
COPY patches/helm-4.3.0-build-metadata.patch /tmp/helm.patch
RUN git apply --check --whitespace=error-all /tmp/helm.patch && git apply /tmp/helm.patch

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build \
    go get golang.org/x/crypto@v0.57.0 golang.org/x/net@v0.59.0 golang.org/x/text@v0.42.0 oras.land/oras-go/v2@v2.6.2 && \
    go mod tidy && \
    go test ./internal/version ./pkg/registry ./pkg/strvals ./pkg/engine ./pkg/chart/... && \
    go test ./pkg/cmd -run '^TestShortVersionBuildMetadata$' \
      -ldflags '-X helm.sh/helm/v4/internal/version.metadata=zapravila.20261006 -X helm.sh/helm/v4/internal/version.gitCommit=bec5b06ed841fe5269972d864d5177944fd5970f' && \
    CGO_ENABLED=0 go build -trimpath -mod=readonly \
      -ldflags '-s -w -X helm.sh/helm/v4/internal/version.version=v4.3.0 -X helm.sh/helm/v4/internal/version.metadata=zapravila.20261006 -X helm.sh/helm/v4/internal/version.gitCommit=bec5b06ed841fe5269972d864d5177944fd5970f -X helm.sh/helm/v4/internal/version.gitTreeState=dirty' \
      -o /out/helm ./cmd/helm

FROM golang:1.27.1-alpine3.24@sha256:8a5910f31396cd4d89662f56c68b3ae31d374308270a1c3bd96672ee5ed43414 AS helmfile-builder

RUN apk add --no-cache git bash
WORKDIR /source
ADD --checksum=sha256:b5a02fc8be34751f903af6fa621021462988d1ed13319f6e6cae95299b5c3dde https://codeload.github.com/helmfile/helmfile/tar.gz/226c16b88e2a1982b89b9ce2aee4fc69a3e03d73 /tmp/helmfile.tar.gz
RUN tar -xzf /tmp/helmfile.tar.gz --strip-components=1 && rm /tmp/helmfile.tar.gz
COPY --from=helm-builder /out/helm /usr/local/bin/helm

RUN --mount=type=cache,target=/go/pkg/mod --mount=type=cache,target=/root/.cache/go-build \
    go get golang.org/x/crypto@v0.57.0 golang.org/x/net@v0.59.0 golang.org/x/text@v0.42.0 oras.land/oras-go/v2@v2.6.2 && \
    go mod tidy && \
    go test ./pkg/helmexec && \
    CGO_ENABLED=0 go build -trimpath -mod=readonly \
      -ldflags '-s -w -X go.szostok.io/version.version=v1.8.1+zapravila.20261006 -X go.szostok.io/version.commit=226c16b88e2a1982b89b9ce2aee4fc69a3e03d73 -X go.szostok.io/version.commitDate=2026-09-30T01:00:23Z -X go.szostok.io/version.buildDate=2026-10-06T00:00:00Z -X go.szostok.io/version.dirtyBuild=true' \
      -o /out/helmfile .

FROM alpine/helm:4.3.0@sha256:a6cf54599ccb99d90cf0712b30f03fdb3cab062e6b94e0418cc4db7e8a1464b2

RUN apk upgrade --update --no-cache && apk add --no-cache ruby git colordiff

WORKDIR /wd

COPY --from=helm-builder /out/helm /usr/bin/helm
COPY --from=helmfile-builder /out/helmfile /usr/local/bin/helmfile
COPY --from=helm-builder /source/LICENSE /usr/share/licenses/helm/LICENSE
COPY --from=helmfile-builder /source/LICENSE /usr/share/licenses/helmfile/LICENSE
COPY helmsnap.gemspec LICENSE.txt README.md ./
COPY lib/ ./lib/
COPY exe/ ./exe/

RUN gem install colorize && gem build && gem install helmsnap --local

ENTRYPOINT []
CMD []
