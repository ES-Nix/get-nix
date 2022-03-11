#!/bin/sh

set -x

podman \
image \
exists \
localhost/test-nix-installer || podman \
build \
--network=host \
--file=src/tests/Containerfile \
--tag=test-nix-installer


podman \
run \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--privileged=true \
--tty=true \
--rm=true \
--user=nixuser \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
--volume=/dev/shm:/dev/shm:ro \
--volume=/dev/snd:/dev/snd:ro \
--volume="$(pwd)":/home/nixuser/code:rw \
--workdir=/home/nixuser \
localhost/test-nix-installer





sudo \
podman \
run \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--privileged=true \
--tty=true \
--rm=true \
--user=nixuser \
--volume=/lib/modules:/lib/modules:ro \
--volume=/dev/mapper:/dev/mapper:rw \
--volume="$(pwd)":/home/nixuser/code:rw \
--volume=/sys/fs/cgroup:/sys/fs/cgroup:rw \
--workdir=/home/nixuser \
localhost/test-nix-installer




