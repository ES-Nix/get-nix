
# One more hack...
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment83000217_11097703
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment3450154_3327027
# NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)

NIX_GUESSED_USER_SHELL="$(basename $(grep $USER </etc/passwd | cut -f 7 -d ":"))"

echo 'The installer has identified the runnig shell as: '"$NIX_GUESSED_USER_SHELL"

GUESSED_SHELL_RC=~/."$NIX_GUESSED_USER_SHELL"rc

echo 'Debuging the GUESSED_SHELL_RC='"$GUESSED_SHELL_RC"

nix profile install nixpkgs#direnv
nix profile install nixpkgs#nix-direnv
echo 'WWWWWW'
echo 'source $(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc' >> ~/.direnvrc

# https://stackoverflow.com/a/29685539
# sed -i '/^[^#]/ s/\(^.*plugins.*$\)/#\ \1/' "$GUESSED_SHELL_RC"

echo 'export DIRENV_BASH=$(which bash)' >> "$GUESSED_SHELL_RC"
echo 'export PATH=$(nix eval --raw nixpkgs#direnv)/bin:"$PATH"' >> "$GUESSED_SHELL_RC"
echo 'export PATH=$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc:"$PATH"' >> "$GUESSED_SHELL_RC"
echo 'AAAAA' \
&& echo 'eval "$(direnv hook '"$NIX_GUESSED_USER_SHELL"')"' >> "$GUESSED_SHELL_RC"

sudo rm -fv /nix/store/*-nix-2.3.12/bin/nix
# && echo '#####' \
# && GUESSED_SHELL_RC=~/."$NIX_GUESSED_USER_SHELL"rc \
# && . "$GUESSED_SHELL_RC" \
# && echo 'RRRRRRR' \
. ~/.direnvrc
# echo 'QQQQQ'
direnv --version

nix profile install nixpkgs#gnused

sudo su << COMMANDS
sed \
-i \
's/NIX_BIN_PREFIX=.*/NIX_BIN_PREFIX=\"\$(nix eval --raw nixpkgs#nixFlakes)\"\/bin\//' \
$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc

sed \
-i \
'/.*NIX_BIN_PREFIX=\$(command -v nix-shell)/d' \
$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc
COMMANDS

nix profile remove nixpkgs#gnused
