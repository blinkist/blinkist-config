FROM ruby:2.5.1-slim

ENV RAILS_ENV=test
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8

ENV RUNTIME_PACKAGES pkg-config git

RUN mkdir /tmp/tmpapp
WORKDIR /tmp/tmpapp
ADD . /tmp/tmpapp

RUN echo 'gem: --no-document' >> ~/.gemrc && \
    apt-get clean && apt-get update -qq && apt-get install -y build-essential $RUNTIME_PACKAGES && \
    gem install bundler --version 2.2.10 && \
    gem install gem-release && \
    bundle update && bundle install --jobs 20 --retry 5 && \
    rm -Rf /tmp/tmpapp/ && \
    rm -rf /usr/share/doc/ /usr/share/man/ /usr/share/locale/ && apt-get clean

RUN mkdir /app
ADD . /app
WORKDIR /app

RUN bundle install -j1

RUN chown -R nobody:nogroup /app
RUN whoami
USER nobody
RUN whoami
