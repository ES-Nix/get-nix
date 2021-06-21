nix profile install nixpkgs#direnv
nix profile install nixpkgs#nix-direnv
echo 'source $(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc' >> ~/.direnvrc
echo 'export PATH=$(nix eval --raw nixpkgs#direnv)/bin:"$PATH"' >> ~/.bashrc
echo 'export PATH=$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc:"$PATH"' >> ~/.bashrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
. ~/.bashrc
. ~/.direnvrc
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
