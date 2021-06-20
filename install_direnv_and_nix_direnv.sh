nix profile install nixpkgs#direnv
nix profile install nixpkgs#nix-direnv
echo 'source $(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc' >> ~/.direnvrc
echo 'export PATH=$(nix eval --raw nixpkgs#direnv)/bin:"$PATH"' >> ~/.bashrc
echo 'export PATH=$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc:"$PATH"' >> ~/.bashrc
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
. ~/.bashrc
. ~/.direnvrc
direnv --version

