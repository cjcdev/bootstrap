#!/bin/sh

BASE=https://raw.githubusercontent.com/cjcdev/bootstrap/main/docker
DOCKER_SH=${BASE}/docker.sh
DOCKERFILE=${BASE}/Dockerfile

wget -O docker.sh ${DOCKER_SH}
chmod +x docker.sh
wget -O Dockerfile ${DOCKERFILE}
