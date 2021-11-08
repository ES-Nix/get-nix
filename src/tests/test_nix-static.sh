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
nix store gc --verbose
toybox du -sh /nix


nix shell nixpkgs#hello --command hello
nix shell nixpkgs#busybox --command id
nix run nixpkgs#busybox id

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

nix \
--store \
"$HOME"/store \
build \
github:NixOS/nix#nix-static



#podman \
#run \
#--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
#--env="DISPLAY=${DISPLAY:-:0.0}" \
#--interactive=true \
#--log-level=error \
#--tty=true \
#--rm=true \
#--user=0 \
#--volume="$(pwd)":/code \
#docker.nix-community.org/nixpkgs/nix-flakes
#
#mkdir --parent --mode=0755 ~/.config/nix
#echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf
#
#nix build github:NixOS/nix#nix-static
#
#du -hs result/bin/nix
#cp result/bin/nix /code
#
#
#mkdir --parent --mode=0755 "$HOME"/store
#
#nix \
#--store \
#"$HOME"/store \
#build \
#github:NixOS/nix#nix-static
#
#
#ls store/nix/store/$(echo $(readlink -f inseption-nix)/bin/nix | cut -d'/' -f'4-')

sudo apt-get update \
&& sudo apt-get install -y podman

podman \
run \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--log-level=error \
--tty=false \
--rm=true \
--user=0 \
--volume="$(pwd)":/code \
docker.nix-community.org/nixpkgs/nix-flakes \
<<COMMAND
mkdir --parent --mode=0755 ~/.config/nix
echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf

nix build github:NixOS/nix/4a2b7cc68c7d11ec126bc412ffea838e629345af#nix-static

echo -n ec74eb0971c4f54a8e3c25344db051640ead538292d566fa526430eb2579fffe result/bin/nix | sha256sum --check

du -hs result/bin/nix
cp result/bin/nix /code
COMMAND


test -d ~/.config/nix || mkdir --parent --mode=0755 ~/.config/nix && touch ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'nixos' >/dev/null && /bin/true || echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'flakes' >/dev/null && /bin/true || echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'trace' >/dev/null && /bin/true || echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& test -d ~/.config/nixpkgs || mkdir --parent --mode=0755 ~/.config/nixpkgs && touch ~/.config/nixpkgs/config.nix \
&& cat ~/.config/nixpkgs/config.nix | grep 'allowUnfree' >/dev/null && /bin/true || echo '{ allowUnfree = true; }' >> ~/.config/nixpkgs/config.nix \
&& mkdir --parent --mode=0755 "$HOME"/store


#nix build github:NixOS/nix/4a2b7cc68c7d11ec126bc412ffea838e629345af#nix-static

sudo rm "$(readlink -f "$(which nix)")"
#./nix profile install nixpkgs#hello
#./nix develop github:ES-Nix/fhs-environment/enter-fhs
#
#find / -name '*nix*' \
#  -not \( -path "/home/ubuntu/code/*" \) \
#  -not \( -path "/proc/*" \) \
#  -not \( -path "/usr/*" \) \
#  -not \( -path "/tmp/*" \) \
#  -not \( -path "/snap/*" \) \
#  -not \( -path "/etc/*" \) \
#  -not \( -path "/boot/*" \) \
#  -not \( -path "/sys/*" \) \
#  -exec echo -- {} + 2>/dev/null

# https://unix.stackexchange.com/a/651928
mkdir -p "$HOME"/.local/bin
echo 'export PATH="$HOME"/.local/bin:"${PATH}"' >> "$HOME"/.bashrc


chmod -v 0755 nix
mv nix "$HOME"/.local/bin
chmod -v 0555 "$HOME"/.local/bin
. "$HOME"/.bashrc


# Tests

nix flake --version
nix --store "$HOME" flake metadata nixpkgs

nix shell --store "$HOME" nixpkgs#nix-info --command nix-info --markdown

# half broken
nix run --store "$HOME" nixpkgs#nix-info --markdown

# Broken
#nix --store "$HOME" flake metadata github:edolstra/dwarffs
nix flake metadata github:edolstra/dwarffs
nix --store "$HOME" doctor
nix --store "$HOME" store verify --all
nix --store "$HOME" store optimise


du -sh "$HOME"/nix
nix --store "$HOME" store gc --dry-run
nix --store "$HOME" store gc --verbose
du -sh "$HOME"/nix


nix --store "$HOME" flake show github:NixOS/nixpkgs/478cfa6f4bec2ee1fb7df8ef38e3b80cbbdcecc5
#nix --store "$HOME" flake show github:NixOS/nixpkgs/478cfa6f4bec2ee1fb7df8ef38e3b80cbbdcecc5 --legacy

# Building a copy of itself

nix \
build \
github:NixOS/nix/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nix-static \
&& result/bin/nix flake --version \
&& echo -n ec74eb0971c4f54a8e3c25344db051640ead538292d566fa526430eb2579fffe result/bin/nix | sha256sum --check \
&& rm -frv result \
&& nix store gc # --verbose




nix \
--store \
"$HOME" \
build \
github:NixOS/nix/4a2b7cc68c7d11ec126bc412ffea838e629345af#nix-static

cp nix/store/$(echo $(readlink result)/bin/nix | cut -d'/' -f'4-') nix-inseption

echo 'ec74eb0971c4f54a8e3c25344db051640ead538292d566fa526430eb2579fffe nix-inseption' | sha256sum -c

chmod 0755 nix-inseption
rm nix-inseption


##

nix \
--store \
"$HOME" \
build \
nixpkgs#gcc

cat nix/store/$(echo $(readlink result)/bin/gcc | cut -d'/' -f'4-')


#

nix --store "$HOME" shell nixpkgs#hello --command hello
nix --store "$HOME" shell nixpkgs#busybox --command id
nix --store "$HOME" run nixpkgs#busybox id

nix --store "$HOME" shell nixpkgs#python3Minimal --command python --version
nix --store "$HOME" shell nixpkgs#kvm --command qemu-kvm --version


# nix --store "$HOME" registry add nixpkgs github:NixOS/nixpkgs/a3f85aedb1d66266b82d9f8c0a80457b4db5850c

nix \
shell \
nixpkgs/a3f85aedb1d66266b82d9f8c0a80457b4db5850c#{\
gcc10,\
gcc6,\
gfortran10,\
gfortran6,\
nodejs,\
poetry,\
python39,\
rustc,\
yarn\
}

gcc --version
gfortran --version
node --version
poetry --version
python3 --version
rustc --version
yarn --version

# julia is broken
# nix --store "$HOME" shell nixpkgs#julia --command julia --version

# nix --store "$HOME" shell github:edolstra/dwarffs

# nix --store "$HOME" registry add nixpkgs github:NixOS/nixpkgs/5272327b81ed355bbed5659b8d303cf2979b6953

#

nix \
build \
--store "$HOME" \
nixpkgs#hello

ls -al nix/store/$(echo $(readlink result)/bin/hello | cut -d'/' -f'4-')

#


nix \
profile \
install \
--store "$HOME" \
nixpkgs#hello


ls -al nix/store/$(echo $(readlink result)/bin/hello | cut -d'/' -f'4-')

#


nix \
shell \
--store "$HOME" \
nixpkgs/f5b9a25cdd21b4e45ab5f11c27b95dfe17384274#podman \
--command \
podman \
--version


nix \
shell \
--store "$HOME" \
nixpkgs#podman \
--command \
podman \
--version


nix \
--store "$HOME" \
profile \
install \
nixpkgs#shadow


podman \
run \
--log-level=error \
--rm=true \
docker.io/library/alpine:3.14.2 \
apk add --no-cache curl
