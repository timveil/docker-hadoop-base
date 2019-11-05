FROM openjdk:8-jdk-slim

LABEL maintainer="tjveil@gmail.com"

ARG TIMEZONE=America/New_York

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils perl curl netcat less procps vim \
    && rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
