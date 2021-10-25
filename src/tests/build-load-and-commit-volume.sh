#!/bin/sh

set -x


podman \
build \
--network=host \
--file Containerfile \
--tag test-nix-installer

BASE_IMAGE='localhost/test-nix-installer'
CONTAINER='container-to-commit'
DOCKER_OR_PODMAN=podman
IMAGE='test-nix-installer'
TAG="${1:-latest}"

"$DOCKER_OR_PODMAN" rm --force --ignore "$CONTAINER"

"$DOCKER_OR_PODMAN" \
run \
--entrypoint='' \
--log-level=error \
--privileged=true \
--interactive=true \
--name="$CONTAINER" \
--network=host \
--tty=false \
--rm=false \
--user=nixuser \
--volume "$(pwd)":/code \
--workdir=/home/nixuser \
"$BASE_IMAGE" \
bash \
<< COMMANDS
/code/nix-installer.sh
COMMANDS

#--change ENTRYPOINT=entrypoint.sh \
ID=$("$DOCKER_OR_PODMAN" \
commit \
"$CONTAINER" \
"$IMAGE":"$TAG")

"$DOCKER_OR_PODMAN" rm --force --ignore "$CONTAINER"