# When you add custom packages, list them here
{ pkgs, podman-rootless }: {

  oci-test-nix-single-user-installer = pkgs.callPackage ./oci-test-nix-single-user-installer { };
  oci-podman-test-nix-single-user-installer = pkgs.callPackage ./oci-test-nix-single-user-installer/oci-podman-test-nix-single-user-installer.nix { podman-rootless = podman-rootless; };

}
