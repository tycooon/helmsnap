FROM alpine/helm:4

RUN apk add --update --no-cache ruby git colordiff

WORKDIR /wd

COPY --from=ghcr.io/helmfile/helmfile:v1.5.2  /usr/local/bin/helmfile /usr/local/bin/helmfile
COPY . .

RUN gem install colorize && gem build && gem install helmsnap --local

ENTRYPOINT []
CMD []
