FROM ruby:3.3.0
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir -p /app

WORKDIR /app

ADD . /app/

RUN bundle install