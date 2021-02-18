#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x

command -v nix >/dev/null 2>&1 || curl -L https://nixos.org/nix/install | sh \
&& test -d ~/.config/nix || mkdir --parent --mode=755 ~/.config/nix && touch ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'nixos' >/dev/null && /bin/true || echo 'system-features = kvm nixos-test' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'flakes' >/dev/null && /bin/true || echo 'experimental-features = nix-command flakes ca-references' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'trace' >/dev/null && /bin/true || echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& test -d ~/.config/nixpkgs || mkdir --parent --mode=755 ~/.config/nixpkgs && touch ~/.config/nixpkgs/config.nix \
&& cat ~/.config/nixpkgs/config.nix | grep 'allowUnfree' >/dev/null && /bin/true || echo '{ allowUnfree = true; }' >> ~/.config/nixpkgs/config.nix \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/.bashrc

# It looks like it does not work
#&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
#&& . ~/.bashrc


# Main idea from: https://stackoverflow.com/a/1167849
BASHRC_NIX_FUNCTIONS=$(cat <<-EOF
flake () {
    echo "Entering the nix + flake shell."
    # Would it be usefull to have the "" to pass arguments?
    nix-shell -I nixpkgs=channel:nixos-20.09 --packages nixFlakes
}

nd () {
   nix-collect-garbage --delete-old
}

develop () {
    echo "Entering the nix + flake development shell."
    nix-shell -I nixpkgs=channel:nixos-20.09 --packages nixFlakes --run 'nix develop'
}
EOF
)

# Really important the double quotes in the PROFILE_NIX_FUNCTIONS variable echo, see:
# https://stackoverflow.com/a/18126699
# To preserve the format of the echoed code.
if [ ! -f ~/.bashrc ]; then
  echo "$BASHRC_NIX_FUNCTIONS" > ~/.bashrc
else
  grep 'flake' ~/.bashrc --quiet || echo "$BASHRC_NIX_FUNCTIONS" >> ~/.bashrc
fi

