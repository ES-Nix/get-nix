
nix \
build \
--impure \
--expr \
'(
with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}.pkgsStatic;
(podman.override { postFixup = ""; })
)'

