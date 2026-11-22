#!/usr/bin/env bash

set -euo pipefail

COMMAND="bash"

function log() {
  if [ -v VERBOSE ]; then
    echo "${1}"
  fi
}

function usage() {
  printf "Usage:\n"
  printf "\t%s -h\n" "$(basename "${0}")"
  printf "\t%s [-v] [-c COMMAND]\n" "$(basename "${0}")"
}

function help() {
  usage
  printf "\nBuild Docker image and run container from it. "
  printf "\n"
  printf "Positional arguments:\n"
  printf "\n"
  printf "Options:\n"
  printf "\t-c COMMAND\tCommand to run in container (default: %s)\n" "${COMMAND}"
  printf "\t-h\t\tPrint this message and exit\n"
  printf "\t-v\t\tEnable verbose output\n"
}

function remove_image() {
  if [ -v IMAGE ]; then
    docker rmi -f "${IMAGE}" > /dev/null
    log "Removed image ${IMAGE}"
    unset IMAGE
  fi
}

function remove_iidfile() {
  if [ -v IIDFILE ]; then
    rm "${IIDFILE}"
    unset IIDFILE
  fi
}

function cleanup() {
  remove_iidfile
  remove_image
}

unset IMAGE
unset VERBOSE

trap cleanup EXIT

while getopts "c:hv" ARG; do
  case $ARG in
    h)
      help
      exit 0
      ;;
    v)
      set -x
      VERBOSE=1
      ;;
    c)
      COMMAND="${OPTARG}"
      ;;
    *)
      usage
      exit 1
      ;;
    esac
done

log "Command: ${COMMAND}"
log "Building image..."

IMAGE_USER="${USER}"
IMAGE_USER_ID="$(id -u)"
IMAGE_USER_HOME="${HOME}"
IMAGE_CONAN_VENV="/venvs/conan"
DOCKER_QUIET_FLAG="-q"
if [ -v VERBOSE ]; then
  DOCKER_QUIET_FLAG=""
fi
IIDFILE=$(mktemp /tmp/tmp.iidfile-XXXXXX)
docker build \
  ${DOCKER_QUIET_FLAG} \
  --iidfile "${IIDFILE}" \
  -f Dockerfile \
  --build-arg IMAGE_CONAN_VENV="${IMAGE_CONAN_VENV}" \
  --build-arg IMAGE_USER="${IMAGE_USER}" \
  --build-arg IMAGE_USER_ID="${IMAGE_USER_ID}" \
  --build-arg IMAGE_USER_HOME="${IMAGE_USER_HOME}" \
  .
IMAGE=$(cat "${IIDFILE}")

log "Built image: ${IMAGE}"

TTY_FLAG="-i"
if [ -t 0 ]; then
  TTY_FLAG="-it"
fi

WORKDIR="${PWD}"
CONAN_HOME="${WORKDIR}/.conan2/"
docker run \
  --rm \
  ${TTY_FLAG} \
  -v "${PWD}:${WORKDIR}" \
  -w "${WORKDIR}" \
  -e "CONAN_HOME=${CONAN_HOME}" \
  --network=host \
  "${IMAGE}" \
  bash -c "${COMMAND}"
