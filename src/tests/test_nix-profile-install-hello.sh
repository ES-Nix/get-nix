#!/bin/sh

set -x

nix profile install nixpkgs#hello \
&& hello \
&& echo "$(nix eval --raw nixpkgs#hello)" \
&& nix profile remove "$(nix eval --raw nixpkgs#hello)" \
&& hello || echo 'Expected error happed, it is ok!' \
&& du -hs /nix \
&& nix store gc --verbose \
&& du -hs /nix
