FROM ruby:3.0.2-alpine

RUN apk add --update --no-cache git

WORKDIR /app

COPY . .

RUN gem build && gem install helmsnap --local

ENTRYPOINT [ "helmsnap" ]
