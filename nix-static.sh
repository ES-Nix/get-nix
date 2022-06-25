#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x

# What is the best, more compatible, way?
# cd ~
# cd "$HOME"
cd /home/"$USER"

BASE="$HOME"/.local/bin
# BUILD_ID='178718571'
BUILD_ID='181545168'

toybox --version 1> /dev/null 2> /dev/null || curl -L http://landley.net/toybox/downloads/binaries/0.8.7/toybox-x86_64 > toybox && chmod 0755 toybox


./toybox test -d "$BASE" || ./toybox mkdir -v -p -m 0755 "$BASE"
toybox --version 1> /dev/null 2> /dev/null || ./toybox mv toybox "$BASE" && export PATH="$BASE":"$PATH"

# curl -L https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist > nix
toybox which nix || curl -L https://hydra.nixos.org/build/"${BUILD_ID}"/download/2/nix > "$BASE"/nix

toybox chmod -v 0700 "$BASE"/nix
# toybox test -d /home/"$USER"/nix || toybox mkdir -v -p -m 0755 /home/"$USER"/nix

# test -f 'result/bin/nix' || echo 'Error the path does not exist: ''result/bin/nix'
# cp -v result/bin/nix "${BASE}"
#echo 'export PATH="${HOME}"/.local/bin:"${PATH}"' >> ~/."$(ps -ocomm= -q $$)"rc \
#&& ~/."$(ps -ocomm= -q $$)"rc


toybox test -d ~/.config/nix || toybox mkdir -p -m 0755 ~/.config/nix \
&& toybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || toybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& toybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || toybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
&& toybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || toybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& toybox test -d ~/.config/nixpkgs || toybox mkdir -p -m 0755 ~/.config/nixpkgs \
&& toybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || toybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix

toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'derivations' || toybox echo 'keep-derivations = true' >> /home/"$USER"/.config/nix/nix.conf
toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'outputs' || toybox echo 'keep-outputs = true' >> /home/"$USER"/.config/nix/nix.conf


test -d /nix || sudo mkdir -v /nix && sudo -k chown -Rv "$(id -u)":"$(id -g)" /nix


# Main idea from: https://stackoverflow.com/a/1167849
BASHRC_NIX_FUNCTIONS=$(toybox cat <<-'EOF'
# It was inserted by the get-nix installer
export TMPDIR=/tmp
export PATH="$HOME"/.local/bin:"$PATH"
export NIX_PROFILES="/nix/var/nix/profiles/default /home/"$USER"/.nix-profile"
# End of inserted by the get-nix installer
EOF
)

# Really important the double quotes in the PROFILE_NIX_FUNCTIONS variable echo, see:
# https://stackoverflow.com/a/18126699
# To preserve the format of the echoed code.
if [ ! -f /home/nix_user/.profile ]; then
  echo "$BASHRC_NIX_FUNCTIONS" > /home/"$USER"/.profile
else
  toybox grep 'flake' /home/"$USER"/.profile -q || echo "$BASHRC_NIX_FUNCTIONS" >> /home/"$USER"/.profile
fi

toybox rm -fv "$BASE"/toybox

