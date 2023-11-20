#!/bin/sh


DOCKER_SH=https://raw.githubusercontent.com/cjcdev/docker-bootstrap/main/docker.sh
DOCKERFILE=https://raw.githubusercontent.com/cjcdev/docker-bootstrap/main/Dockerfile

wget -O docker.sh $DOCKER_SH
chmod +x docker.sh
wget -O Dockerfile $DOCKERFILE
