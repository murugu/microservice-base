# Microservices Base Modules

Base modules set up infrastructure for deploying microservices

TODO: more documentation needed

Usage:
- Set up docker on your machine
- Start all base service containers by running ./run.sh
- Perform development
- Stop all base service containers by running ./stop.sh

Notes:
- all logs are forwarded to the included ELK containers and accessible from http://<DOCKER_IP>:5401 under docker-* index for a consolidated view and search. Subsequently docker logs command is not available.
