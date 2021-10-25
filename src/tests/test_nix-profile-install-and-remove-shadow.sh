#!/bin/sh

set -x

nix profile install nixpkgs#shadow \
&& newuimap \
&& echo "$(nix eval --raw nixpkgs#shadow)" \
&& nix profile remove "$(nix eval --raw nixpkgs#shadow)" \
&& newuimap || echo 'Expected error happed, it is ok!' \
&& du -hs /nix \
&& nix store gc --verbose \
&& du -hs /nix
