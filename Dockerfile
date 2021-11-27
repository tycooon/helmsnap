FROM alpine/helm

RUN apk add --update --no-cache ruby git colordiff

WORKDIR /app

COPY . .

RUN gem install colorize && gem build && gem install helmsnap --local

ENTRYPOINT []
CMD []
