FROM ubuntu:16.04

MAINTAINER shimtom

ENV ROOT_CA_SUBJECT /C=JP/ST=Tokyo/L=City/O=Company/CN=ca.example.com
ENV ROOT_CA_SAN DNS:root.example.com,DNS:www.root.example.com
ENV SUB_CA_SUBJECT /C=JP/ST=Tokyo/L=City/O=Company/CN=sub.example.com
ENV SUB_CA_SAN DNS:sub.example.com,DNS:www.sub.example.com
ENV CA_VALID_DAYS 3650


VOLUME /export

RUN apt-get update && apt-get install -y --no-install-recommends \
        openssl \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ADD openssl.root.ca.cnf /root/ca/openssl.cnf
ADD openssl.subordinate.ca.cnf /root/subordinate/ca/openssl.cnf
ADD run.sh /usr/local/bin/run.sh
ADD sign.sh /usr/local/bin/sign.sh

CMD ["/usr/local/bin/run.sh"]
