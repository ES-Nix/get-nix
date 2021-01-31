#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail
set -eux

# Are these all flake deps??
nix-env --install --attr nixpkgs.commonsCompress nixpkgs.gnutar nixpkgs.lzma.bin nixpkgs.git


# The next par need it
nix-env --install --attr nixpkgs.gnugrep

test -d ~/.config/nix || mkdir --parent --mode=755 ~/.config/nix && touch ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'nixos' >/dev/null || echo 'system-features = kvm nixos-test' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'flakes' >/dev/null || echo 'experimental-features = nix-command flakes ca-references' >> ~/.config/nix/nix.conf \
&& test -d ~/.config/nixpkgs || mkdir --parent --mode=755 ~/.config/nixpkgs && touch ~/.config/nixpkgs/config.nix \
&& cat ~/.config/nixpkgs/config.nix | grep 'allowUnfree' >/dev/null && /bin/true || echo '{ allowUnfree = true; }' >> ~/.config/nixpkgs/config.nix \
&& cat ~/.bashrc | grep 'flake' >/dev/null || echo "alias flake='nix-shell -I nixpkgs=channel:nixos-20.09 --packages nixFlakes'" >> ~/.bashrc \
&& cat ~/.bashrc | grep 'collect' >/dev/null || echo "alias nd='nix-collect-garbage --delete-old'" >> ~/.bashrc

. ~/.bashrc

# Broken, why this does not existe?
# . "$HOME"/.nix-profile/etc/profile.d/nix.sh \

flake
nd

du --human-readable --summarize --total /nix
