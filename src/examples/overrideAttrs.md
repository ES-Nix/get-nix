

https://www.youtube.com/watch?v=6VepnulTfu8



###

ssh-keygen -lf ~/.ssh/id_ed25519.pub


export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
--extra-experimental-features 'nix-command flakes' \
shell \
--impure \
--expr \
'(with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
with legacyPackages.${builtins.currentSystem}; 
(openssl_1_1.overrideAttrs (oldAttrs: {
  src = fetchurl {
    url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1o.tar.gz;
    sha256 = "sha256-k4SisFcN2ANYhBRkZ3EV33he25QccSEfdQdtcv5rQ48=";
  };
  makeFlags = openssl_1_1.makeFlags ++ [ "DOPENSSL_TLS_SECURITY_LEVEL=2" ];
}))
)' \
 --command \
bash \
-c \
"
openssl version

timeout \
2 \
openssl s_client -connect oauth.hm.bb.com.br:443 -tls1_2
openssl version
"

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
    (redis.overrideAttrs(old: {
        makeFlags = old.makeFlags ++ ["USE_SYSTEMD=no"];
      }
    )
  )
)'
```

export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
develop \
--impure \
--expr \
'(with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
with legacyPackages.${builtins.currentSystem}; 
(openssl_1_1.overrideAttrs (oldAttrs: rec {
  src = fetchurl {
    url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
    sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
  };
  CC = (oldAttrs.stdenv.cc.overrideAttrs (old: {
          CC = ((old.CC or "") + "-DOPENSSL_TLS_SECURITY_LEVEL=2");
        })); 
  stdenv = oldAttrs.overrideCC oldAttrs.stdenv CC; 
}))
)'




export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
develop \
--impure \
--expr \
'(with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
with legacyPackages.${builtins.currentSystem}; 
(openssl_1_1.overrideAttrs (oldAttrs: rec {
  src = fetchurl {
    url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
    sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
  };
  NIX_CFLAGS_COMPILE = [ (oldAttrs.NIX_CFLAGS_COMPILE or "") ] ++ [ "-g2"];
}))
)' \
--command \
bash \
-c \
"
openssl version

timeout \
2 \
openssl s_client -connect oauth.hm.bb.com.br:443

openssl version
"


From: https://discourse.nixos.org/t/how-to-recompile-a-package-with-flags/3603/7


export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'(with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
with legacyPackages.${builtins.currentSystem}; 
(openssl_1_1.overrideAttrs (oldAttrs: rec {
  src = fetchurl {
    url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
    sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
  };
  configureFlags = (oldAttrs.configureFlags or "") ++ [ "-no-asm" ]; 
}))
)'


export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'(with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
with legacyPackages.${builtins.currentSystem}; 
(openssl_1_1.overrideAttrs (oldAttrs: rec {
  src = fetchurl {
    url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
    sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
  };
  configureFlags = (oldAttrs.configureFlags or "") ++ [ "-smtp_tls_security_level=may" ]; 
}))
)'


openssl version -f | tr ' ' '\n' | sort


./config.status --config


NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
  with legacyPackages.${builtins.currentSystem}; 
  (openssl_1_1.overrideAttrs (oldAttrs: rec {
    src = fetchurl {
      url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
      sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
    };
    configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
  }))
)' \
--command \
bash \
-c \
"
openssl version

timeout \
2 \
openssl \
s_client \
-CApath /etc/ssl/certs/ \
-connect oauth.hm.bb.com.br:443 \
-brief

openssl version
"


NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
  with legacyPackages.${builtins.currentSystem}; 
  (openssl_1_1.overrideAttrs (oldAttrs: rec {
    src = fetchurl {
      url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
      sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
    };
    configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
  }))
)' \
--command \
bash \
-c \
"
(openssl version -f | grep -q -e '-DOPENSSL_TLS_SECURITY_LEVEL=2') || echo 'Not found flag -DOPENSSL_TLS_SECURITY_LEVEL=2'
openssl version -f | sed 's/ / \\ \n/g' | sed -e 1d | (sed -u 1q; sort)
"




openssl version -f
openssl version -a
openssl version -d
nm -C $(erw openssl) | grep TLS
objdump $(erw openssl) -x  | grep TLS


https://superuser.com/a/929567


nix show-derivation nixpkgs#openssl  | jq ".[].outputs.out.path"

https://earthly.dev/blog/make-flags/

https://crypto.stackexchange.com/questions/84271/why-openssh-prefers-ecdsa-nistp256-keys-over-384-and-521-and-those-over-ed255


nix \
build \
--impure \
--expr \
'(
with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}.pkgsStatic;
(podman.override { postFixup = ""; })
)'



NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
(podman.overrideAttrs (oldAttrs: {
  preFixup = "";
}))
)'

NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}.pkgsStatic; 
(catatonit.overrideAttrs (oldAttrs: {
  nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ patchelf ];
}))
)'


nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (pkgsStatic.python3Minimal.override 
    { 
      reproducibleBuild = true; 
    }
  )
)' \
--command \
bash \
-c \
'
file $(readlink -f $(which python3)) \
&& ldd $(readlink -f $(which python3)) \
&& sha256sum $(readlink -f $(which python3)) \
'



nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (
    glibcLocales.override {
      allLocales = true;
    }
  )
)'


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (
    glibcLocales.override {
      locales = [ "pt_BR.UTF-8/UTF-8" ];
    }
  )
)'
```



```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (
    glibcLocales.overrideAttrs (oldAttrs: {
        locales = [ "pt_BR.UTF-8/UTF-8" ];
      }
    )
  )
)'
```

```bash
# nix flake metadata github:NixOS/nixpkgs/release-22.05 --json
command -v jq >/dev/null || nix profile install github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#jq \
&& nix \
show-derivation \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (
    glibcLocales.overrideAttrs (oldAttrs: {
        locales = [ "pt_BR.UTF-8/UTF-8" ];
      }
    )
  )
)' | jq -r '.[].env.preConfigure'
```




```bash
# nix flake metadata github:NixOS/nixpkgs/release-22.05 --json
command -v jq >/dev/null || nix profile install github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#jq \
&& nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs";
  with legacyPackages.${builtins.currentSystem};
  (
    glibcLocales.override {
        allLocales = false;
        locales = [ "pt_BR.UTF-8/UTF-8" ];
      }
  )
)'
```
Refs.:
- https://github.com/NixOS/nixpkgs/pull/176253#issuecomment-1152892550



```bash
sha256sum $(readlink result)/lib/locale/locale-archive
```


https://github.com/NixOS/nixpkgs/blob/nixos-22.05/pkgs/development/libraries/glibc/locales.nix#L69

```bash
# nix flake metadata github:NixOS/nixpkgs/release-22.05 --json
command -v jq >/dev/null || nix profile install github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#jq \
&& nix \
show-derivation \
nixpkgs#pkgsCross.aarch64-multiplatform.pkgsStatic.hello | jq '.[].env'
```


```bash
nix \
show-derivation \
github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#gtk3 | jq -r '.[].env.postFixup'
```


```bash
command -v jq >/dev/null || nix profile install github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#jq \
&& nix \
show-derivation \
'github:NixOS/nix?tag=2.10.2&rev=e79b38ef59ebb6d3e8115f28961d3fad925e5ca6#nix' \
| jq -r '.[].env.preConfigure'
```

```bash
command -v jq >/dev/null || nix profile install github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a#jq \
&& nix \       
show-derivation \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem}; 
  (pkgsStatic.python3Minimal.override 
    { 
      reproducibleBuild = true; 
    }
  )
)' | jq -r '.[].env.preConfigure'
```


###

https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/tools/networking/pacparser/default.nix#L12-L18

https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/os-specific/linux/nvidia-x11/settings.nix#L54-L67

https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/os-specific/bsd/netbsd/default.nix#L213-L225

