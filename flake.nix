{
  description = "It is a helper to test the script";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixos.url = "github:nixos/nixpkgs/nixos-unstable";
    podman-rootless.url = "github:ES-Nix/podman-rootless/from-nixpkgs";
  };

  outputs = { self, nixpkgs, nixos, flake-utils, podman-rootless }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgsAllowUnfree = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        tests = pkgsAllowUnfree.writeShellScriptBin "tests" ''
          ./src/tests/tests.sh
        '';

        buildOCI = pkgsAllowUnfree.writeShellScriptBin "build-oci" ''
          podman \
          build \
          --network=host \
          --file=src/tests/Containerfile \
          --tag=test-nix-installer
        '';

        OCIUbuntu = pkgsAllowUnfree.writeShellScriptBin "oci-ubuntu" ''
          ./src/tests/oci-ubuntu.sh
        '';
        # isDarwin = system == "x86_64-darwin";
        isDarwin = system == "aarch64-darwin";
      in
      {
        #        packages.image = import ./default.nix {
        #          pkgs = nixpkgs.legacyPackages.${system};
        #          nixos = nixos;
        #        };

        # TODO
        # https://github.com/NixOS/nix/issues/2854
        #      defaultPackage = self.packages.${system};

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
            bashInteractive
            coreutils
            file
            nixpkgs-fmt
            which

            buildOCI
            OCIUbuntu
            tests

            # Why nix fllake check is broken??
          ]
          ++
          (if !isDarwin then [ self.inputs.podman-rootless.defaultPackage.${system} ] else [ ]);

          shellHook = ''
            export TMPDIR=/tmp
            # cat "$(echo $(type build-oci) | cut -d' ' -f3)"
            # echo abc "${ toString isDarwin}"
          '';
        };

        checks.nixpkgs-fmt = pkgsAllowUnfree.runCommand "check-nix-format" { } ''
          ${pkgsAllowUnfree.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
          mkdir $out #sucess
        '';
      }
    );
}



