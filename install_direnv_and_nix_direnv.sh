#!/bin/sh
# One more hack...
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment83000217_11097703
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment3450154_3327027
# NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)


NIX_GUESSED_USER_SHELL="$(basename "$(grep "$USER" </etc/passwd | cut -f 7 -d ":")")"

echo 'The installer has identified the running shell as: '"${NIX_GUESSED_USER_SHELL}"

FULL_PATH_TO_GUESSED_SHELL_RC="${HOME}"/."${NIX_GUESSED_USER_SHELL}"rc
# FULL_PATH_TO_DIRENVRC="${HOME}"/.direnvrc

OPEN_STRING_EVAL_DIRENV_HOOK='eval "$(direnv hook '
CLOSE_STRING_EVAL_DIRENV_HOOK=')"'
FULL_STRING_EVAL_DIRENV_HOOK="${OPEN_STRING_EVAL_DIRENV_HOOK}""${NIX_GUESSED_USER_SHELL}""${CLOSE_STRING_EVAL_DIRENV_HOOK}"

# nix flake metadata github:NixOS/nixpkgs/release-22.05
readlink "$(which direnv)" >/dev/null || nix profile install github:NixOS/nixpkgs/60e774ff2ca18570a93a2992fd18b8f5bf3ba57b#direnv

# FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC='source "${HOME}"/.nix-profile/share/nix-direnv/direnvrc'
# test -f $(readlink -f "${FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC}") || nix profile install nixpkgs#nix-direnv
# direnv --version


# grep \
# -q \
# -s \
# "${FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC}" \
# "${FULL_PATH_TO_DIRENVRC}" || echo "${FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC}" >> "${FULL_PATH_TO_DIRENVRC}"


grep \
-q \
-s \
"${FULL_STRING_EVAL_DIRENV_HOOK}" \
"${FULL_PATH_TO_GUESSED_SHELL_RC}" || echo "${FULL_STRING_EVAL_DIRENV_HOOK}" >> "${FULL_PATH_TO_GUESSED_SHELL_RC}"

