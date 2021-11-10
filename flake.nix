{
  description = "It is a helper to test the installer's scripts";

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

#        tests = pkgsAllowUnfree.writeShellScriptBin "tests" ''
#          ./src/tests/tests.sh
#        '';

        sha256sumNixFlakeVersion = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-flake-version" ''
          # How to use a shebang here like ${pkgsAllowUnfree.coreutils}?
          # echo $(which sha256sum)
          nix_tmp="$(mktemp)"
          nix --version > "$nix_tmp"
          echo -n a99c1e9acc7d215f308a4918620cd14e3a80860174aea3447a0b014da736f4e8 "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
        '';

        sha256sumNixShowConfigJSON = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-show-config-json" ''
          nix_tmp="$(mktemp)"
          nix show-config --json > "$nix_tmp"
          #sha256sum "$nix_tmp"
          echo -n 6c9efc7738afde14a2a33e4827858007fa31d667124f9c3b8a225d7b64e61b68 "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
        '';

        sha256sumNixStoreQueryRequisites = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-store-query-requisites" ''
          nix_tmp="$(mktemp)"
          echo "$(nix-store --query --requisites "$(which nix)")" | tr ' ' '\n' > "$nix_tmp"
          #sha256sum "$nix_tmp"
          echo -n 5ec70359cf3cb063252b9efc10106d44cfcdd4de8a22d5ab9c9577bb3f9efcba "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
        '';

        sha256sumnixProfileInstallHello = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-profile-install-hello" ''
          nix_tmp="$(mktemp)"
          nix profile install nixpkgs#hello
          hello > "$nix_tmp"
          # sha256sum "$nix_tmp"
          echo -n d9014c4624844aa5bac314773d6b689ad467fa4e1d1a50a1b8a99d5a95f72ff5 "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
          nix profile remove "$(nix eval --raw nixpkgs#hello)"
          ! hello 1> /dev/null 2> /dev/null || echo 'Error the program hello still installed!'
        '';

        sha256sumRawEvalNixFlakes = pkgsAllowUnfree.writeShellScriptBin "sha256sum-raw-eval-nixFlakes" ''
          nix_tmp="$(mktemp)"
          echo -n "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)"/bin > "$nix_tmp"
          # sha256sum "$nix_tmp"
          echo -n 5886497eaf6c4336e909c80b0fceaca4d58729ed0c4d9256fc4dd0f81aae6fed "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
        '';

        testNix = pkgsAllowUnfree.writeShellScriptBin "test-nix" ''
          set -ex

          nix \
          run \
          github:edolstra/dwarffs -- --version
          nix store gc --verbose

          nix \
          flake \
          show \
          github:GNU-ES/hello
          nix store gc --verbose

          nix \
          build \
          nixpkgs#hello \
          --no-out-link

          nix \
          shell \
          github:GNU-ES/hello \
          --command \
          hello
          nix store gc --verbose

          nix \
          build \
          github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp
          nix store gc --verbose

          nix \
          build \
          github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso
          nix store gc --verbose

        '';

        run = pkgsAllowUnfree.writeShellScriptBin "run" ''
          "$@"
        '';

        testConfig1 = pkgsAllowUnfree.writeShellScriptBin "test_config_1" ''
          system_features="$(busybox mktemp)"
          nix show-config | busybox grep 'system-features' | busybox cut -d ' ' -f3- | busybox tr ' ' '\n' | busybox sort > "$system_features"
          #busybox sha256sum "$system_features"
          busybox echo "e409ceb415ad70f19d7ac63f5c1000e6ec73d9b2e5d8a055c4f6d0e425d3a9f2  $system_features" | busybox sha256sum -c
          busybox rm "$system_features"


          experimental_features="$(mktemp)"
          nix show-config | busybox grep 'experimental-features' | busybox cut -d ' ' -f3- | busybox tr ' ' '\n' | busybox sort > "$system_features"
          #busybox sha256sum "$experimental_features"
          busybox echo "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855  $experimental_features" | busybox sha256sum -c
          busybox rm "$experimental_features"
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

        nixFlakeVersion = pkgsAllowUnfree.writeShellScriptBin "nix-flake-version" ''
          ${pkgsAllowUnfree.nixFlakes}/bin/nix flake --version
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

            sha256sumNixFlakeVersion
            sha256sumNixShowConfigJSON
            sha256sumNixStoreQueryRequisites
            sha256sumnixProfileInstallHello
            sha256sumRawEvalNixFlakes

            run
            testNix
            testConfig1

          ]
          ++
          # Why nix fllake check is broken if aarch64-darwin is not excluded??
          (if !isDarwin then [ self.inputs.podman-rootless.defaultPackage.${system} ] else [ ]);

          shellHook = ''
            export TMPDIR=/tmp
            # cat "$(echo $(type build-oci) | cut -d' ' -f3)"
            # echo abc "${ toString isDarwin}"

#            sha256sum-nix-flake-version
#            sha256sum-nix-show-config-json
#            sha256sum-nix-store-query-requisites
#            sha256sum-nix-profile-install-hello
#            sha256sum-raw-eval-nixFlakes
#            test-nix
#            run
          '';
        };

        checks.nixpkgs-fmt = pkgsAllowUnfree.runCommand "check-nix-format" { } ''
          ${pkgsAllowUnfree.nixpkgs-fmt}/bin/nixpkgs-fmt --check ${./.}
          mkdir $out #sucess
        '';

        checks.nix-version = pkgsAllowUnfree.runCommand "check-nix-format" { } ''
          ${nixFlakeVersion}/bin/nix-flake-version
          mkdir $out #sucess
        '';

      }
    );
}



