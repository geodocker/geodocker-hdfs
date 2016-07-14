#!/usr/bin/env bash

# Avoid race conditions and actually poll for availability of component dependencies
# Credit: http://stackoverflow.com/questions/8350942/how-to-re-run-the-curl-command-automatically-when-the-error-occurs/8351489#8351489
with_backoff() {
  local max_attempts=${ATTEMPTS-5}
  local timeout=${INTIAL_POLLING_INTERVAL-1}
  local attempt=0
  local exitCode=0

  while (( $attempt < $max_attempts ))
  do
    set +e
    "$@"
    exitCode=$?
    set -e

    if [[ $exitCode == 0 ]]
    then
      break
    fi

    echo "Retrying $@ in $timeout.." 1>&2
    sleep $timeout
    attempt=$(( attempt + 1 ))
    timeout=$(( timeout * 2 ))
  done

  if [[ $exitCode != 0 ]]
  then
    echo "Fail: $@ failed to complete after $max_attempts attempts" 1>&2
  fi

  return $exitCode
}

wait_until_port_open() {
  echo -n "Waiting for TCP connection to $1:$2..."
  while ! nc -w 1 $1 $2 2> /dev/null; do
    echo -n .
    sleep 1
  done
  echo "Ok."
}

hdfs_is_available() {
	hdfs dfs -test -d /
	return $?
}

wait_until_hdfs_is_available() {
  hdfs dfsadmin -safemode wait
	with_backoff hdfs_is_available
	if [ $? != 0 ]; then
		echo "HDFS not available before timeout. Exiting ..."
		exit 1
	fi
}
