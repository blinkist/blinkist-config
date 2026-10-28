ARG RUBY_VERSION=4.0
FROM ruby:${RUBY_VERSION}-alpine

RUN apk add --no-cache build-base git

WORKDIR /app
