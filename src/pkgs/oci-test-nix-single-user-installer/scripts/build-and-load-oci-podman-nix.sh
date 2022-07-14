#!/usr/bin/env sh


# set -x

FLAKE_NAME=$1
FLAKE_ATTR=$2
IMAGE_NAME=$3

# Is it a bad thing? I think in small cases it would be useful.
build-local-or-remote "${FLAKE_NAME}" "${FLAKE_ATTR}"


podman load < result

podman \
build \
--file Containerfile \
--tag "${IMAGE_NAME}" \
.

