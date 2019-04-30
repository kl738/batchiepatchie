#!/bin/bash

set -euxo pipefail

# This script is the entry point for the Go Reporting application when
# running inside the docker container.

# https://denibertovic.com/posts/handling-permissions-with-docker-volumes/
# This dance let's the Docker image create directories when run locally with
# docker-compose.
export VERSION=`cat version`

# Get local IP address; or just assume it is 127.0.0.1
BATCHIEPATCHIE_IP=$(curl http://instance-data/latest/meta-data/local-ipv4) || BATCHIEPATCHIE_IP=127.0.0.1
export BATCHIEPATCHIE_IP

BUILD_ENV_ENV=${BUILD_ENV:-}

if [ "${BUILD_ENV_ENV}" = "DEBUG" ]; then
    # Runs the Delve debugger in headless mode.
    dlv debug --headless=true --listen=:9999 --accept-multiclient=true --api-version=1
fi;

if [ "${BUILD_ENV_ENV}" = "PRODUCTION" ]; then
    sleep 5
    go build
    ./batchiepatchie
else
    sleep 5
    # Runs the application through Fresh for code reloading.
    fresh -c fresh.conf
fi;
