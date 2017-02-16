#!/usr/bin/env bash

set -e

# Build the project and docker images
#mvn clean install
#mvn install

#eval "$(docker-machine env $(docker-machine active))"

# Export the docker machine IP
set +e
# check if we run machine?
docker-machine status default > /dev/null  2>&1
# if yes - result will be 0, if not 1
result=$?
set -e
if [[ $result == 1 || $result == 127 ]]
then
    echo "you're using native docker. If not, review the setup"
    if [ -z $DOCKER_HOST_IP ]
    then
      UNAME=`uname`
      echo "OS Platform: $UNAME, setting DOCKER_HOST_IP"
      if [[ "$UNAME" == 'Darwin' ]]
      then
        export DOCKER_HOST_IP=$(ipconfig getifaddr en0)
      	export DOCKER_IP=$DOCKER_HOST_IP
      elif [[ "$UNAME" == 'Linux' ]]
      then
        if [[ -f /etc/redhat-release ]]
        then
          DOCKER_HOST_IP=$(ifconfig | grep "inet" | grep -v 172 | grep -v 127 | awk '{ print $2 }')
        else
          DOCKER_HOST_IP=$(ifconfig | grep "inet addr" | grep -v 172 | grep -v 127 | cut -d: -f2 | awk '{ print $1 }')
        fi
      	export DOCKER_IP=$DOCKER_HOST_IP
      fi
    else
    	export DOCKER_IP=$DOCKER_HOST_IP
    fi
else
    echo "you're using docker machine. If not, review the setup"
    eval "$(docker-machine env default)"
    export DOCKER_IP=$(docker-machine ip default)
fi
echo DOCKER_IP set to $DOCKER_IP

# docker-machine doesn't exist in Linux, assign default ip if it's not set
DOCKER_IP=${DOCKER_IP:-0.0.0.0}

# Remove existing containers
docker-compose stop
docker-compose rm -f

echo *** building/updating docker images... ***
docker build -t davita/logstash logstash

docker-compose up -d logstash
echo "logstash container created, getting container id"
LOGSTASH_CONTAINER=$(docker-compose ps -q logstash)
echo "Waiting for logstash container $LOGSTASH_CONTAINER"
( docker logs -f $LOGSTASH_CONTAINER &) | grep -q "Successfully started Logstash API endpoint"

# Start the config service first and wait for it to become available
echo "Starting config-service"
docker-compose up -d config-service kibana mysql redis

while [ -z ${CONFIG_SERVICE_READY} ]; do
  echo "Waiting for config service..."
  if [ "$(curl --silent $DOCKER_IP:8888/health 2>&1 | grep -q '\"status\":\"UP\"'; echo $?)" = 0 ]; then
      CONFIG_SERVICE_READY=true;
  fi
  sleep 2
done

# Start the discovery service next and wait
docker-compose up -d discovery-service

while [ -z ${DISCOVERY_SERVICE_READY} ]; do
  echo "Waiting for discovery service..."
  if [ "$(curl --silent $DOCKER_IP:8761/health 2>&1 | grep -q '\"status\":\"UP\"'; echo $?)" = 0 ]; then
      DISCOVERY_SERVICE_READY=true;
  fi
  sleep 2
done

# start mysql and wait for it to run
#docker-compose up -d mysql
#sleep 5
while [ -z ${DB_READY} ]; do
  echo "Waiting for db..."
  if [ "$( nc -z -v -w30 $DOCKER_IP 3306 2>&1 | grep -q 'localhost [127.0.0.1] 3306 (mysql) open'; echo $?)" = 1 ]; then
      DB_READY=true;
  fi
  sleep 2
done

# Start the other containers
docker-compose up -d

# Attach to the log output of the cluster
#docker-compose logs
