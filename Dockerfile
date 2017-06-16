FROM ruby:2.4.1

ENV RAILS_ENV production
WORKDIR /app
RUN echo $RUBY_VERSION > .ruby-version

RUN apt-get update -qq \
 && apt-get install -qqy \
    build-essential nodejs

# Some gems change rarely, builds can speed up by pre-installing them
RUN gem install bundler:1.15.1 foreman
RUN gem install \
    nokogiri:1.7.1 \
    rails:5.0.2 \
    sidekiq:4.2.10

ADD Gemfile* /app/
RUN bundle install --without development test --jobs `nproc` --retry 3
ADD . /app/
RUN SECRET_KEY_BASE=XXX bundle exec rake assets:precompile

VOLUME /var/containerdb
CMD ["foreman", "start"]
