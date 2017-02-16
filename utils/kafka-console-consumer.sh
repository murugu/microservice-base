#!/usr/bin/env bash

set -e

# Export the docker machine IP
set +e
# check if we run machine?
docker-machine status default > /dev/null  2>&1
# if yes - result will be 0, if not 1
result=$?
set -e
if [[ $result == 1 ]]
then
    echo "you're using native docker. If not, review the setup"
    export DOCKER_IP=localhost
else
    echo "you're using docker machine. If not, review the setup"
    eval "$(docker-machine env default)"
    export DOCKER_IP=$(docker-machine ip default)
fi
echo DOCKER_IP set to $DOCKER_IP

# docker-machine doesn't exist in Linux, assign default ip if it's not set
DOCKER_IP=${DOCKER_IP:-0.0.0.0}

# change to a relative or env var driven kafka path
~/Documents/Software/kafka_2.11-0.10.1.0/bin/windows/kafka-console-consumer.bat --bootstrap-server $DOCKER_IP:9092 --topic patientdietorders --from-beginning