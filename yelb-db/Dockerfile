FROM postgres:10.12-alpine
MAINTAINER uhoelscher@pivotal.io
LABEL author="uhoelscher@pivotal.io"

WORKDIR /

COPY init-yelb-db.sh /docker-entrypoint-initdb.d/init-yelb-db.sh

ENV POSTGRES_PASSWORD=postgres_password


