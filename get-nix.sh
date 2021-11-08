#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x
export NIX_VERSION_URL='nix-2.5pre20211026_5667822'
export URL_TO_CURL="https://github.com/numtide/nix-flakes-installer/releases/download/"$NIX_VERSION_URL"/install"
command -v nix >/dev/null 2>&1 || curl -fsSL "$URL_TO_CURL" | sh
unset NIX_VERSION_URL
unset URL_TO_CURL

test -d ~/.config/nix || mkdir --parent --mode=0755 ~/.config/nix && touch ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'nixos' >/dev/null && /bin/true || echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'flakes' >/dev/null && /bin/true || echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'trace' >/dev/null && /bin/true || echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& test -d ~/.config/nixpkgs || mkdir --parent --mode=0755 ~/.config/nixpkgs && touch ~/.config/nixpkgs/config.nix \
&& cat ~/.config/nixpkgs/config.nix | grep 'allowUnfree' >/dev/null && /bin/true || echo '{ allowUnfree = true; }' >> ~/.config/nixpkgs/config.nix

. "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& export OLD_NIX_PATH="$(readlink -f $(which nix))" \
&& echo $OLD_NIX_PATH \
&& nix-shell \
    --arg pkgs 'import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/20.09.tar.gz") {}' \
    --keep OLD_NIX_PATH \
    --packages nixFlakes \
    --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install github:NixOS/nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old --verbose \
&& nix store gc --verbose \
&& nix flake --version \
&& chmod 0755 -v "$HOME"/.nix-profile \
&& chmod 0755 -v "$HOME"/.nix-profile/bin \
&& chmod 0755 -v "$HOME"/.nix-profile/bin/nix \
&& chmod 0755 -v "$HOME"/.nix-profile/etc \
&& chmod 0755 -v "$HOME"/.nix-profile/etc/profile.d \
&& chmod 0755 -v "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& export aux1="$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)"'/bin' \
&& export aux2='    export PATH='"${aux1}"':"$PATH"' \
&& stat "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& sed -i 's|unset NIX_LINK|&\n'"${aux2}"'|' "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& echo

#\
#&& nix profile install nixpkgs#hello \
#&& nix profile remove "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" \
#&& nix profile remove "$(nix eval --raw nixpkgs#hello)"


#&& mv "$HOME"/.nix-profile/bin/nix "${aux1}"/nix_ \
#&& rm -fv "$HOME"/.nix-profile/bin/nix \
#&& mv "${aux1}"/nix_ "${aux1}"/nix

# Main idea from: https://stackoverflow.com/a/1167849
NIX_HELPER_FUNCTIONS=$(cat <<-EOF

# It was inserted by the get-nix installer
flake () {
    echo "Entering the nix + flake shell.";
    # Would it be usefull to have the "" to pass arguments?
    nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes;
}

nd () {
   nix-collect-garbage --delete-old;
}

develop () {
    echo "Entering the nix + flake development shell.";
    nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix develop';
}

export TMPDIR=/tmp
. "\$HOME"/.nix-profile/etc/profile.d/nix.sh

# End of inserted by the get-nix installer
EOF
)

# Tried it, but did not work, but need to test it again.
# Maybe use this to source ~/.zshrc or ~/.bashrc?
# NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment83000217_11097703

# NIX_GUESSED_USER_SHELL==$(ps -p "$$" -o 'comm=')
# NIX_GUESSED_USER_SHELL=$(echo $0)
# https://unix.stackexchange.com/a/352430
# NIX_GUESSED_USER_SHELL="$(basename $(grep $USER </etc/passwd | cut -f 7 -d ":"))"

# NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)

NIX_GUESSED_USER_SHELL="$(basename $(grep $USER </etc/passwd | cut -f 7 -d ":"))"

if [ "$NIX_GUESSED_USER_SHELL" = 'zsh' ];
then

  if [ ! -f ~/.zshrc ]; then
    echo "$NIX_HELPER_FUNCTIONS" > ~/.zshrc
  else
    grep 'flake' ~/.zshrc --quiet || echo "$NIX_HELPER_FUNCTIONS" >> ~/.zshrc
  fi

elif [ "$NIX_GUESSED_USER_SHELL" = 'bash' ]
then

  # Really important the double quotes in the PROFILE_NIX_FUNCTIONS variable echo, see:
  # https://stackoverflow.com/a/18126699
  # To preserve the format of the echoed code.
  if [ ! -f ~/.bashrc ]; then
    echo "$NIX_HELPER_FUNCTIONS" > ~/.bashrc
  else
    grep 'flake' ~/.bashrc --quiet || echo "$NIX_HELPER_FUNCTIONS" >> ~/.bashrc
  fi

else
  echo "Your current shell is not suported, sorry."
  exit 123
fi
