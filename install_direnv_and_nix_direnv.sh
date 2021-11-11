
# One more hack...
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment83000217_11097703
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment3450154_3327027
# NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)

NIX_GUESSED_USER_SHELL="$(basename $(grep $USER </etc/passwd | cut -f 7 -d ":"))" \
&& echo 'The installer has identified the runnig shell as: '"$NIX_GUESSED_USER_SHELL" \
&& GUESSED_SHELL_RC=~/."$NIX_GUESSED_USER_SHELL"rc \
&& nix profile install nixpkgs#direnv \
&& nix profile install nixpkgs#nix-direnv \
&& direnv --version \
&& echo 'source $(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc' >> ~/.direnvrc \
&& echo 'export PATH=$(nix eval --raw nixpkgs#direnv)/bin:"$PATH"' >> "$GUESSED_SHELL_RC" \
&& echo 'export PATH=$(nix eval --raw nixpkgs#nix-direnv)/share/nix-direnv/direnvrc:"$PATH"' >> "$GUESSED_SHELL_RC" \
&& echo 'eval "$(direnv hook '"$NIX_GUESSED_USER_SHELL"')"' >> "$GUESSED_SHELL_RC"

