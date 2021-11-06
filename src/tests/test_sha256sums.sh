#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x

#./code/src/tests/test_sha256sums.sh

nix_tmp="$(mktemp)"
nix --version > "$nix_tmp"
echo -n a99c1e9acc7d215f308a4918620cd14e3a80860174aea3447a0b014da736f4e8 "$nix_tmp" | sha256sum --check
rm "$nix_tmp"

# It is not pure, sad.
# Paths like ls -al /nix/store/*-source are changing from installation to other
#nix_tmp="$(mktemp)"
#jq --version || nix profile install nixpkgs#jq
##nix flake metadata nixpkgs --json | jq .
#nix flake metadata nixpkgs --json | jq . | grep -v lastModified > "$nix_tmp"
##sha256sum "$nix_tmp"
#echo -n 1ac6635742938a2d2344c8ba6595490e878d5beea8f2f9ffdeff4076fa2c07a4 "$nix_tmp" | sha256sum --check
#rm "$nix_tmp"

nix_tmp="$(mktemp)"
nix show-config --json > "$nix_tmp"
#sha256sum "$nix_tmp"
echo -n 6c9efc7738afde14a2a33e4827858007fa31d667124f9c3b8a225d7b64e61b68 "$nix_tmp" | sha256sum --check
rm "$nix_tmp"

nix_tmp="$(mktemp)"
echo "$(nix-store --query --requisites "$(which nix)")" | tr ' ' '\n' > "$nix_tmp"
#sha256sum "$nix_tmp"
echo -n 5ec70359cf3cb063252b9efc10106d44cfcdd4de8a22d5ab9c9577bb3f9efcba "$nix_tmp" | sha256sum --check
rm "$nix_tmp"


# Good reference: http://xion.io/post/code/shell-xargs-into-find.html
nix_tmp="$(mktemp)"
echo "$(nix-store --query --requisites "$(which nix)")" | sort | tr ' ' '\n'  | xargs -I{} find {} -type f | xargs -n 1 sha256sum | sort > "$nix_tmp"
#sha256sum "$nix_tmp"
echo -n dd1128ba712e15a4849c7a0da73801cb8b542837847deec74f30d61d62aca1e2 "$nix_tmp"  | sha256sum --check
rm "$nix_tmp"

#nix_tmp="$(mktemp)"
##nix flake metadata nixpkgs
##nix flake metadata github:NixOS/nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes
#nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes > "$nix_tmp"
#sha256sum "$nix_tmp"
#echo -n 0002fd0f1216647e72eef5460eee3bb20f6d2eb8284d4bde3da6cfbb20b07536 "$nix_tmp" | sha256sum --check
#rm "$nix_tmp"


echo "$PATH" | grep '.nix-profile/bin' 1> /dev/null  || echo 'Error'

[ "$(echo "$PATH" | tr ':' '\n' | grep '.nix-profile/bin' | wc -l)" -eq 1 ] || echo 'Error'
