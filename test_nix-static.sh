#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x

nix \
build \
github:NixOS/nix#nix-static

toybox file result/bin/nix
result/bin/nix --version
toybox sha1sum result/bin/nix

toybox du -sh /nix
nix store gc --dry-run
nix store gc
toybox du -sh /nix

result/bin/nix \
build \
github:NixOS/nix#nix-static

toybox file result/bin/nix
result/bin/nix --version
toybox sha1sum result/bin/nix
toybox stat result/bin/nix
toybox wc -c < result/bin/nix

# Adapted from: https://unix.stackexchange.com/a/16645
toybox rm -fv result
nix store gc
toybox du -sh /nix


nix shell nixpkgs#hello --command hello
nix shell nixpkgs#busybox --command id

result/bin/nix \
develop \
github:ES-Nix/nix-flakes-shellHook-writeShellScriptBin-defaultPackage/65e9e5a64e3cc9096c78c452b51cc234aa36c24f \
--command \
podman \
run \
--interactive=true \
--tty=true \
alpine:3.13.0 \
sh \
-c 'uname --all && apk add --no-cache git && git init'



nix doctor
nix store verify
nix store optimise


nix \
shell \
github:GNU-ES/hello

nix \
develop \
github:GNU-ES/hello

nix \
build \
github:GNU-ES/hello
result/bin/hello

nix show-derivation /nix/store/*-hello-20210221.drv


nix build nixpkgs#qemu

nix \
build \
github:ES-Nix/podman-rootless/706380778786b88d4886a2c43e1924e200cb5023


result/bin/podman \
run \
-it \
alpine:3.13.0 \
sh \
-c 'uname --all'

#nix \
#--store \
#"$HOME" \
#build \
#github:NixOS/nix#nix-static
