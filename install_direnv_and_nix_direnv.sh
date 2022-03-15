
# One more hack...
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment83000217_11097703
# https://stackoverflow.com/questions/3327013/how-to-determine-the-current-shell-im-working-on#comment3450154_3327027
# NIX_GUESSED_USER_SHELL=$(ps -ocomm= -q $$)


NIX_GUESSED_USER_SHELL="$(basename $(grep $USER </etc/passwd | cut -f 7 -d ":"))"

echo 'The installer has identified the running shell as: '"${NIX_GUESSED_USER_SHELL}"

FULL_PATH_TO_GUESSED_SHELL_RC="${HOME}"/."${NIX_GUESSED_USER_SHELL}"rc
FULL_PATH_TO_DIRENVRC="${HOME}"/.direnvrc

FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC='source "${HOME}"/.nix-profile/share/nix-direnv/direnvrc'
STRING_EVAL_DIRENV_HOOK='eval "$(direnv hook '
FULL_STRING_EVAL_DIRENV_HOOK="${STRING_EVAL_DIRENV_HOOK}""${NIX_GUESSED_USER_SHELL}"')"'

test -x direnv || nix profile install nixpkgs#direnv
test -f $(readlink -f "${FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC}") || nix profile install nixpkgs#nix-direnv
direnv --version


grep \
-q \
-s \
"${FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC}" \
"${FULL_PATH_TO_DIRENVRC}" || echo "${FULL_STRING_NIX_PROFILE_SHARE_NIX_DIRENV_DIRENVRC}" >> "${FULL_PATH_TO_DIRENVRC}"


grep \
-q \
-s \
"${FULL_STRING_EVAL_DIRENV_HOOK}" \
"${FULL_PATH_TO_GUESSED_SHELL_RC}" || echo "${FULL_STRING_EVAL_DIRENV_HOOK}" >> "${FULL_PATH_TO_GUESSED_SHELL_RC}"

