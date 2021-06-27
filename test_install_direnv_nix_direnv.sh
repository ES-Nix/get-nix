cd ~
mkdir foo-bar

cd foo-bar

git init

cat <<WRAP > flake.nix
{
  description = "A very basic flake";
  # Provides abstraction to boiler-code when specifying multi-platform outputs.
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.\${system};
    in {
      devShell = pkgs.mkShell {
        buildInputs = with pkgs; [ hello ];
      };
    });
}
WRAP


echo 'use flake' >> .envrc \
&& direnv allow \
&& git add . \
&& cd .. \
&& cd -

