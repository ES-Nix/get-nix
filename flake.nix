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
          # set -e

          # How to use a shebang here like ${pkgsAllowUnfree.coreutils}?
          # echo $(which sha256sum)
          nix_tmp="$(mktemp)"
          # sha256sum "$nix_tmp"
          nix --version > "$nix_tmp"
          echo -n 27df00965d46f540ae6015104f83f528684191148589ade190becc6282844d30 "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
        '';

         # TODO: needs some more thinking about this, maybe not use --json and filter
         # some impure key's value?
#        sha256sumNixShowConfigJSON = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-show-config-json" ''
#          # set -ex
#
#          nix_tmp="$(mktemp)"
#          nix show-config --json > "$nix_tmp"
#           sha256sum "$nix_tmp"
#          echo -n d4d1992e16f698b21050c3cd1450d3a75e2a5bdeb32c98c3299ac50b05128ea1 "$nix_tmp" | sha256sum --check
#          rm "$nix_tmp"
#        '';

        sha256sumNixStoreQueryRequisites = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-store-query-requisites" ''
          set -ex

#          nix_tmp="$(mktemp)"
#          echo "$(nix-store --query --requisites "$(nix eval --raw nixpkgs#nix)")"/bin/nix | tr ' ' '\n' > "$nix_tmp"
#           sha256sum "$nix_tmp"
#          echo -n 01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b "$nix_tmp" | sha256sum --check
#          rm "$nix_tmp"
        '';

        sha256sumnixProfileInstallHello = pkgsAllowUnfree.writeShellScriptBin "sha256sum-nix-profile-install-hello" ''
          # set -ex


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
          # set -ex

          nix_tmp="$(mktemp)"
          echo -n "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)"/bin > "$nix_tmp"
          # sha256sum "$nix_tmp"
          echo -n 5886497eaf6c4336e909c80b0fceaca4d58729ed0c4d9256fc4dd0f81aae6fed "$nix_tmp" | sha256sum --check
          rm "$nix_tmp"
        '';

        testNixFromOnlynixpkgs = pkgsAllowUnfree.writeShellScriptBin "test-nix-from-only-nixpkgs" ''
          set -ex

          nix \
          shell \
          nixpkgs/a3f85aedb1d66266b82d9f8c0a80457b4db5850c#{\
          bashInteractive,\
          gcc10,\
          gcc6,\
          gfortran10,\
          gfortran6,\
          nodejs,\
          qemu,\
          poetry,\
          python39,\
          rustc,\
          yarn\
          } \
          --command \
          bash \
          -c \
          "gcc --version \
          && python --version \
          && gcc --version \
          && gfortran --version \
          && node --version \
          && qemu-kvm --version \
          && poetry --version \
          && rustc --version \
          && yarn --version
          "

          nix \
          store \
          gc \
          --verbose

          # nix \
          # flake \
          # metadata \
          # github:nixos/nixpkgs/nixpkgs-unstable
          # nix run github:nixos/nixpkgs/nixpkgs-unstable#nix -- --version
          nix \
          run \
          github:nixos/nixpkgs/d14ae62671fd4eaec57427da1e50f91d6a5f9605#nix -- --version

          nix \
          run \
          github:nixos/nixpkgs/d14ae62671fd4eaec57427da1e50f91d6a5f9605#nixFlakes -- --version

          # nix \
          # flake \
          # metadata \
          # github:nixos/nixpkgs/master
          # nix run github:nixos/nixpkgs/master#nix -- --version
          nix \
          run \
          github:nixos/nixpkgs/04cf6dc67f8e29bd086ebd1dc9ad7c8262913347#nix -- --version

          nix \
          run \
          github:nixos/nixpkgs/04cf6dc67f8e29bd086ebd1dc9ad7c8262913347#nixFlakes -- --version

          nix \
          store \
          gc \
          --verbose
        '';

        testNix = pkgsAllowUnfree.writeShellScriptBin "test-nix" ''
          set -ex


          nix flake show github:serokell/templates

          nix \
          flake \
          check \
          github:edolstra/dwarffs

          nix \
          run \
          github:edolstra/dwarffs -- --version
          nix store gc --verbose

#          nix \
#          flake \
#          check \
#          github:ES-Nix/podman-rootless/from-nixpkgs
          nix \
          flake \
          show \
          github:ES-Nix/podman-rootless/from-nixpkgs
          nix store gc --verbose

          nix \
          build \
          github:ES-Nix/podman-rootless/from-nixpkgs \
          --no-link

          nix \
          build \
          github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp \
          --no-link
          nix store gc --verbose

          nix \
          build \
          github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso \
          --no-link
          nix store gc --verbose
        '';

        run = pkgsAllowUnfree.writeShellScriptBin "run" ''
          "$@"
        '';

        allTests = pkgsAllowUnfree.writeShellScriptBin "all-tests" ''
          sha256sum-nix-flake-version
          # sha256sum-nix-show-config-json
          sha256sum-nix-store-query-requisites
          sha256sum-nix-profile-install-hello
          sha256sum-raw-eval-nixFlakes

          test-nix-from-only-nixpkgs
          test_config_1
          test-nix
        '';

        testConfig1 = pkgsAllowUnfree.writeShellScriptBin "test_config_1" ''
          set -ex

          nix \
          profile \
          install \
          nixpkgs#busybox

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

          nix \
          profile \
          remove \
          "$(nix eval --raw nixpkgs#busybox)"
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

            sha256sumNixFlakeVersion
#            sha256sumNixShowConfigJSON
            sha256sumNixStoreQueryRequisites
            sha256sumnixProfileInstallHello
            sha256sumRawEvalNixFlakes

            run
            testNix
            testNixFromOnlynixpkgs
            testConfig1
            allTests
          ]
          ++
          # Why nix flake check is broken if aarch64-darwin is not excluded??
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

        checks.nix-version = pkgsAllowUnfree.runCommand "check-nix-format" { } ''
          ${nixFlakeVersion}/bin/nix-flake-version
          mkdir $out #sucess
        '';

      }
    );
}
