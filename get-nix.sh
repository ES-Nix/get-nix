#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x

command -v nix >/dev/null 2>&1 || curl -L https://nixos.org/nix/install | sh \
&& test -d ~/.config/nix || mkdir --parent --mode=755 ~/.config/nix && touch ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'nixos' >/dev/null && /bin/true || echo 'system-features = kvm nixos-test' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'flakes' >/dev/null && /bin/true || echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf \
&& cat ~/.config/nix/nix.conf | grep 'trace' >/dev/null && /bin/true || echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& test -d ~/.config/nixpkgs || mkdir --parent --mode=755 ~/.config/nixpkgs && touch ~/.config/nixpkgs/config.nix \
&& cat ~/.config/nixpkgs/config.nix | grep 'allowUnfree' >/dev/null && /bin/true || echo '{ allowUnfree = true; }' >> ~/.config/nixpkgs/config.nix


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
