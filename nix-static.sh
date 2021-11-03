#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x

# What is the best, more compatible, way?
# cd ~
# cd "$HOME"
cd /home/"$USER"

toybox --version 1> /dev/null 2> /dev/null || curl -L http://landley.net/toybox/downloads/binaries/0.8.5/toybox-x86_64 > toybox && chmod 0755 toybox

BASE="$HOME"/.local/bin

./toybox test -d "$BASE" || ./toybox mkdir -v -p -m 0755 "$BASE"
toybox --version 1> /dev/null 2> /dev/null || ./toybox mv toybox "$BASE" && export PATH="$BASE":"$PATH"

# curl -L https://hydra.nixos.org/job/nix/master/buildStatic.x86_64-linux/latest/download-by-type/file/binary-dist > nix
toybox which nix || curl -L https://hydra.nixos.org/build/156399089/download/2/nix > "$BASE"/nix
toybox chmod -v 0700 "$BASE"/nix

toybox test -d /home/"$USER"/nix || toybox mkdir -v -p -m 0755 /home/"$USER"/nix

toybox test -d "$HOME"/.config/nix || toybox mkdir -p -m 0755 "$HOME"/.config/nix && toybox touch "$HOME"/.config/nix/nix.conf

toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'nixos' || toybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> /home/"$USER"/.config/nix/nix.conf
toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'flakes' || toybox echo 'experimental-features = nix-command flakes ca-references' >> /home/"$USER"/.config/nix/nix.conf
toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'trace' || toybox echo 'show-trace = true' >> /home/"$USER"/.config/nix/nix.conf


toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'derivations' || toybox echo 'keep-derivations = true' >> /home/"$USER"/.config/nix/nix.conf
toybox cat /home/"$USER"/.config/nix/nix.conf | toybox grep 'outputs' || toybox echo 'keep-outputs = true' >> /home/"$USER"/.config/nix/nix.conf


toybox test -d /home/"$USER"/.config/nixpkgs || toybox mkdir -v -p -m 0755 /home/"$USER"/.config/nixpkgs && toybox touch /home/"$USER"/.config/nixpkgs/config.nix
toybox cat /home/"$USER"/.config/nixpkgs/config.nix | toybox grep 'allowUnfree' || toybox echo '{ allowUnfree = true; }' >> /home/"$USER"/.config/nixpkgs/config.nix


# Main idea from: https://stackoverflow.com/a/1167849
BASHRC_NIX_FUNCTIONS=$(toybox cat <<-EOF
# It was inserted by the get-nix installer
export TMPDIR=/tmp
export PATH="\$HOME"/.local/bin:"\$PATH"
export NIX_PROFILES="/nix/var/nix/profiles/default /home/"\$USER"/.nix-profile"
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

# . $HOME/.profile

#cd /home/"$USER"/bin
#sudo su << COMMANDS
#./toybox cat << 'EOF' >> /etc/passwd
#nixbld1:x:122:30000:Nix build user 1:/var/empty:/sbin/nologin
#nixbld2:x:121:30000:Nix build user 2:/var/empty:/sbin/nologin
#nixbld3:x:120:30000:Nix build user 3:/var/empty:/sbin/nologin
#nixbld4:x:119:30000:Nix build user 4:/var/empty:/sbin/nologin
#nixbld5:x:118:30000:Nix build user 5:/var/empty:/sbin/nologin
#nixbld6:x:117:30000:Nix build user 6:/var/empty:/sbin/nologin
#nixbld7:x:116:30000:Nix build user 7:/var/empty:/sbin/nologin
#nixbld8:x:115:30000:Nix build user 8:/var/empty:/sbin/nologin
#nixbld9:x:114:30000:Nix build user 9:/var/empty:/sbin/nologin
#nixbld10:x:113:30000:Nix build user 10:/var/empty:/sbin/nologin
#nixbld11:x:112:30000:Nix build user 11:/var/empty:/sbin/nologin
#nixbld12:x:111:30000:Nix build user 12:/var/empty:/sbin/nologin
#nixbld13:x:110:30000:Nix build user 13:/var/empty:/sbin/nologin
#nixbld14:x:109:30000:Nix build user 14:/var/empty:/sbin/nologin
#nixbld15:x:108:30000:Nix build user 15:/var/empty:/sbin/nologin
#nixbld16:x:107:30000:Nix build user 16:/var/empty:/sbin/nologin
#nixbld17:x:106:30000:Nix build user 17:/var/empty:/sbin/nologin
#nixbld18:x:105:30000:Nix build user 18:/var/empty:/sbin/nologin
#nixbld19:x:104:30000:Nix build user 19:/var/empty:/sbin/nologin
#nixbld20:x:103:30000:Nix build user 20:/var/empty:/sbin/nologin
#nixbld21:x:102:30000:Nix build user 21:/var/empty:/sbin/nologin
#nixbld22:x:101:30000:Nix build user 22:/var/empty:/sbin/nologin
#nixbld23:x:999:30000:Nix build user 23:/var/empty:/sbin/nologin
#nixbld24:x:998:30000:Nix build user 24:/var/empty:/sbin/nologin
#nixbld25:x:997:30000:Nix build user 25:/var/empty:/sbin/nologin
#nixbld26:x:996:30000:Nix build user 26:/var/empty:/sbin/nologin
#nixbld27:x:995:30000:Nix build user 27:/var/empty:/sbin/nologin
#nixbld28:x:994:30000:Nix build user 28:/var/empty:/sbin/nologin
#nixbld29:x:993:30000:Nix build user 29:/var/empty:/sbin/nologin
#nixbld30:x:992:30000:Nix build user 30:/var/empty:/sbin/nologin
#nixbld31:x:991:30000:Nix build user 31:/var/empty:/sbin/nologin
#nixbld32:x:990:30000:Nix build user 32:/var/empty:/sbin/nologin
#EOF
#
#./toybox cat << 'EOF' >> /etc/group
#nixbld:x:30000:nixbld1,nixbld2,nixbld3,nixbld4,nixbld5,nixbld6,nixbld7,nixbld8,nixbld9,nixbld10,nixbld11,nixbld12,nixbld13,nixbld14,nixbld15,nixbld16,nixbld17,nixbld18,nixbld19,nixbld20,nixbld21,nixbld22,nixbld23,nixbld24,nixbld25,nixbld26,nixbld27,nixbld28,nixbld29,nixbld30,nixbld31,nixbld32
#EOF
#
#./toybox mkdir -p /nix
#
## ./toybox mkdir -p /home/"$USER"/nix/var/nix/profiles/per-user
## ./toybox mkdir -p /home/"$USER"/nix/var/nix/temproots
## ./toybox mkdir -p /home/"$USER"/nix/var/nix/gcroots
## ./toybox mkdir -p /home/"$USER"/nix/var/nix/db
## ./toybox mkdir -p /home/"$USER"/nix/store/.links
#
#./toybox chown \
#   -R \
#   $(./toybox echo "$USER"): \
#   /nix
#COMMANDS
