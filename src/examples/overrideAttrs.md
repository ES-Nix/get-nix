

https://www.youtube.com/watch?v=6VepnulTfu8

> I'm not convinced getting rid of `NIX_CFLAGS_COMPILE` is a good idea. 
> `NIX_CFLAGS_COMPILE` is consistent and reliable, unlike figuring out the magic 
> incantation (often silently ignored) to tell the build system to pass a flag to the C compiler.
https://github.com/NixOS/nixpkgs/issues/79303#issuecomment-720647170


### hello

```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs";
  with legacyPackages.${builtins.currentSystem};
    (hello.overrideAttrs
      (oldAttrs: {
          preFixup = (oldAttrs.preFixup or "") + "set -x";
        }
      )
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
    (binutils-unwrapped.overrideAttrs (old: {
        name = "binutils-2.37";
        src = pkgs.fetchurl {
          url = "https://ftp.gnu.org/gnu/binutils/binutils-2.37.tar.xz";
          sha256 = "sha256-gg2XJPAgo+acszeJOgtjwtsWHa3LDgb8Edwp6x6Eoyw=";
        };
        patches = [];
      });
    )
)'
ls -al result/bin
```
Refs.:
- https://nixos.wiki/wiki/C




```bash
rm -fv result \
&& nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs";
  with legacyPackages.${builtins.currentSystem};
    (hello.overrideAttrs
      (oldAttrs: {
          preBuild = (oldAttrs.preBuild or "") + "export ABC_ENVIRONMENT_VARIABLE=xptozyx";
          preFixup = (oldAttrs.preFixup or "") + "echo xzafssdfg; env";
        }
      )
    )
)' \
&& nix log $(readlink -f result) | grep '^ABC_ENVIRONMENT_VARIABLE=xptozyx'
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs";
  with legacyPackages.${builtins.currentSystem};
    (hello.overrideAttrs
      (oldAttrs: {
          oldAttrs.buildInputs or []) ++ [ makeWrapper ];
          postInstallPhase = (oldAttrs.postInstallPhase or "") + "wrapProgram $out/bin/hello --prefix LD_LIBRARY_PATH : ${pkgs.stdenv.cc.cc.lib}/lib";
        }
      )
    )
)'
```


### openssl

```bash
nix run nixpkgs#gcr
```


- https://www.openssl.org/docs/man1.1.1/man3/SSL_CTX_set_security_level.html
- https://github.com/openssl/openssl/blob/a6843e6ae8ae0551aae8555783f06dab7951f112/INSTALL.md#no-asm
- https://wiki.openssl.org/index.php/Compilation_and_Installation#Modifying_Build_Settings
- https://stackoverflow.com/a/7831995
- https://stackoverflow.com/questions/56141096/how-to-override-a-parameter-in-an-openssl-configuration-file-using-the-cli
- https://askubuntu.com/questions/1233186/ubuntu-20-04-how-to-set-lower-ssl-security-level
- https://stackoverflow.com/a/64200184
- https://discourse.nixos.org/t/how-to-recompile-a-package-with-flags/3603/7

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

```bash
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
```



openssl version -f
openssl version -a
openssl version -d
nm -C $(erw openssl) | grep TLS
objdump $(erw openssl) -x  | grep TLS

https://stackoverflow.com/questions/26411955/openssl-how-to-find-the-config-options-that-openssl-was-compiled-with
https://superuser.com/a/929567
https://github.com/openssl/openssl/issues/11456#issuecomment-607682072
https://unix.stackexchange.com/a/134942
https://stackoverflow.com/a/189524


```bash
nix show-derivation nixpkgs#openssl  | jq ".[].outputs.out.path"
```

https://earthly.dev/blog/make-flags/

https://crypto.stackexchange.com/questions/84271/why-openssh-prefers-ecdsa-nistp256-keys-over-384-and-521-and-those-over-ed255


```bash
nix eval --raw nixpkgs#python3.postFixup
```

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
    (
      python3.overrideAttrs (oldAttrs: {
        postFixup = "";
      }
    )
  )
)
'
```


### podman

Broken:
```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65"; 
  with legacyPackages.${builtins.currentSystem}.pkgsStatic;
    (
      podman.override {
        postFixup = "";
      }
    )
  )
'
```

```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
    (
      podman.overrideAttrs (oldAttrs: {
        postFixup = "";
      }
    )
  )
)
'
```

```bash
ldd $(readlink -f result/bin/podman) | rg systemd
nix-store --query --graph --include-outputs $(readlink -f result/bin/python) | dot -Tps > graph.ps
okular graph.ps
```

```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
    (
      podman-unwrapped.overrideAttrs (oldAttrs: {
        postFixup = "";
      }
    )
  )
)
'
```


```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
    (
      podman-unwrapped.overrideAttrs (oldAttrs: {
        postFixup = "";
      }
    )
  ).override { systemd = null; }
)
'
```


```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
    (
      pkgsStatic.podman-unwrapped.overrideAttrs (oldAttrs: {
        postFixup = "";
      }
    )
  ).override { systemd = null; }
)
'
```
Refs.:
- https://discourse.nixos.org/t/combining-override-and-overrideattrs/10089/2


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "nixpkgs";
  with legacyPackages.${builtins.currentSystem};
    (
      podman-unwrapped.override
        {
          systemd = null;
          lvm2 = null;
          libapparmor = null;
          libselinux = null;
          btrfs-progs = null;
        }
    ).overrideAttrs (oldAttrs:
        {
          postFixup = "";
        }
      )
  )
'
```


```bash
NIXPKGS_ALLOW_BROKEN=1 \
&& nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/e66821278399ba9565178ce3b525e72275fe004e";
  with legacyPackages.${builtins.currentSystem}; 
    (
      pkgsStatic.catatonit.overrideAttrs (oldAttrs: {
        noAuditTmpdir = true;
      }
    )
  )
)'
```

```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix why-depends --impure --derivation nixpkgs#pkgsStatic.podman nixpkgs#systemd | cat
```

TODO: it seems to be possible to compile statically 
- https://github.com/containers/podman/issues/14454#issuecomment-1148561820, this one has a Dockerfile that compiles podman statically
- https://github.com/containers/podman/blob/main/Makefile#L107
- https://github.com/cri-o/cri-o/blob/e80d9c9197059f24f97bf33c18533ce07f257420/Makefile#L175-L181

```bash
export NIXPKGS_ALLOW_BROKEN=1 \
&& nix why-depends --impure --derivation nixpkgs#pkgsStatic.procps nixpkgs#systemd
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.python3Minimal.override
    {
      reproducibleBuild = true;
    }
  )
)'
# The file from coreutils must report that it is an statically linked binary
file $(readlink -f $(which result/bin/python)) | grep -q -F "statically linked" || exit 32

! ldd $(readlink -f $(which result/bin/python)) 2> /dev/null
export EXPECTED_SHA256=f1c5d1e728b61731e1a305070444be95818b5a778682def8424a6ae9a5a37c0d
export EXPECTED_SHA512=eeee2852bf6510e187a1cf228d58977f826e00235528b1abef8069cd3eaa07d7e81f2debf016d8c3580d6f0aa874255c2bed2e3c29dc4e6aa4d80b02010a4c99
echo $EXPECTED_SHA256'  '$(readlink -f $(which result/bin/python)) | sha256sum -c --strict 1> /dev/null
echo $EXPECTED_SHA512'  '$(readlink -f $(which result/bin/python)) | sha512sum -c --strict 1> /dev/null
```



```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65"; 
  with legacyPackages.${builtins.currentSystem};
  (pkgsCross.s390x.pkgsStatic.python3Minimal.override
    {
      reproducibleBuild = true;
    }
  )
)'

# The file from coreutils must report that it is an statically linked binary
file $(readlink -f $(which result/bin/python)) | grep -q -F "statically linked" || exit 32

! ldd $(readlink -f $(which result/bin/python)) 2> /dev/null
export EXPECTED_SHA256=c0e857711c91e5dccbced4645e45d637e98bedae113d749d90909abd080081d3
export EXPECTED_SHA512=d310f94d20ece6d993f5887f2d632ce64c1497441d597e76714e32f8078897855009869546428baa8f89f189e6aa7ef0bfa3c9ad3f3a8c3744c6c5b5281a170d
echo $EXPECTED_SHA256'  '$(readlink -f $(which result/bin/python)) | sha256sum -c --strict 1> /dev/null
echo $EXPECTED_SHA512'  '$(readlink -f $(which result/bin/python)) | sha512sum -c --strict 1> /dev/null
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
    glibcLocales.override {
      allLocales = true;
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



```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.${builtins.currentSystem}; 
    (
      hello.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") 
                       + "\n" 
                       + "wrapProgram $out/bin/hello --prefix LD_LIBRARY_PATH : ${stdenv.cc.cc.lib}/lib";
      }
    )
  )
)
'
```


```bash
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.${builtins.currentSystem}; 
    (
      python3.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") 
                       + "\n" 
                       + "wrapProgram $out/bin/python3 --prefix ABC : xyz-value";
      }
    )
  )
)
' \
-- \
-c \
'import os; assert os.environ.get("ABC") == "xyz-value", "The environment variable ABC was not equal to xyz-value"'
```


```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.${builtins.currentSystem}; 
    (
      python3Minimal.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
        postInstall = (oldAttrs.postInstall or "") 
                       + "\n" 
                       + "wrapProgram $out/bin/python3 --prefix ABC : xyz-value";
      }
    )
  )
)
' \
--command \
python \
-c \
'import os; assert os.environ.get("ABC") == "xyz-value", "The environment variable ABC was not equal to xyz-value"'
```


### awscli

TODO: document it better
```bash
nix \
develop \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
  (awscli.override 
    { 
      python3 = python38; 
    }
  )
)' \
--command \
python --version
```

```bash
nix \
develop \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
  (awscli.override 
    { 
      python3 = python39; 
    }
  )
)' \
--command \
python --version
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/d1ca40ea766da1b639937084d18d3e54e4e5da1b/pkgs/tools/admin/awscli/default.nix#L52-L63



```bash
overrideAttrs (attrs: {
      buildInputs = (attrs.buildInputs or []) ++ [ makeWrapper ];
      postInstall = (attrs.postFixup or "") + lib.optionalString stdenv.isLinux ''
        chmod +x $out/bin/pycharm-community
        wrapProgram "$out/bin/pycharm-community --set FOO_BAR "XPTO"
        wrapProgram "$out/bin/pycharm-community --set LOCALE_ARCHIVE "${glibcLocales}/lib/locale/locale-archive"
      '';
    })
```


###

TODO: document it
https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/tools/networking/pacparser/default.nix#L12-L18

https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/os-specific/linux/nvidia-x11/settings.nix#L54-L67

https://github.com/NixOS/nixpkgs/blob/634141959076a8ab69ca2cca0f266852256d79ee/pkgs/os-specific/bsd/netbsd/default.nix#L213-L225




#### redis

```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs";
  with legacyPackages.${builtins.currentSystem};
    (redis.overrideAttrs(old: {
        makeFlags = (old.makeFlags or []) ++ ["USE_SYSTEMD=no"];
      }
    )
  )
)'
```
Refs.:
- http://lethalman.blogspot.com/2016/04/cheap-docker-images-with-nix_15.html (the first one to do this?)
- https://unix.stackexchange.com/questions/543325/nix-error-undefined-variable-gopackages
- https://discourse.nixos.org/t/nix-docker-buildlayeredimage-musl-static-build-issue/15153/6
- https://mudrii.medium.com/fixing-dockerfile-image-build-consistency-5bc6d5128aac
- https://javamana.com/2021/11/20211102055652111y.html
- https://gist.github.com/573/6692d06a14f8844abbe40935d8eb8146

The easy way:
```bash
# If this is broken in the future, test the fixed commit sha256 version
nix shell nixpkgs#pkgsStatic.redis --command redis-cli --version

# Got the 2f0c3be57c348f4cfd8820f2d189e29a685d9c41 from:
# nix flake metadata nixpkgs
# nix shell 'github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65#pkgsStatic.redis' --command redis-cli --version


nix \
shell \
'github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65#pkgsStatic.redis' \
--command \
sh \
-c \
'
redis-cli --version

ldd "$(which redis-server)" 1> /dev/null 2> /dev/null 
EXITCODE=$?
test $EXITCODE -eq 1 && echo "Looks like it worked!" || echo "Something bad happened!";
exit $EXITCODE
'
```
Refs.:
- https://stackoverflow.com/a/55940715


### C++, boost, poco, Clang 7, overrideCC stdenv



https://blog.galowicz.de/2019/04/17/tutorial_nix_cpp_setup/


#### opencv


```bash
nix why-depends --all nixpkgs#pkgsStatic.opencv nixpkgs#systemd
```


https://stackoverflow.com/questions/65436307/ldd-exited-with-unknown-exit-code-when-use-qemu-in-docker

#### overlays


TODO: https://www.fbrs.io/nix-overlays/
https://discourse.nixos.org/t/how-to-get-cuda-working-in-blender/5918/5

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
  let
    pkgs = (import <nixpkgs> { overlays = [(self: super: { hello = self.neofetch; })]; });
  in
    with pkgs;[
      hello
    ]
)' \
--command \
neofetch
```

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
  let
    pkgs = (import <nixpkgs> { overlays = [(self: super: { coreutils = self.uutils-coreutils; })]; });
  in
    with pkgs;[
      hello
    ]
)' \
--command \
hello
```


```bash
nix build --impure --expr \
'(import <nixpkgs> { overlays = [(final: prev: { bash = final.busybox; })]; }).gcc'
```


```bash
nix build --impure --expr '(import <nixpkgs> { overlays = [(final: prev: { static = true; })]; }).openssl'
```


```bash
nix run --impure --expr '(import <nixpkgs> { overlays = [(final: prev: { aclSupport = false; })]; }).coreutils'
```


```bash
nix run --impure --expr '(import <nixpkgs> { overlays = [(final: prev: { aclSupport = false; })]; }).pkgsStatic.coreutils'
```


```bash
nix \
run \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992")
  { overlays = [(final: prev: { postFixup = (final.postFixup or "") + ""; })]; }
).hello
'
```



```bash
nix \
run \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992")
  { overlays = [(final: prev: { 
                  python3 = prev.python3.override {
                    packageOverrides = final: prev: {
                      flask = prev.flask.overrideAttrs (oldAttrs: {
                          postFixup = (final.postFixup or "asdff") + "";
                        });
                      };
                    };
                  })
               ]; 
  }
).python3Packages.flask
'
```



```bash
nix \
run \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992")
  { overlays = [(final: prev: { aclSupport = false; })]; }
).pkgsStatic.coreutils
'
```




### Force rebuilding pkgsStatic.podman-unwrapped with postFixup = "";


```bash
export NIXPKGS_ALLOW_BROKEN=1

nix \
run \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65")
  { overlays = [(final: prev: { postFixup = ""; })]; }
).pkgsStatic.podman-unwrapped
'
```

> Why `systemd = null;` breaks?





```bash
export NIXPKGS_ALLOW_BROKEN=1;
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  import (builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65")
  { overlays = [(final: prev: { buildInputs = [ libseccomp libselinux lvm2 ]; postFixup = ""; })]; }
).pkgsStatic.podman-unwrapped
'
```


```bash
nix build nixpkgs#pkgsStatic.btrfs-progs 2> /dev/null || echo 'Erro in: 'btrfs-progs
nix build nixpkgs#pkgsStatic.gpgme 2> /dev/null || echo 'Erro in: 'gpgme
nix build nixpkgs#pkgsStatic.libapparmor 2> /dev/null || echo 'Erro in: 'libapparmor
nix build nixpkgs#pkgsStatic.libseccomp 2> /dev/null || echo 'Erro in: 'libseccomp
nix build nixpkgs#pkgsStatic.libselinux 2> /dev/null || echo 'Erro in: 'libselinux
nix build nixpkgs#pkgsStatic.lvm2 2> /dev/null || echo 'Erro in: 'lvm2
nix build nixpkgs#pkgsStatic.systemd 2> /dev/null || echo 'Erro in: 'systemd
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/13cbe534ebe63a0bc2619c57661a2150569d0443/pkgs/applications/virtualization/podman/default.nix#L37-L45


```bash
nix build nixpkgs#pkgsStatic.acl 2> /dev/null || echo 'Erro in: 'acl
nix build nixpkgs#pkgsStatic.attr 2> /dev/null || echo 'Erro in: 'attr
nix build nixpkgs#pkgsStatic.e2fsprogs 2> /dev/null || echo 'Erro in: 'e2fsprogs
nix build nixpkgs#pkgsStatic.libuuid 2> /dev/null || echo 'Erro in: 'libuuid
nix build nixpkgs#pkgsStatic.lzo 2> /dev/null || echo 'Erro in: 'lzo
nix build nixpkgs#pkgsStatic.python3 2> /dev/null || echo 'Erro in: 'python3
nix build nixpkgs#pkgsStatic.zlib 2> /dev/null || echo 'Erro in: 'zlib
nix build nixpkgs#pkgsStatic.zstd 2> /dev/null || echo 'Erro in: 'zstd
nix build nixpkgs#pkgsStatic.udev 2> /dev/null || echo 'Erro in: 'udev
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/13cbe534ebe63a0bc2619c57661a2150569d0443/pkgs/tools/filesystems/btrfs-progs/default.nix#L24


```bash
# export NIXPKGS_ALLOW_BROKEN=1

nix \
run \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65")
  { overlays = [(final: prev: { systemd = null; })]; }
).pkgsStatic.podman-unwrapped
'
```


WARNING: it works but it must not! Read the link.
```bash
nix \
build \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992")
  {
    overlays = [ (final: prev: { nginxStable = null; }) ];
  }
).nixosTests.nginx
'
```
https://github.com/NixOS/nixpkgs/issues/62116#issuecomment-1225180043



```bash
nix \
build \
--impure \
--expr \
'
(import <nixpkgs> {                                                                      
  overlays = [
    (self: super: {
      firefox-unwrapped = super.firefox-unwrapped.overrideAttrs (oldAttrs: {
        makeFlags = oldAttrs.makeFlags ++ [ "BUILD_OFFICIAL=1" ];
      });
    })
  ];
  }
).firefox-unwrapped'
```

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (import <nixpkgs> { overlays = [(self: super: { gcc = self.gcc10; })]; }).stdenv.cc
)' \
--command \
gcc --version
```
Refs.:
- https://stackoverflow.com/a/62224124


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (import <nixpkgs> { overlays = [(self: super: { hello = self.python3; })]; }).hello
)' \
--command \
python --version
```


https://stackoverflow.com/a/56706514


```bash
nix \
build \
--impure \
--expr \
'(import <nixpkgs> { overlays = [ (self: super: { nginxStable = null; }) ]; }).nixosTests.nginx'
```
Refs.:
- https://github.com/NixOS/nixpkgs/issues/50301



### Old gcc version


https://discourse.nixos.org/t/compiling-with-old-glibc/12054/4


### glibc.overrideAttrs


```bash
nix \
build \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "2.26";
      });
    })
  ];
  }
).glibc
'
```
Refs.:
- https://gurkan.in/wiki/nix.html#override-example-optional-args

```bash
nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "3.4.21";
      });
    })
  ];
  }
).stdenv.cc.cc.lib
'
```

```bash
readelf -sV \
$(nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "3.4.21";
      });
    })
  ];
  }
).stdenv.cc.cc.lib
')/lib/libstdc++.so.6.0.28 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
```
Refs.:
- https://stackoverflow.com/a/10356740


```bash
patchelf \
--print-rpath \
$(nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "3.4.21";
      });
    })
  ];
  }
).hello
')/bin/hello | grep 'glibc-3.4.21/lib'
```


```bash
patchelf \
--print-rpath \
$(nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "2.15";
      });
    })
  ];
  }
).hello
')/bin/hello | grep 'glibc-2.15/lib'
```


```bash
patchelf \
--print-rpath \
$(nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "2.15";
      });
    })
  ];
  }
).python3
')/bin/python3 | grep 'glibc-2.15/lib'
```

```bash
nix profile install nixpkgs#patchelf
```


```bash
# nix-shell -p hello --command 'patchelf --print-rpath $(which hello)'

nix \
shell \
-i \
nixpkgs#hello \
nixpkgs#patchelf \
nixpkgs#which \
nixpkgs#bash \
--command \
sh \
-c \
'patchelf --print-rpath $(which hello)'
```



```bash
echo \
| $(
nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "3.4.21";
      });
    })
  ];
  }
).gcc
' | tail -n1
)/bin/gcc -E -Wp,-v - \
| grep 3.4.21
```

3.4.2
3.4.21

```bash
nix \                                                                                                                                            
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> {
  overlays = [
    (self: super: {
      glibc = super.glibc.overrideAttrs (oldAttrs: {
        version = "3.4.28";
      });
    })
  ];
  }
).gcc
'
```
Refs.:
- https://stackoverflow.com/a/10356740


```bash
nix \
build \
--print-out-paths \
--impure \
--expr \
'
(import <nixpkgs> { overlays = [ (self: super: { stdenv = super.stdenv // { overrides = self2: super2: super.stdenv.overrides self2 super2 // { coreutils = uutils-coreutils; }; }; }) ]; }).coreutils
'
```
Refs.:
- https://stackoverflow.com/a/58765599


### stdenv.cc.cc.lib


Note: this does not need to build locally the derivation.
So, it is fast!
```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
--recursive \
"$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)"/lib
```

Not so good if what you need is just `nix build --print-out-paths`:
```bash
nix build nixpkgs#stdenv.cc.cc.lib \
&& ls -al "$(nix eval --raw nixpkgs#stdenv.cc.cc.lib)/lib"
```


```bash
ls -al $(nix build --print-out-paths nixpkgs#stdenv.cc.cc.lib)/lib
```



### Trick to troubleshooting


```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (hello.overrideAttrs (old: { buildInputs = (old.buildInputs or []) ++ [bash strace less ltrace vim cowsay]; }))
)
'
```

```bash
rm -fr build-dir

mkdir build-dir \
&& cd build-dir/ \
&& unpackPhase \
&& cd hello-2.12.1 \
&& ./configure \
&& make \
&& ./hello | cowsay
```

TODO: it is big, cat $stdenv/setup | wc -l
```bash
source $stdenv/setup \
&& phases="buildPhase" genericBuild
```


```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (hello.overrideAttrs (old: { buildInputs = (old.buildInputs or []) ++ [bash strace less ltrace vim cowsay]; }))
)
' \
--command \
bash \
-c \
'cat $stdenv/setup | wc -l | grep -q 1428'
```

```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (hello.overrideAttrs (old: { buildInputs = (old.buildInputs or []) ++ [bash strace less ltrace vim cowsay]; }))
)
' \
--command \
bash \
-c \
'
rm -fr build-dir

source $stdenv/setup
mkdir build-dir \
&& cd build-dir/ \
&& unpackPhase \
&& cd hello-2.12.1 \
&& ./configure \
&& make \
&& ./hello | cowsay
'
```

```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (hello.overrideAttrs (old: { 
                                nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ breakpointHook ]; 
                                buildInputs = (old.buildInputs or []) ++ [bashInteractive coreutils strace less ltrace vim hello];
                              }
                        )
  )
)
' \
--command \
bash \
-c \
'
rm -fr build-dir

source $stdenv/setup
mkdir build-dir \
&& cd build-dir/ \
&& unpackPhase \
&& cd */ \
&& pwd \
&& ls -al \
&& ./configure \
&& phases="buildPhase" genericBuild \
&& exec bash
'
```

```bash
nix \
develop \
--impure \
--ignore-environment \
nixpkgs#hello \
--command \
bash \
-c \
'
source $stdenv/setup

cd "$(mktemp -d)" \
&& unpackPhase \
&& cd */ \
&& pwd \
&& phases="configurePhase buildPhase" genericBuild \
&& ./hello
'
```
Refs.:
- https://unix.stackexchange.com/a/673488


Other way:
```bash
nix \
develop \
--impure \
--ignore-environment \
nixpkgs#hello \
--command \
bash \
-c \
'
source $stdenv/setup # loads the environment variable (`PATH`...) of the derivation to ensure we are not using the system variables
cd "$(mktemp -d)" # Important to avoid errors during unpack phase
export out="$(pwd)/"tmp/out
set +e # To ensure the shell does not quit on errors/Ctrl+C ($stdenv/setup runs `set -e`)
set -x # Optional, if you want to display all commands that are run
genericBuild
./hello
'
```


```bash
nix \
develop \
--impure \
--ignore-environment \
github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f#pkgsStatic.hello \
--command \
bash \
-c \
'
source $stdenv/setup # loads the environment variable (`PATH`...) of the derivation to ensure we are not using the system variables
cd "$(mktemp -d)" # Important to avoid errors during unpack phase
pwd
mkdir -pv "$(pwd)/"tmp/out
export out="$(pwd)/"tmp/out
set +e # To ensure the shell does not quit on errors/Ctrl+C ($stdenv/setup runs `set -e`)
set -x # Optional, if you want to display all commands that are run
genericBuild
./hello
# echo d270c41c27556b41150c9a3af47fe8c1a9a1e8c3ed4838b7e0c5d5e312260827  hello | sha256sum -c
'
```
TODO: why it is not deterministic, has the same sha256sum?


```bash
nix \
develop \
--impure \
--ignore-environment \
github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f#ffmpeg \
--command \
bash \
-c \
'
source $stdenv/setup # loads the environment variable (`PATH`...) of the derivation to ensure we are not using the system variables
cd "$(mktemp -d)" # Important to avoid errors during unpack phase
#pwd
#mkdir -pv "$(pwd)/"tmp/out
#export out="$(pwd)/"tmp/out
set +e # To ensure the shell does not quit on errors/Ctrl+C ($stdenv/setup runs `set -e`)
set -x # Optional, if you want to display all commands that are run
genericBuild
./ffmpeg
'
```


```bash
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f";
  with legacyPackages.${builtins.currentSystem};
  (ffmpeg.overrideAttrs (old: { 
                                nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ ];
                              }
                        )
  )
)
'
```

```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (ffmpeg.overrideAttrs (old: {
                                nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ SDL2 ];
                                buildInputs = (old.buildInputs or []) ++ [bashInteractive coreutils strace less ltrace vim hello];
                              }
                        )
  )
)
' \
--command \
bash \
-c \
'
source $stdenv/setup

cd "$(mktemp -d)" \
&& unpackPhase \
&& cd */ \
&& pwd \
&& phases="configurePhase buildPhase" genericBuild \
&& ./ffmpeg
'
```
Refs.:
- https://unix.stackexchange.com/a/673488



```bash
nix \
develop \
--impure \
--ignore-environment \
nixpkgs#ffmpeg \
--command \
bash \
-c \
'
source $stdenv/setup

cd "$(mktemp -d)" \
&& unpackPhase \
&& cd */ \
&& pwd \
&& phases="configurePhase buildPhase" genericBuild \
&& ./ffmpeg
'
```
Refs.:
- https://unix.stackexchange.com/a/673488
- https://youtu.be/4yyLoLWq-Jw?t=634


```bash
nix \
develop \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-isort";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
              (python3.buildEnv.override
                {
                  extraLibs = with python3Packages; [ isort ];
                }
              )
          ];
        };
      };

      testScript = ''
        "machine.succeed(\"isort\")"
      '';
    })
)
' \
--command \
bash \
-c \
'
source $stdenv/setup # loads the environment variable (`PATH`...) of the derivation to ensure we are not using the system variables
cd "$(mktemp -d)" # Important to avoid errors during unpack phase
set +e # To ensure the shell does not quit on errors/Ctrl+C ($stdenv/setup runs `set -e`)
# set -x # Optional, if you want to display all commands that are run
genericBuild
'
```


```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (python3.overrideAttrs (old: { buildInputs = (old.buildInputs or []) ++ [bashInteractive coreutils strace less ltrace vim hello]; }))
)
' \
--command \
bash \
-c \
'
source $stdenv/setup

cd "$(mktemp -d)" \
&& unpackPhase \
&& cd */ \
&& pwd \
&& phases="configurePhase buildPhase" genericBuild \
&& exec bash
'
```

```bash
nix-shell -E 'with import <nixpkgs> {}; stdenv.mkDerivation { name = "arm-shell"; buildInputs = [git gnumake gcc gcc-arm-embedded dtc]; }'
```
https://nixos.wiki/wiki/NixOS_on_ARM#Building_U-Boot_from_your_NixOS_PC

```bash
nix \
develop \
--impure \
--ignore-environment \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (hello.overrideAttrs (old: { buildInputs = (old.buildInputs or []) ++ [bashInteractive coreutils strace less ltrace vim hello]; }))
)
' \
--command \
bash \
-c \
'
# exec bash
rm -fr build-dir

source $stdenv/setup
mkdir build-dir \
&& cd build-dir/ \
&& unpackPhase \
&& cd */ \
&& exec bash
'
```

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (stdenv.mkDerivation { name = "arm-shell"; buildInputs = [hello];})
)'
```

```bash
nix \
develop \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (stdenv.mkDerivation {
      name = "arm-shell"; 
      src = builtins.path { path = ./.; };
      buildInputs = [git gnumake gcc gcc-arm-embedded dtc hello];
      phases = [ "buildPhase" "installPhase" "fixupPhase" ];
      installPhase = "mkdir $out";
    })
)'
```
https://nixos.wiki/wiki/NixOS_on_ARM#Building_U-Boot_from_your_NixOS_PC

Broken:
```bash
git clone git://git.denx.de/u-boot.git \
&& cd u-boot \
&& git checkout v2017.03 \
&& make -j4 CROSS_COMPILE=arm-none-eabi- orangepi_pc_defconfig \
&& make -j4 CROSS_COMPILE=arm-none-eabi-
```



```bash
cat $(nix \
build \
--print-out-paths \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (stdenv.mkDerivation {
      name = "test-podman-sandbox"; 
      src = builtins.path { path = ./.; };
      buildInputs = [podman];
      phases = [ "buildPhase" "installPhase" "fixupPhase" ];
      installPhase = "mkdir $out; export HOME=$(mktemp -d); podman images &> $out/log.txt || true; exit 0";
    })
)'
)/log.txt
```


```bash
cat $(nix \
build \
--print-out-paths \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (stdenv.mkDerivation {
      name = "test-sandbox"; 
      src = builtins.path { path = ./.; };
      buildInputs = [docker];
      phases = [ "buildPhase" "installPhase" "fixupPhase" ];
      installPhase = "mkdir $out; export HOME=$(mktemp -d); docker info &> $out/log.txt || true; exit 0";
    })
)')/log.txt
```


```bash
nix \
develop \
-i \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (stdenv.mkDerivation {
      name = "test-podman-sandbox"; 
      src = builtins.path { path = ./.; };
      buildInputs = [podman];
      phases = [ "buildPhase" "installPhase" "fixupPhase" ];
      installPhase = "mkdir $out; export HOME=$(mktemp -d); podman info > $out/log.txt";
    })
)'
```



```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (import <nixpkgs> { overlays = [ (self: super: { stdenv = super.stdenv // { overrides = self2: super2: super.stdenv.overrides self2 super2 // { coreutils = uutils-coreutils; }; }; }) ]; }).coreutils
)' \
--command \
uutils-coreutils --help
```


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (import <nixpkgs> { overlays = [ (self: super: { stdenv = super.stdenv // { overrides = self2: super2: super.stdenv.overrides self2 super2 // { glibc = super2.glibc.overrideAttrs (oldAttrs: { version = "3.4.21"; }); }; }; }) ]; }).gcc
)' \
--command \
gcc --version
```





```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (import <nixpkgs> { overlays = [ (self: super: { stdenv = super.stdenv \
                                                     // { overrides = self2: super2: super.stdenv.overrides self2 super2 \
                                                     // { coreutils = uutils-coreutils; }; };
                                                   }
                                      )
                                    ]; 
                      }
    ).hello
)' \
--command \
hello
```