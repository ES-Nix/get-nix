#!/bin/bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

set -x


nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs


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
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
ubuntu:21.04



mkdir -p /home/nixuser/tmp
chown -R nixuser: /home/nixuser/tmp

export TMPDIR=/home/nixuser/tmp

nix build nixpkgs#nixFlakes
nix flake metadata nixpkgs
nix build github:NixOS/nixpkgs/736b4edf537e2f03bf8e8c7bb5f6d7d395d648ae#nixFlakes
result/bin/nix flake --version
readlink -f "$(which result/bin/nix)"
/nix/store/p64jysmz67vyy4nnj6wkg3dk26fzc2gd-nix-2.4pre20210601_5985b8b/bin/nix

result/bin/nix build nixpkgs#nixFlakes --out-link

test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=adf595ee99c71a0a9b885d0d57dd683011e00764 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="$(readlink -f $(which nix-env))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -fv /nix/store/*-nix-2.3.1*/bin/nix \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc --verbose \
&& nix flake --version

RUN mkdir -m 0755 /nix && chown pedro: /nix

USER pedro

# RUN curl -L https://nixos.org/nix/install | sh
RUN echo "123" | sudo -S curl -L https://nixos.org/nix/install | sh \
 && echo '. /home/pedro/.nix-profile/etc/profile.d/nix.sh' >> ~/.bashrc

ONBUILD ENV \
    ENV=/etc/profile \
    USER=pedro \
    PATH=/nix/var/nix/profiles/per-user/pedro/profile/bin:/nix/var/nix/profiles/per-user/pedro/profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

ENV \
    ENV=/etc/profile \
    USER=pedro \
    PATH=/nix/var/nix/profiles/per-user/pedro/profile/bin:/nix/var/nix/profiles/per-user/pedro/profile/sbin:/bin:/sbin:/usr/bin:/usr/sbin \
    GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt \
    NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
    NIX_PATH=/nix/var/nix/profiles/per-user/pedro/channels


 \
&& echo 'The podman rootless instalation has finished!' \
podman \
run \
--privileged=true \
--device=/dev/fuse \
--device=/dev/kvm \
--env=DISPLAY=':0.0' \
--interactive=true \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--tty=false \
--rm=true \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMANDS

COMMANDS
