#!/usr/bin/env sh


FLAKE_NAME=$1
FLAKE_ATTR=$2

if nix flake metadata .# 1> /dev/null 2> /dev/null; then
  echo 'Local building'
  nix build --refresh .#"${FLAKE_ATTR}"
else
    echo "Using flake from github remote definition"
  nix build --refresh "${FLAKE_NAME}"#"${FLAKE_ATTR}"
fi


