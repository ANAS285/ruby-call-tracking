FROM ruby:2.4
RUN mkdir /src
WORKDIR /src
ADD . /src
RUN bundle install

EXPOSE 3000

WORKDIR /src

CMD bundle exec puma -p 3000
