# ActiveMQ Artemis 1.5.0

FROM alpine:latest

MAINTAINER Dominik Lenoch <dlenoch@redhat.com>

USER root

RUN apk update && apk upgrade && apk add \
      ca-certificates \
      gnupg \
      su-exec \
      tini \
      openjdk8-jre-base \
      libaio \
      wget \
      grep \
      tar \
    && rm -rf /var/cache/apk/*

ENV JAVA_HOME /usr/lib/jvm/java-1.8-openjdk

# create artemis user without password and home dir
RUN addgroup -S artemis && adduser -s /bin/false -D -H artemis -G artemis

# Setup broker
RUN mkdir /opt && cd /opt && \
    RELEASE=1.5.3 && \
    URL=https://www-eu.apache.org/dist/activemq && \

    TAR=apache-artemis-$RELEASE-bin.tar.gz && \
    ASC=$TAR.asc && \

    wget -q $URL/activemq-artemis/$RELEASE/$TAR && \
    wget -q $URL/activemq-artemis/$RELEASE/$ASC && \
    wget -q $URL/KEYS && \

    gpg --import KEYS && \
    gpg $ASC && \

    tar xfz $TAR && \
    ln -s apache-artemis-$RELEASE apache-artemis && \
    rm -f $TAR $ASC KEYS

# Web Server
EXPOSE 8161

# Port for CORE,MQTT,AMQP,HORNETQ,STOMP,OPENWIRE
EXPOSE 61616

# Port for HORNETQ,STOMP
EXPOSE 5445

# Port for AMQP
EXPOSE 5672

# Port for MQTT
EXPOSE 1883

#Port for STOMP
EXPOSE 61613

# Expose some outstanding folders
VOLUME ["/var/lib/artemis/data"]
VOLUME ["/var/lib/artemis/tmp"]
VOLUME ["/var/lib/artemis/etc"]

WORKDIR /var/lib/artemis/bin

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]

CMD ["artemis-server"]
