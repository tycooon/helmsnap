FROM alpine/helm:4.3.0@sha256:a6cf54599ccb99d90cf0712b30f03fdb3cab062e6b94e0418cc4db7e8a1464b2

RUN apk add --update --no-cache ruby git colordiff

WORKDIR /wd

COPY --from=ghcr.io/helmfile/helmfile:v1.8.1@sha256:9c29ece2fb6ec3f8c1432be9d29526f3cfe35d7e59e066d0aa5c4b3e819f2165 /usr/local/bin/helmfile /usr/local/bin/helmfile
COPY helmsnap.gemspec LICENSE.txt README.md ./
COPY lib/ ./lib/
COPY exe/ ./exe/

RUN gem install colorize && gem build && gem install helmsnap --local

ENTRYPOINT []
CMD []
