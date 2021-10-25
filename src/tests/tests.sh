#!/bin/sh

set -x

podman \
build \
--network=host \
--file Containerfile \
--tag test-nix-installer

podman \
run \
--log-level=error \
--privileged=true \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--network=host \
--tty=false \
--rm=true \
--user=nixuser \
localhost/test-nix-installer \
<<COMMANDS
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "\$USER": /nix \
&& SHA256=7c60027233ae556d73592d97c074bc4f3fea451d \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"\$SHA256"/get-nix.sh | sh \
&& . "\$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."\$(ps -ocomm= -q \$\$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="\$(readlink -f \$(which nix-env))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -fv /nix/store/*-nix-2.3.1*/bin/nix \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version
COMMANDS


podman \
run \
--log-level=error \
--privileged=false \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--network=slirp4netns \
--tty=false \
--rm=true \
--user=nixuser \
localhost/test-nix-installer \
<<COMMANDS
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "\$USER": /nix \
&& SHA256=7c60027233ae556d73592d97c074bc4f3fea451d \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"\$SHA256"/get-nix.sh | sh \
&& . "\$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."\$(ps -ocomm= -q \$\$)"rc \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="\$(readlink -f \$(which nix-env))" \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --keep OLD_NIX_PATH --packages nixFlakes --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install nixpkgs#nixFlakes' \
&& sudo rm -fv /nix/store/*-nix-2.3.1*/bin/nix \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version
COMMANDS


#podman \
#run \
#--log-level=error \
#--privileged=true \
#--device=/dev/fuse \
#--device=/dev/kvm \
#--env="DISPLAY=${DISPLAY:-:0.0}" \
#--interactive=true \
#--tty=true \
#--rm=true \
#--user=nixuser \
#localhost/test-nix-installer
