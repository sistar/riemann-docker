#use alpine with oracle jdk and bash
FROM anapsix/alpine-java
MAINTAINER Ralf Sigmund ralf.sigmund@gmail.com

ENV RIEMANN_VERSION=0.2.10

RUN apk update
RUN apk add curl

RUN mkdir -p /var/opt/riemann
RUN adduser -D riemann
RUN chown -R riemann /var/opt/riemann

USER riemann

WORKDIR /var/opt/riemann

RUN curl -o riemann.tar.bz2 https://aphyr.com/riemann/riemann-$RIEMANN_VERSION.tar.bz2 && \
    tar -xj -f riemann.tar.bz2

## 5555 - Riemann TCP and UDP
## 5556 - Riemann WS
EXPOSE 5555 5555/udp 5556

# Share the config directory as a volume
VOLUME /etc/riemann
ADD riemann.config /etc/riemann/riemann.config

# Set the hostname in /etc/hosts so that Riemann doesn't die due to unknownHostException
CMD echo 127.0.0.1 $(hostname) > /etc/hosts; /usr/bin/riemann /etc/riemann/riemann.config

ENTRYPOINT "./riemann-${RIEMANN_VERSION}/bin/riemann"
CMD '/etc/riemann/riemann.config'