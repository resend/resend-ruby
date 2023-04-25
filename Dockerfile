FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev

RUN mkdir -p /app

WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock

RUN bundle install
ADD . /app