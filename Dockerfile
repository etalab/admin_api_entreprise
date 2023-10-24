FROM ruby:3.2.1

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.7.3/wait /wait
RUN chmod +x /wait

RUN printf 'Package: nodejs\nPin: origin deb.nodesource.com\nPin-Priority: 1001' > /etc/apt/preferences.d/nodesource&& \
  curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get update -qq && \
  apt-get install -qq --no-install-recommends nodejs && \
  apt-get upgrade -qq && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

RUN npm install -g mjml

RUN mkdir /app
WORKDIR /app

COPY Gemfile /app/Gemfile
COPY Gemfile.lock /app/Gemfile.lock
RUN bundle check || bundle install

COPY . /app

COPY docker/entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 5000
