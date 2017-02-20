FROM ruby:2.3.1-slim

ENV RAILS_ENV=production
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

ENV RUNTIME_PACKAGES pkg-config netcat supervisor nodejs git jq uuid-runtime libxslt1-dev build-essential libxml2-dev libxslt1-dev

RUN mkdir /tmp/tmpapp
WORKDIR /tmp/tmpapp
ADD . /tmp/tmpapp

RUN echo 'gem: --no-document' >> ~/.gemrc && \
    apt-get clean && apt-get update -qq && apt-get install -y build-essential $RUNTIME_PACKAGES && \
    gem install bundler --version 1.12.5 && \
    bundle update && bundle install --jobs 20 --retry 5 && \
    rm -Rf /tmp/tmpapp/ && \
    rm -rf /usr/share/doc/ /usr/share/man/ /usr/share/locale/ && apt-get clean

RUN mkdir /app
ADD . /app
WORKDIR /app

RUN bundle install -j1
