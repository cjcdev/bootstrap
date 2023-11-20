#!/bin/bash

function help() {
echo \
"
Helper script to build and run the docker container.

Usage:

  Build the image:
    ./docker -b

  Run './build.sh' inside of the container:
    ./docker ./build.sh

  Run the container and drop into a shell:
    ./docker

Options:
   -b --Build the docker image.
   -h --Displays this help message.
"
}

DOCKER_IMAGE_TAG=docker-helper
DOCKER_CONTAINER_NAME=${DOCKER_IMAGE_TAG}-container

WORK_DIR="${PWD}/work"

# process options
while getopts bh OPTIONS; do
  case $OPTIONS in
    b)
      # do docker build
      docker build --tag "${DOCKER_IMAGE_TAG}" \
            --build-arg "USER=$(whoami)" \
            --build-arg "host_uid=$(id -u)" \
            --build-arg "host_gid=$(id -g)" \
            -f "${DOCKERFILE}" \
            .
      exit 0
      ;;
    h)
      help
      exit 0
      ;;
    \?) #unrecognized option - show help
      echo -e \\n"Option -$OPTIONS not allowed."
      help
      exit 1
      ;;
  esac
done


# Shift past the last option parsed by getopts
shift $((OPTIND-1))
# now $@ has everything after the options

if [[ ! -d "$WORK_DIR" ]]; then
    echo "WORK_DIR=${WORK_DIR} does not exits. Creating.."
    mkdir ${WORK_DIR}
fi

# run the docker image
#   --rm  automatically removes the container and on exit
#   -i  keeps the standard input open
#   -t  provides a terminal as a interactive shell within container
#   -v  are file systems mounted on docker container to preserve data
#       generated during the build and these are stored on the host.
docker run -it --rm --privileged --name "${DOCKER_CONTAINER_NAME}" \
    -v "${WORK_DIR}":/work \
    -v "${HOME}/.ssh/":"/home/${USER}/.ssh/:ro" \
    "${DOCKER_IMAGE_TAG}" \
    "$@"



