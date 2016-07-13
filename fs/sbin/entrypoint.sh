#! /usr/bin/env bash
set -eo pipefail

# No matter what, this runs
if [[ ! -v ${HADOOP_MASTER_ADDRESS} ]]; then
  sed -i.bak "s/{HADOOP_MASTER_ADDRESS}/${HADOOP_MASTER_ADDRESS}/g" ${HADOOP_CONF_DIR}/core-site.xml
fi

wait_for_connection() {
  echo -n "Waiting for TCP connection to $1:$2..."
  while ! nc -w 1 $1 $2 2> /dev/null; do
    echo -n .
    sleep 1
  done
  echo "Ok."
}

# The first argument determines whether this container runs as data, namenode or secondary namenode
if [ -z "$1" ]; then
  echo "Select the role for this container with the docker cmd 'name', 'sname', 'data'"
  exit 1
else
  if [ $1 = "name" ]; then
    if  [[ ! -f /data/hdfs/name/current/VERSION ]]; then
      echo "Formatting namenode root fs in /data/hdfs/name..."
      hdfs namenode -format
      echo
    fi
    exec hdfs namenode
  elif [ $1 = "sname" ]; then
    wait_for_connection ${HADOOP_MASTER_ADDRESS} 8020
    exec hdfs secondarynamenode
  elif [ $1 = "data" ]; then
    wait_for_connection ${HADOOP_MASTER_ADDRESS} 50070
    exec hdfs datanode
  else
    exec "$@"
  fi
fi
