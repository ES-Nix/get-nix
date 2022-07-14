#!/usr/bin/env sh

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

#set -x
#export NIX_VERSION_URL='nix-2.5pre20211026_5667822'
#export URL_TO_CURL="https://github.com/numtide/nix-flakes-installer/releases/download/"$NIX_VERSION_URL"/install"
#command -v nix >/dev/null 2>&1 || curl -fsSL "$URL_TO_CURL" | sh
#unset NIX_VERSION_URL
#unset URL_TO_CURL
#
#. "$HOME"/.nix-profile/etc/profile.d/nix.sh \
#&& export TMPDIR=/tmp
#
#nix \
#profile \
#install \
#nixpkgs#busybox \
#--option \
#experimental-features 'nix-command flakes ca-references ca-derivations'
#
#
#busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
#&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
#&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes ca-references ca-derivations' >> ~/.config/nix/nix.conf \
#&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
#&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
#&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; }' >> ~/.config/nixpkgs/config.nix

# Got it from:
# https://github.com/numtide/nix-unstable-installer/releases
#
# NIX_RELEASE_VERSION=${1:-nix-2.8.0pre20220314_a618097}
# curl -L 'https://github.com/numtide/nix-flakes-installer/releases/download/'"${NIX_RELEASE_VERSION}"'/install' | sh


# https://nixos.org/download.html
# https://releases.nixos.org/nix/nix-2.10.1/install
NIX_RELEASE_VERSION=${1:-2.10.1}

curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --no-daemon

. "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& export TMPDIR=/tmp


nix \
profile \
install \
github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#busybox \
--option \
experimental-features 'nix-command flakes'


busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix

# If there is one line with only '-e ' removes it.
# Nix 2.4 installer let it alone in the ~/.profile.
# busybox sed -i 's/^-e $//' ~/.profile

nix \
profile \
remove \
"$(nix eval --raw github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#busybox)"



# It should be cleaned in the future.
# I think now it is a bad idea couple this things, I mean,
# the installer and this injection of some bash utils functions.

# Main idea from: https://stackoverflow.com/a/1167849
NIX_HELPER_FUNCTIONS=$(cat <<-EOF

# It was inserted by the get-nix installer
develop () {
    echo "Entering the nix + flake development shell.";
    nix develop "\$@";
}

export TMPDIR=/tmp

#
PATH="\$HOME"/.nix-profile/bin:"\$PATH"
# End of code inserted by the get-nix installer
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

NIX_GUESSED_USER_SHELL="$(basename "$(grep "$USER" </etc/passwd | cut -f 7 -d ":")")"

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

elif [ "$NIX_GUESSED_USER_SHELL" = 'sh' ]
then

  # Really important the double quotes in the PROFILE_NIX_FUNCTIONS variable echo, see:
  # https://stackoverflow.com/a/18126699
  # To preserve the format of the echoed code.
  if [ ! -f ~/.ashrc ]; then
    echo "$NIX_HELPER_FUNCTIONS" > ~/.ashrc
  else
    grep 'flake' ~/.ashrc --quiet || echo "$NIX_HELPER_FUNCTIONS" >> ~/.ashrc
  fi

else
  echo "Your current shell is not suported, sorry."
  exit 123
fi
