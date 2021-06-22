
# One more hack...
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment83000217_11097703
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment3450154_3327027
NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)
echo 'The installer has identified the runnig shell as: '"$NIX_GUESSED_USER_SHELL"

GUESSED_SHELL_RC='~/.'"$NIX_GUESSED_USER_SHELL"'rc'

nix profile install nixpkgs#direnv
nix profile install nixpkgs#nix-direnv
echo 'source $(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc' >> ~/.direnvrc
echo 'export PATH=$(nix eval --raw nixpkgs#direnv)/bin:"$PATH"' >> "$GUESSED_SHELL_RC"
echo 'export PATH=$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc:"$PATH"' >> "$GUESSED_SHELL_RC"
echo 'eval "$(direnv hook bash)"' >> "$GUESSED_SHELL_RC"
. "$GUESSED_SHELL_RC"
. ~/.direnvrc
direnv --version

nix profile install nixpkgs#gnused

sudo \
su \
<< COMMANDS
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
