#!/bin/bash

function addProperty() {
  local path=$1
  local name=$2
  local value=$3

  local entry="<property><name>$name</name><value>${value}</value></property>"
  local escapedEntry=$(echo ${entry} | sed 's/\//\\\//g')

  sed -i "/<\/configuration>/ s/.*/${escapedEntry}\n&/" ${path}
}

function configure() {
    local path=$1
    local module=$2
    local envPrefix=$3

    local var
    local value
    
    echo "Configuring $module"

    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=${envPrefix}`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g'`
        var="${envPrefix}_${c}"
        value=${!var}

        echo " - Setting $name=$value"
        addProperty ${path} ${name} "$value"

        #unset ${var}
    done
}

configure ${HADOOP_CONF_DIR}/core-site.xml core CORE_CONF
configure ${HADOOP_CONF_DIR}/hdfs-site.xml hdfs HDFS_CONF
configure ${HADOOP_CONF_DIR}/yarn-site.xml yarn YARN_CONF
configure ${HADOOP_CONF_DIR}/httpfs-site.xml httpfs HTTPFS_CONF
configure ${HADOOP_CONF_DIR}/kms-site.xml kms KMS_CONF
configure ${HADOOP_CONF_DIR}/mapred-site.xml mapred MAPRED_CONF
configure ${HIVE_CONF_DIR}/hive-site.xml hive HIVE_SITE_CONF

if [ "$MULTIHOMED_NETWORK" = "1" ]; then
    echo "Configuring for multi-homed network"

    # HDFS
    addProperty ${HADOOP_CONF_DIR}/hdfs-site.xml dfs.namenode.rpc-bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/hdfs-site.xml dfs.namenode.servicerpc-bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/hdfs-site.xml dfs.namenode.http-bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/hdfs-site.xml dfs.namenode.https-bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/hdfs-site.xml dfs.client.use.datanode.hostname true
    addProperty ${HADOOP_CONF_DIR}/hdfs-site.xml dfs.datanode.use.datanode.hostname true

    # YARN
    addProperty ${HADOOP_CONF_DIR}/yarn-site.xml yarn.resourcemanager.bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/yarn-site.xml yarn.nodemanager.bind-host 0.0.0.0
    addProperty ${HADOOP_CONF_DIR}/yarn-site.xml yarn.timeline-service.bind-host 0.0.0.0

    # MAPRED
    addProperty ${HADOOP_CONF_DIR}/mapred-site.xml yarn.nodemanager.bind-host 0.0.0.0
fi

function waitForService() {

    local servicePort=$1
    local service=${servicePort%%:*}
    local port=${servicePort#*:}
    local retrySeconds=5
    local max_try=100
    let i=1

    nc -z ${service} ${port}
    result=$?

    until [ ${result} -eq 0 ]; do

      echo "[$i/$max_try] ${service}:${port} is not available yet"

      if (( $i == $max_try )); then
        echo "[$i/$max_try] ${service}:${port} is still not available; giving up after ${max_try} tries. :/"
        exit 1
      fi

      let "i++"
      sleep ${retrySeconds}

      nc -z ${service} ${port}
      result=$?
    done

    echo "[$i/$max_try] $service:${port} is available."
}

for i in ${SERVICE_PRECONDITION[@]}
do
    waitForService ${i}
done

exec $@
