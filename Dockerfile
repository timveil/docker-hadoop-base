FROM openjdk:8-jdk-slim

LABEL maintainer="tjveil@gmail.com"

ENV HADOOP_VERSION 2.8.4
ENV HADOOP_URL https://www.apache.org/dyn/mirrors/mirrors.cgi?action=download&filename=hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/etc/hadoop
ENV MULTIHOMED_NETWORK=1
ENV USER=root
ENV PATH $HADOOP_HOME/bin/:$PATH

ENV TIMEZONE=America/New_York
RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN apt-get update && apt-get install -y --no-install-recommends perl curl netcat apt-utils

RUN rm -rf /var/lib/apt/lists/* \
    && mkdir -p /opt \
    && curl -fSL "$HADOOP_URL" -o /tmp/hadoop.tar.gz \
    && tar -xvf /tmp/hadoop.tar.gz -C /opt/ \
    && rm /tmp/hadoop.tar.gz* \
    && rm -rf $HADOOP_HOME/share/doc \
    && ln -s $HADOOP_HOME/etc/hadoop /etc/hadoop \
    && cp /etc/hadoop/mapred-site.xml.template /etc/hadoop/mapred-site.xml \
    && mkdir -p $HADOOP_HOME/logs

# Custom configuration goes here
ADD conf/httpfs-log4j.properties $HADOOP_CONF_DIR
ADD conf/kms-log4j.properties $HADOOP_CONF_DIR
ADD conf/log4j.properties $HADOOP_CONF_DIR

ADD entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
