{ pkgs ? import <nixpkgs> { } }:
let
  troubleshoot-packages = with pkgs; [
    file
    findutils
    # gzip
    hello
    htop
    iproute
    nano
    netcat
    ripgrep
    strace
    # gnutar
    wget
    which
  ];

  # customSudo = (pkgs.pkgsStatic.sudo.override { pam = null; });
  # customSu = (pkgs.pkgsStatic.shadow.override { pam = null; }).su;

  userName = "nixuser";
  userGroup = "nixgroup";
in
pkgs.dockerTools.buildImage {
  name = "test-nix-single-user-installer";
  tag = "0.0.1";

  contents = (with pkgs; [
    bashInteractive
    coreutils
  ]
    # ++ troubleshoot-packages
  )
  ++
  (with pkgs.pkgsStatic; [
    gnutar
    xz
    curl
    ]
  )
  ;

  config = {
    # Cmd = [ "nix" ];
    Entrypoint = [ "${pkgs.bashInteractive}/bin/bash" ];
    # Entrypoint = [ "es" ];
    # Entrypoint = [ "${pkgs.coreutils}/bin/stat" ];
    Env = [
      # "FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
      # "FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts/"
      # TODO
      # https://access.redhat.com/solutions/409033
      # https://github.com/nix-community/home-manager/issues/703#issuecomment-489470035
      # https://bbs.archlinux.org/viewtopic.php?pid=1805678#p1805678
      # "LC_ALL=C"
      #
      #
      # https://gist.github.com/eoli3n/93111f23dbb1233f2f00f460663f99e2#file-rootless-podman-wayland-sh-L25
      # "LD_LIBRARY_PATH=${pkgs.libcanberra-gtk3}/lib/gtk-3.0/modules"
      # 
      # TODO: document it
      # https://unix.stackexchange.com/a/230442
      # "NO_AT_BRIDGE=1"
      # 
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      # "GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
      # "NIX_PAGER=cat"
      # A user is required by nix
      # https://github.com/NixOS/nix/blob/9348f9291e5d9e4ba3c4347ea1b235640f54fd79/src/libutil/util.cc#L478
      "USER=${userName}"
      "HOME=/home/${userName}"
      # "PATH=/bin:/home/${userName}/bin"
      # "NIX_PATH=/nix/var/nix/profiles/per-user/root/channels"
      "TMPDIR=/home/${userName}/tmp"
    ];
  };

  # sudo chown "$(id -u)":"$(id -g)" -R /nix
  # chmod 0655 /nix
  # nix flake metadata nixpkgs
  #
  # sudo mkdir -pv /nix/var/nix/profiles
  # sudo chown "$(id -u)":"$(id -g)" -R /nix/var/nix/profiles
  #
  #
  # sudo mkdir -pv "${HOME}"/.cache
  # sudo chown "$(id -u)":"$(id -g)" -R "${HOME}"/.cache
  #
  # sudo chmod 0755 -R /nix
  # sudo chown "$(id -u)":"$(id -g)" -R /nix
  #
  # nix flake metadata nixpkgs
  #
  # chmod 0755 -R ./nix
  # chown nixuser:nixgroup -R ./nix
  runAsRoot = ''
    #!${pkgs.stdenv}
    ${pkgs.dockerTools.shadowSetup}

    echo 'Some message from runAsRoot echo.'

    groupadd --gid 6789 nixgroup
    useradd --no-log-init --uid 1234 --gid nixgroup ${userName}


    groupadd --gid 302 kvm
    usermod --append --groups kvm ${userName}

    test -d ./etc/sudoers.d || mkdir -pv ./etc/sudoers.d
    echo 'nixuser ALL=(ALL) NOPASSWD: ALL' > ./etc/sudoers.d/nixuser

    # Is it ugly or beautiful?
    test -d ./tmp || mkdir -pv ./tmp
    chmod 1777 ./tmp

    test -d ./home/nixuser/tmp || mkdir -pv ./home/nixuser/tmp
    chmod 1777 ./home/nixuser/tmp

    # https://www.reddit.com/r/ManjaroLinux/comments/sdkrb1/comment/hue3gnp/?utm_source=reddit&utm_medium=web2x&context=3
    mkdir -pv ./home/nixuser/.local/share/fonts
    chown nixuser:nixgroup -R ./home/nixuser/.local/share/fonts

    test -d ./home/nixuser/.cache || mkdir -pv ./home/nixuser/.cache
    chown nixuser:nixgroup -R ./home/nixuser/.cache

    test -d ./root/.config/nix || mkdir -pv ./root/.config/nix
    echo 'experimental-features = nix-command flakes' > /root/.config/nix/nix.conf

    test -d ./root/.config/nix || mkdir -pv ./root/.config/nixpkgs/
    echo '{ nixpkgs.config.allowUnfree = true; }' > ./root/.config/config.nix

    # mkdir -pv ./nix/store/.links
    # chown 1234:6789 ./nix
    # chown 1234:6789 ./nix/store
    # chown 1234:6789 ./nix/store/.links
  '';

  extraCommands = ''
    #!${pkgs.stdenv}

    test -d ./home/nixuser/.config/nix || mkdir -pv ./home/nixuser/.config/nix
    echo 'experimental-features = nix-command flakes' > ./home/nixuser/.config/nix/nix.conf
    
    test -d ./home/nixuser/.config/nix || mkdir -pv ./home/nixuser/.config/nixpkgs/
    echo '{ nixpkgs.config.allowUnfree = true; }' > ./home/nixuser/.config/config.nix
  '';

}
