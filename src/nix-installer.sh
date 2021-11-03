#!/bin/bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

set -x

test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="$(readlink -f $(which nix))" \
&& echo $OLD_NIX_PATH \
&& nix-shell \
    --arg pkgs 'import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/20.09.tar.gz") {}' \
    --keep OLD_NIX_PATH \
    --packages nixFlakes \
    --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install github:NixOS/nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#pkgsStatic.nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old --verbose \
&& nix store gc --verbose \
&& nix flake --version
