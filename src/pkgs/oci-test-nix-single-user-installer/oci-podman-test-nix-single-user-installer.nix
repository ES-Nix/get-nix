{ pkgs ? import <nixpkgs> { }, podman-rootless }:
pkgs.stdenv.mkDerivation rec {
  name = "oci-podman-test-nix-single-user-installer";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils

    # findutils

    podman-rootless

    # Testing
    xorg.xhost

    (import ./build-and-load-oci-podman-nix.nix { inherit pkgs podman-rootless; })
  ];

  src = builtins.path { path = ./.; inherit name; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp -r "${src}"/* $out

    install \
    -m0755 \
    $out/scripts/${name}.sh \
    -D \
    $out/bin/${name}

    patchShebangs $out/bin/${name}

    substituteInPlace \
      $out/bin/${name} \
      --replace Containerfile $out/Containerfile

    wrapProgram $out/bin/${name} \
      --prefix PATH : "${pkgs.lib.makeBinPath propagatedNativeBuildInputs }"
  '';

}
