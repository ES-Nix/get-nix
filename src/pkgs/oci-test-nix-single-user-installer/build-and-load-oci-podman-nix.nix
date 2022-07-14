{ pkgs ? import <nixpkgs> { }, podman-rootless }:
pkgs.stdenv.mkDerivation rec {
  name = "build-and-load-oci-podman-nix";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [
    bash
    coreutils
    podman-rootless

    (import ./build-local-or-remote.nix { inherit pkgs; })
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
