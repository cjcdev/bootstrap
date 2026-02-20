#!/bin/bash
# Helper script to build and run docker container for build environment.  
# The script will automatically build the container if it detects it's not built yet.
# The current directory will be mounted as volume as /work in the container.
# The gid/uid inside of the volume will be 1000/1000 for ubuntu user, but the files on the host will have the user's gid/uid.

# trace commands
#set -x

# stop on error
set -e

# figure out the path where this script is stored
if [[ -h ${0} ]];then
  # When script is called as a symlink
  SCRIPT_FILE="${PWD}/$(readlink $(basename "$0"))"
  SCRIPT_DIR="$(dirname "${SCRIPT_FILE}")"
else
  # When script is not called as as symlink
  SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
fi 

DOCKER_IMAGE_TAG=docker-helper
DOCKER_CONTAINER_NAME=${DOCKER_IMAGE_TAG}-container
HOSTNAME=$(echo "$DOCKER_IMAGE_TAG" | sed 's/\./-/g')
# container should run with same user/gid as host user to avoid permissions issues with mounted volumes
HOST_USER=ubuntu

WORK_DIR="${PWD}"
INTERACTIVE="-it"
BUILD_IMAGE_FLAG=0
DOCKERFILE="${SCRIPT_DIR}/Dockerfile"

function help() {
echo \
"
Helper script to run docker container.  The script will automatically build the container if it detects it's not built yet.  
You can also force a rebuild of the container by using the -b option.

Usage:

  Run the container and drop into an interactive shell:
    ./docker.sh

  Run './build.sh' inside of the container with non-interactive shell:
    ./docker.sh -n ./build.sh

Options:
   -h                 Displays this help message.
   -b                 Build the docker image.
   -f                 Build Docker Image with --no-cache, will include latest from Ubuntu.
   -n                 Run the docker image non-interactively.
   -e [env-file]      Docker Environment File (default .env is used if exits)
   -v [volume pair]   Docker Volumes to Mount, e.g. -v /opt/local_dir:/opt/container_dir
"
}

function build_image() 
{
  local dockerfile="$1"
  docker build --tag "${DOCKER_IMAGE_TAG}" \
        ${BUILD_CACHE} \
        --build-arg host_user=${HOST_USER} \
        -f "${dockerfile}" \
        .
}

# Build volume arguments conditionally
DOCKER_VOLUMES=""
DOCKER_VOLUMES+="-v ${WORK_DIR}:/work "

# Conditionally add .ssh/ if it exists
if [ -d "${HOME}/.ssh/" ]; then
    DOCKER_VOLUMES+="-v ${HOME}/.ssh/:/home/${HOST_USER}/.ssh/ "
fi

# process options
while getopts bfnhe:v: OPTIONS; do
  case $OPTIONS in
    b)
      # do docker build
      BUILD_IMAGE_FLAG=1
    ;;

    f)
      BUILD_CACHE="--no-cache"
    ;;

    n)
      # do docker run non-interactively
      INTERACTIVE=""
    ;;

    h)
      help
      exit 0
    ;;

    e)
      ENV_FILE=${OPTARG}
      if [ ! -f "${ENV_FILE}" ]; then
          echo "Error: ${ENV_FILE} Not Found"
          help
      fi
      ENV_FILE="--env-file=${ENV_FILE}"
    ;;

    v)
      NEW_VOL=${OPTARG}
      echo "Adding volume: ${NEW_VOL}"
      if [ "$NEW_VOL" = "" ]; then
          help
      fi
      DOCKER_VOLUMES="${DOCKER_VOLUMES} -v ${NEW_VOL}"
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

# If the build flag is set, build the docker image
# Build container if the image does not exist, the cache needs to be rebuilt, or the build flag is set
if ! docker images | grep -q "${DOCKER_IMAGE_TAG}" \
    || [ -n "$BUILD_CACHE" ] \
    || [ $BUILD_IMAGE_FLAG -eq 1 ]; then
    build_image ${DOCKERFILE}
fi

if [[ ! -d "$WORK_DIR" ]]; then
    echo "WORK_DIR=${WORK_DIR} does not exits. Creating.."
    mkdir ${WORK_DIR}
fi

# If ENV_FILE wasn't set and default .env exits, add it
if [ -f "${WORK_DIR}/.env" ] && [ -z "${ENV_FILE}" ]; then
  ENV_FILE="--env-file ${WORK_DIR}/.env"
fi

# run the docker image
#   --rm  automatically removes the container and on exit
#   --init  run an init process inside the container that forwards signals and reaps processes (helps when buildserver cancels the job)
#   -i  keeps the standard input open
#   -t  provides a terminal as a interactive shell within container
#   -v  are file systems mounted on docker container to preserve data
#       generated during the build and these are stored on the host.
#   --network host  use the host network stack inside the container (no network isolation).  This helps VPN work inside the container.
# 
# INTERACTIVE=-it
docker run --init ${INTERACTIVE} --rm --privileged --network host --name "${DOCKER_CONTAINER_NAME}" \
    --add-host ${HOSTNAME}:127.0.0.1 \
    --hostname ${HOSTNAME} \
    ${DOCKER_VOLUMES} \
    ${ENV_FILE} \
    "${DOCKER_IMAGE_TAG}" \
    "$@"

