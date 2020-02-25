FROM ruby:2.4.9-alpine3.11
MAINTAINER uhoelscher@pivotal.io
LABEL author="uhoelscher@pivotal.io"

################## BEGIN INSTALLATION ######################

# Set the working directory to /app
WORKDIR /app

COPY yelb-appserver.rb yelb-appserver.rb 
COPY Gemfile Gemfile
COPY modules modules

ENV LANG=en_us.UTF-8
ENV LC_ALL=C.UTF-8
ENV RACK_ENV=production

RUN gem install sinatra 
RUN gem install redis 
RUN gem install aws-sdk-dynamodb
### hack to allow the setup of the pg gem (which would fail otherwise)
RUN apk add --no-cache --update build-base \
                                linux-headers \
                                git \
                                postgresql-dev 
### end of hack (this would require additional research and optimization)
RUN gem install pg 
# Set the working directory to /
WORKDIR /
ADD startup.sh startup.sh

##################### INSTALLATION END #####################

CMD ["./startup.sh"]