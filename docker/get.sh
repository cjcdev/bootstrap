#!/bin/sh

BASE=https://raw.githubusercontent.com/cjcdev/bootstrap/main/docker
DOCKER_SH=${BASE}/docker.sh
DOCKERFILE=${BASE}/Dockerfile

wget -q -O docker.sh ${DOCKER_SH}
chmod +x docker.sh
wget -q -O Dockerfile ${DOCKERFILE}

echo "Docker bootstrap ready!"
