

[Overrides: In and Out (NixCon 2019)](https://www.youtube.com/watch?v=6VepnulTfu8)

> I'm not convinced getting rid of `NIX_CFLAGS_COMPILE` is a good idea. 
> `NIX_CFLAGS_COMPILE` is consistent and reliable, unlike figuring out the magic 
> incantation (often silently ignored) to tell the build system to pass a flag to the C compiler.
https://github.com/NixOS/nixpkgs/issues/79303#issuecomment-720647170


### hello


```bash
nix \
run \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.hello.overrideAttrs
    (oldAttrs: {
        patchPhase = (oldAttrs.patchPhase or "") + "sed -i \"s/Hello, world!/hello, Nix!/g\" src/hello.c";
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


```bash
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```


```bash
export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
--extra-experimental-features 'nix-command flakes' \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"; 
    with legacyPackages.${builtins.currentSystem};
      (openssl_1_1.overrideAttrs (oldAttrs: {
        src = fetchurl {
          url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1o.tar.gz;
          sha256 = "sha256-k4SisFcN2ANYhBRkZ3EV33he25QccSEfdQdtcv5rQ48=";
        };
        makeFlags = openssl_1_1.makeFlags ++ [ "DOPENSSL_TLS_SECURITY_LEVEL=2" ];
      })
    )
  )
' \
--command \
bash \
-c \
'
openssl version

timeout \
2 \
openssl s_client -connect oauth.hm.bb.com.br:443 -tls1_2
openssl version
'
```

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

```bash
export NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"; 
    with legacyPackages.${builtins.currentSystem};
    (openssl_1_1.overrideAttrs (oldAttrs: rec {
        src = fetchurl {
          url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
          sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
        };
        configureFlags = (oldAttrs.configureFlags or "") ++ [ "smtp_tls_security_level=may" ]; 
      })
    )
  )
' \
-c \
openssl version -f | tr ' ' '\n' | sort
```





```bash
NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"; 
    with legacyPackages.${builtins.currentSystem};
      (openssl_1_1.overrideAttrs (oldAttrs: rec {
          src = fetchurl {
            url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
            sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
          };
          configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
        })
      )
  )
' \
--command \
bash \
-c \
'
openssl version

timeout \
2 \
openssl \
s_client \
-CApath /etc/ssl/certs/ \
-connect oauth.hm.bb.com.br:443 \
-brief

openssl version
'
```

```bash
NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"; 
    with legacyPackages.${builtins.currentSystem};
    (openssl_1_1.overrideAttrs (oldAttrs: rec 
      {
        src = fetchurl {
          url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
          sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
        };
        configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
      })
    )
)
' \
--command \
bash \
-c \
"
  (openssl version -f | grep -q -e '-DOPENSSL_TLS_SECURITY_LEVEL=2') || echo 'Not found flag -DOPENSSL_TLS_SECURITY_LEVEL=2'
  openssl version -f | sed 's/ / \\ \n/g' | sed -e 1d | (sed -u 1q; sort)
"
```


```bash
openssl version -f
openssl version -a
openssl version -d
nm -C $(erw openssl) | grep TLS
objdump $(erw openssl) -x  | grep TLS
```
Refs.:
- https://stackoverflow.com/questions/26411955/openssl-how-to-find-the-config-options-that-openssl-was-compiled-with
- https://superuser.com/a/929567
- https://github.com/openssl/openssl/issues/11456#issuecomment-607682072
- https://unix.stackexchange.com/a/134942
- https://stackoverflow.com/a/189524


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

This is somewhere after podman version 4.3.1. Building podman from source:
```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  ( 
    with builtins.getFlake "github:NixOS/nixpkgs/ba6ba2b90096dc49f448aa4d4d783b5081b1cc87";
    with legacyPackages.${builtins.currentSystem};
      ( 
        podman-unwrapped.overrideAttrs (oldAttrs: {
            src = fetchFromGitHub {
              owner = "containers";
              repo = "podman"; 
              rev = "9fbf91801d4540d48f51b11fb3ca33182d2525e7"; 
              sha256 = "sha256-WX3/gKuHkZfotc/YtAXuCfLfkSh3HT8QmFqHrdMZNXI=";
            }; 
            patches = [];
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


TODO: review this
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


iana-etc

### awscli


> `nix-shell`/`nix develop` were originally designed for the specific use case of debugging 
> nixpkgs stdenv-based builds, which use bash.
Refs.:
- https://stackoverflow.com/a/71112117
- https://github.com/NixOS/nix/issues/2854#issuecomment-673923349

```bash
nix develop nixpkgs#pkgsStatic.hello -c "$SHELL" -c 'echo $mesonFlags'
```

TODO: document it better
```bash
nix \
develop \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};

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
nix \
build \
--impure \
--expr \
'
  (
      let
        nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
        pkgs = import nixpkgs { system = "x86_64-linux"; };

        imageEnv = pkgs.buildEnv {
          name = "python3-awscli-env";
          paths = with pkgs.pkgsStatic; [ 
            bashInteractive 
            coreutils 
            python3 
            (hiPrio awscli)
          ];
        };
        pauseImage = pkgs.dockerTools.buildImage {
          name = "python3-awscli";
          tag = "latest";
          copyToRoot = imageEnv;
          config.Entrypoint = [ "/bin/python3" ];
        };
      in
        pauseImage
  )
'

podman load < result

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/k3s-pause:latest
```



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

> O atributo/nome `overlay` (sem o s) foi deprecado.
> The attribute/name `overlay` (without the `s`) was deprecated.
Refs.:
- https://t.me/nixosbrasil/69554

- jonringer explains the `final`/`prev` thing: https://discourse.nixos.org/t/what-are-overlays/14680/2
- really cool example for python devs: https://discourse.nixos.org/t/what-are-overlays/14680/13


Every thing has a trade-off:
> [...] Removing the overlay fixed it! I don’t even remember why I put it there...
> https://discourse.nixos.org/t/nixos-flakes-rebuild-not-using-subsitution-despite-package-being-available-in-cache-nixos-org/23013/9


Old, not complete/fully copy and paste working, example:
```bash
let
  overlay = self: super: {
    hello = super.hello.overrideAttrs (old: {
      doCheck = false;
    });
  };

  pkgs = import <nixpkgs> { overlays = [ overlay ]; };

in
  pkgs.hello
```
Refs.:
- https://www.haskellforall.com/2022/01/nixpkgs-overlays-are-monoids.html


Bingo! These are the same? 
- `<nixpkgs>` 
- `(builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41")`
YES!


```bash
nix \
build \
--impure \
--expr \
'
  (
    let
      overlay = self: super: {
        hello = super.hello.overrideAttrs (old: {
          doCheck = false;
        });
      };
    
      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") { overlays = [ overlay ]; };
    
    in
      pkgs.hello
  )
'
```


```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  (
    let
      overlay = self: super: {
        hello = super.hello.overrideAttrs (oldAttrs: {
          postInstall = "${self.cowsay}/bin/cowsay Installation complete";
        });
      };
    
      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") { overlays = [ overlay ]; };
    
    in
      pkgs.hello
  )
'
```


Other format:
```bash
nix \
build \
--print-build-logs \
--expr \
'
  (
    let
      overlay = final: prev: {
        hello = prev.hello.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + "${final.cowsay}/bin/cowsay Installation complete";
        });
      };

      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in 
      pkgs.hello
  )
'
```


TODO: it is wrong I believe...
```bash
nix \
build \
--print-build-logs \
--expr \
'
  (
    let
      overlay = final: prev:  {
        python3 = prev.python3.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + "${final.cowsay}/bin/cowsay Installation complete";
        });
      };

      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in 
      pkgs.python3
  )
'
```

Why this does not work?
```bash
...
in {
  inherit overlay;
  defaultPackage.x86_64-linux = pkgs.hello;
}
```


```bash
nix \
build \
--print-build-logs \
--expr \
'
  (
    let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = python-self: python-super: {
            pottery = python-super.python3Packages.buildPythonPackage rec {
                        name = "pottery";
                        version = "3.0.0";
                        src = super.fetchFromGitHub {
                          owner = "brainix";
                          repo = "pottery";
                          rev = "c7be6f1f25c5404a460b676cc60d4e6a931f8ee7";
                          # sha256 = "${lib.fakeSha256}";
                          sha256 = "sha256-LP7SjQ4B9xckTKoTU0m1hZvFPvACk9wvCi54F/mp6XM=";
                        };
                        checkInputs = with python-self.python3Packages; [ pytest ];
                        doCheck = true;
                        buildInputs = with python-self.python3Packages; [ typing-extensions redis mmh3 uvloop ];
                      };
          };
        };

        # python3Packages = python3.pkgs;
        pythonPackages = self.python.pkgs;
      });

      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b") {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in 
      pkgs.python3
  )
'
```


The blender-bin flake.
> Note: use `nix registry list` to check if this flake still exist 
 
```bash
nix \
build \
--print-build-logs \
--expr \
'
  (
    let
      nix-warez-blender = (builtins.getFlake github:edolstra/nix-warez/8b3c350e1632571c549ff304c290ae124d328cb5?dir=blender);
      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") {
        system = "x86_64-linux";
        overlays = [ nix-warez-blender.overlays.default ];
      };
    in 
      pkgs.blender
  )
'
```
Refs.:
- https://discourse.nixos.org/t/how-to-get-cuda-working-in-blender/5918/5
- 


```bash
nix-store --query --graph --include-outputs $(
nix \
build \
--impure \
--print-out-paths \
--expr \
'
  (
    let
      nix-warez-blender = (builtins.getFlake github:edolstra/nix-warez/8b3c350e1632571c549ff304c290ae124d328cb5?dir=blender);
      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") {
        system = "x86_64-linux";
        overlays = [ nix-warez-blender.overlays.default ];
      };
    in 
      pkgs.blender
  )
'
) | dot -Tps > blender-cuda.ps
```




```bash
nix-store --query --graph --include-outputs $(                               
nix \
build \
--impure \
--print-out-paths \
nixpkgs#hello) | sed '1d; $d' | sort > g1.txt
```

```bash
nix-store --query --graph --include-outputs $(
nix \
build \
--impure \
--print-out-paths \
--expr \
'
  (
    let
      overlay = final: prev: {
        hello = prev.hello.overrideAttrs (oldAttrs: {
          postInstall = (oldAttrs.postInstall or "") + "cp ${final.cowsay}/bin/cowsay $out/bin";
        });
      };

      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in 
      pkgs.hello
  )
'
) | sed '1d; $d' | sort > g2.txt
```

https://youtu.be/YLLsY0tovr8?t=1540


##### More than one overlay


```bash
EXPR_NIX='
  (
    let
    
      overlay0 = self: super: {
        hello = super.hello.overrideAttrs (oldAttrs: {
          doCheck = false;
        });
      };

      overlay1 = self: super: {
        hello = super.hello.overrideAttrs (oldAttrs: {
          postInstall = "${self.cowsay}/bin/cowsay Installation complete";
        });
      };

      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c");
      pkgs = import nixpkgs { overlays = [ overlay0 overlay1 ]; };

    in
      pkgs.hello
  )
'

nix \
build \
--no-link \
--print-build-logs \
--impure \
--expr \
"$EXPR_NIX"

nix \
build \
--no-link \
--print-build-logs \
--rebuild \
--impure \
--expr \
"$EXPR_NIX"
```



TODO: what is the difference?
```bash
nix \                                                                                                                                   
shell \                                   
--impure \                                 
--expr \                                    
'                               
(                                    
  let
    overlay = (self: super: {
      hello = super.hello.overrideAttrs (old: {
        doCheck = false;
      });
    };);
                                                                                                
    # Let"s put together a package set to use later
    myPythonPackages = ps: with ps; [             
      pottery
      # and other modules you"d like to add
    ];      
  in      
     (import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41")
             { overlays = [ overlay ]; }
     ).python3.withPackages myPythonPackages
```


Broken:
```bash
nix \
shell \
--impure \
--expr \
'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = self: super: {
            pottery = self.callPackage rec {
              version = "3.0.0";
              doInstallCheck = false;
              src =  super.fetchPypi {
                pname = "pottery";
                inherit version;
                sha256 = "vT+k/i44Uz1TNuEnL8TnZcq7veFEMJzO6GdVCdXNewU=";
              };
            };
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Let"s put together a package set to use later
      myPythonPackages = ps: with ps; [
        pottery
        # and other modules you"d like to add
      ];    
      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") { overlays = [ overlay ]; };  
   in
     pkgs.python3.withPackages myPythonPackages
  )
' \
--command \
python3 \
-c \
'from pottery import ReleaseUnlockedLock'
```

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b";
  with legacyPackages.x86_64-linux;
  [
    (let
      name = "pottery";
      version = "3.0.0";
     in
      python3Packages.buildPythonPackage rec {
        inherit name version;
        src = fetchFromGitHub {
          owner = "brainix";
          repo = "pottery";
          rev = "c7be6f1f25c5404a460b676cc60d4e6a931f8ee7";
          # sha256 = "${lib.fakeSha256}";
          sha256 = "sha256-LP7SjQ4B9xckTKoTU0m1hZvFPvACk9wvCi54F/mp6XM=";
        };
        # checkPhase = "true";
        # pythonImportsCheck = with python3Packages; [ pytest ];
        checkInputs = with python3Packages; [ pytest ];
        doCheck = true;
        buildInputs = with python3Packages; [ typing-extensions redis mmh3 uvloop ];
      }
    )
  ]
)' \
--command \
python \
-c \
'from pottery import ReleaseUnlockedLock'
```

<h2 id="the-package-is-built-successfully-but-it-panics-about-not-finding-libstdcso6-when-being-imported">The package is built successfully, but it panics about not finding “libstdc++.so.6” when being imported?</h2>





TODO: kubernetes
https://gitter.im/NixOS/chat?at=5ee7ab2d7a7f8d2d633852ed

Recommended refs.:
- [Nixpkgs - Overlays](https://www.youtube.com/watch?v=dGAL3gMXvug)
- https://stackoverflow.com/a/52402289
- 
- examples: https://www.haskellforall.com/2022/01/nixpkgs-overlays-are-monoids.html
- [NixOS: The DOs and DON'Ts of nixpkgs overlays](https://flyingcircus.io/blog/nixos-the-dos-and-donts-of-nixpkgs-overlays/)
- [Nix overlays: the fixpoint and the (over)layer cake](https://blog.layus.be/posts/2020-06-12-nix-overlays.html)
- https://discourse.nixos.org/t/what-are-overlays/14680/13
- for python devs https://discourse.nixos.org/t/what-are-overlays/14680/13


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
    with pkgs; [
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


TODO:
```bash
nix \
run \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b")
  { overlays = [(final: prev: { 
                  python3 = prev.python3.override {
                    packageOverrides = final: prev: {
                      isort = prev.isort.overrideAttrs (oldAttrs: {
                          postFixup = "cp -v ${final.hello}/bin/hello $out/bin/";
                        });
                      };
                    };
                  })
               ];
    
  }
).python3Packages.isort
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
                          postFixup = "${final.cowsay}/bin/cowsay Installation complete";
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
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
    with legacyPackages.${builtins.currentSystem}; 

    (openssl_1_1.overrideAttrs 
      (oldAttrs: {
        src = fetchurl {
          url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1g.tar.gz;
          sha256 = "sha256-3bBHdPHjLwxJdR4htnIWrIeFLOsFa3UgmvJENABjbUY=";
        };
      })
    )
  )
' \
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
```

#### Overriding firefox version


```bash
nix \
build \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/345ff18c99af958afdbd57f077aae9af4000e864"; 
    with legacyPackages."x86_64-linux"; 
    
    (firefox-unwrapped.overrideAttrs 
      (oldAttrs: rec {
        pname = "firefox";
        ffversion = "82.0.3";
        src = fetchurl {
          url = "mirror://mozilla/firefox/releases/${ffversion}/source/firefox-${ffversion}.source.tar.xz";
          sha512 = "0j5s5fkph9bm87lv53d4xvfj02qjfqzj5graxcc8air49iqswfmqjdzghna6bj9m8fbn6f5klgm6jbrmavdsycbps0y88x23b6kab5i";
        };
        patches = [];
      })
    )
  )
'
```



```bash
nix \
build \
--impure \
--expr \
'
(
  import <nixpkgs> {
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
build \
--impure \
--expr \
'
(
  import <nixpkgs> {
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

TODO: how to remove <nixpkgs> and use some let ... in?
Test it: -isysroot nowhere to NIX_CFLAGS_COMPILE
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
sh \
-c \
'
gcc --version \
&& echo | gcc -E -Wp,-v -
'
```
Refs.:
- https://stackoverflow.com/a/62224124
- https://github.com/NixOS/nixpkgs/issues/129595#issuecomment-897979569

TODO: help this one https://discourse.nixos.org/t/how-to-override-current-gcc7-for-recompiling-gcc7-3/15958


```bash
# stdenvNoCC
nix \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
    with legacyPackages.${builtins.currentSystem};
      (stdenv.override 
        (
          { cc = null; hasCC = false; }
      
          // lib.optionalAttrs (stdenv.hostPlatform.isDarwin && (stdenv.hostPlatform != stdenv.buildPlatform)) {
            # TODO: This is a hack to use stdenvNoCC to produce a CF when cross
            # compiling. It is not very sound. The cross stdenv has:
            #   extraBuildInputs = [ targetPackages.darwin.apple_sdks.frameworks.CoreFoundation ]
            # and uses stdenvNoCC. In order to make this not infinitely recursive, we
            # need to exclude this extraBuildInput.
            extraBuildInputs = [];
          }
        )
      )
  )
' \
--command \
sh \
-c \
'
gcc --version \
&& echo | gcc -E -Wp,-v -
'
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/f91ee3065de91a3531329a674a45ddcb3467a650/pkgs/top-level/all-packages.nix#L34-L45


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/4aceab3cadf9fef6f70b9f6a9df964218650db0a"; 
  with legacyPackages.${builtins.currentSystem};
    (import <nixpkgs> { overlays = [(self: super: { hello = self.python3; })]; } ).hello
)' \
--command \
python --version
```

```bash
nix run --impure --expr \
'(let pkgs = import (builtins.getFlake "github:NixOS/nixpkgs") { system = "${builtins.currentSystem}"; overlays = [(self: super: { hello = self.python3; })]; }; in pkgs.hello)'
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
--no-link \
--print-build-logs \
--print-out-paths \
--expr \
'
  (
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
      pkgs = import nixpkgs { 
                              system = "x86_64-linux"; 
                              overlays = [
                                (self: super: {
                                  glibc = super.glibc.overrideAttrs (oldAttrs: {
                                    version = "2.26";
                                  });
                                })
                              ];  
                            };
    in
      pkgs.glibc
  )
'
```
Refs.:
- https://gurkan.in/wiki/nix.html#override-example-optional-args




```bash
nix \
build \
--no-link \
--print-out-paths \
--expr \
'
  (
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
      pkgs = import nixpkgs { 
                              system = "x86_64-linux"; 
                              overlays = [
                                (self: super: {
                                  glibc = super.glibc.overrideAttrs (oldAttrs: {
                                    version = "2.26";
                                  });
                                })
                              ];  
                            };
    in
      pkgs.hello
  )
'
```


```bash
nix \
build \
--no-link \
--print-out-paths \
--expr \
'
  (
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
      pkgs = import nixpkgs { 
                              system = "x86_64-linux"; 
                              overlays = [
                                (self: super: {
                                  glibc = super.glibc.overrideAttrs (oldAttrs: {
                                    version = "2.26";
                                  });
                                })
                              ];  
                            };
    in
      pkgs.python3Full
  )
'
```


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
EXPR=$(cat <<-'EOF'
(
let
   nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
   pkgs = import nixpkgs {};

  # Create a C program that prints Hello World
  glibcAndLibcVersion = pkgs.writeText "glibc-and-libc-version.c" ''
    #include <stdio.h>
    #include <features.h>
    #include <unistd.h>
    #ifdef __GLIBC__
    #include <gnu/libc-version.h>
    #endif

    int
    main(void)
    {
    #ifdef __GLIBC__
      printf("GNU libc compile-time version: %u.%u\n", __GLIBC__, __GLIBC_MINOR__);
      printf("GNU libc runtime version:      %s\n", gnu_get_libc_version());

      printf("%s %s\n", gnu_get_libc_version(), gnu_get_libc_release());
      printf("glibc v%i %i.%i\n", __GNU_LIBRARY__, __GLIBC__, __GLIBC_MINOR__);

      printf( "Testing on %ld.%ld \n", __GLIBC__, __GLIBC_MINOR__);

      // method 3, use confstr function
      char version[30] = {0};
      confstr(_CS_GNU_LIBC_VERSION, version, 30);
      puts(version);

      return 0;
    #else
      puts("Not the GNU C Library");
      return 1;
    #endif
    }
  '';

in
  pkgs.stdenv.mkDerivation {
        name = "glibc-and-libc-version";
        src = glibcAndLibcVersion;
        buildPhase = ''
          $CC ${glibcAndLibcVersion} -o glibc-and-libc-version
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp glibc-and-libc-version  $out/bin/glibc-and-libc-version
          runHook postInstall
        '';
        dontUnpack = true;
      }
)
EOF
)



nix \
build \
--no-link \
--print-build-logs \
--impure \
--expr \
"$EXPR"

nix \
run \
--impure \
--expr \
"$EXPR"

ldd $(
  nix \
  build \
  --no-link \
  --print-build-logs \
  --print-out-paths \
  --impure \
  --expr \
  "$EXPR"
)/bin/glibc-and-libc-version \
| sed -n 's/.*@GLIBC_2/2/p' \
| sort -u -V \
| tail -1
```
Refs.:
- https://dev.to/0xbf/how-to-get-glibc-version-c-lang-26he
- https://stackoverflow.com/a/72480538
- https://stackoverflow.com/a/50558104
- https://unix.stackexchange.com/a/120498
- https://gcc.gnu.org/onlinedocs/gcc-4.6.2/libstdc++/api/a00783_source.html
- https://stackoverflow.com/a/10988540
- https://stackoverflow.com/q/75157669
- https://stackoverflow.com/a/50471325
- https://stackoverflow.com/a/14902711 TODO: read
- https://stackoverflow.com/a/53412829 TODO: read
- https://github.com/lattera/glibc/blob/895ef79e04a953cac1493863bcae29ad85657ee1/include/features.h#L420
- https://gcc.gnu.org/pipermail/gcc-patches/1999-October/021179.html
- https://gcc.gnu.org/pipermail/gcc-patches/2012-November/353923.html

```bash
strings /nix/store/vnwdak3n1w2jjil119j65k8mw1z23p84-glibc-2.35-224/lib/libc.so.6 \
| grep GLIBC \
| sed -n 's/.*@GLIBC_2/2/p' \
| sort -u -V \
| tail -1


nm -D -C /nix/store/vnwdak3n1w2jjil119j65k8mw1z23p84-glibc-2.35-224/lib/libc.so.6 | sed -n 's/.*@GLIBC_2/2/p' \
| sort -u -V \
| tail -n -2 \
| tail -n +2
```



```bash
EXPR=$(cat <<-'EOF'
(
let
   nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
   pkgs = import nixpkgs {};

  # Create a C++ program that prints ???
  gccVersion = pkgs.writeText "gcc-version.cpp" ''
    #include <iostream>

    #define STR_EXPAND(tok) #tok
    #define STR(tok) STR_EXPAND(tok)
    #define GCC_VERSION STR(__GNUC__) "." STR(__GNUC_MINOR__) "." STR(__GNUC_PATCHLEVEL__)
    
    int main()
    {
        std::cout << GCC_VERSION << std::endl;
    }
  '';
in
  pkgs.stdenv.mkDerivation {
        name = "gcc-version";
        src = gccVersion;
        buildPhase = ''
          g++ ${gccVersion} -o gcc-version
        '';
        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          cp gcc-version  $out/bin/gcc-version
          runHook postInstall
        '';
        dontUnpack = true;
      }
)
EOF
)



nix \
build \
--no-link \
--print-build-logs \
--impure \
--expr \
"$EXPR"

nix \
run \
--impure \
--expr \
"$EXPR"
```
Refs.:
- https://cplusplus.com/forum/general/62328/


```bash
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-20.03#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-20.09#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-21.05#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-21.11#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-22.05#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-22.11#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/release-23.05#stdenv.cc.cc.lib
nix build --no-link --print-out-paths github:NixOS/nixpkgs/nixpkgs-unstable#stdenv.cc.cc.lib

readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-20.03#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-20.09#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-21.05#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-21.11#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-22.05#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-22.11#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/release-23.05#stdenv.cc.cc.lib)/lib/libstdc++.so
readlink -f $(nix eval --raw github:NixOS/nixpkgs/nixpkgs-unstable#stdenv.cc.cc.lib)/lib/libstdc++.so
```


```bash
nix eval github:NixOS/nixpkgs/release-20.03#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/release-20.09#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/release-21.05#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/release-21.11#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/release-22.05#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/release-22.11#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/release-23.05#stdenv.cc.libc.version
nix eval github:NixOS/nixpkgs/nixpkgs-unstable#stdenv.cc.libc.version

nix eval github:NixOS/nixpkgs/release-20.03#glibc.version
nix eval github:NixOS/nixpkgs/release-20.09#glibc.version
nix eval github:NixOS/nixpkgs/release-21.05#glibc.version
nix eval github:NixOS/nixpkgs/release-21.11#glibc.version
nix eval github:NixOS/nixpkgs/release-22.05#glibc.version
nix eval github:NixOS/nixpkgs/release-22.11#glibc.version
nix eval github:NixOS/nixpkgs/release-23.05#glibc.version
nix eval github:NixOS/nixpkgs/nixpkgs-unstable#glibc.version

nix eval github:NixOS/nixpkgs/release-20.03#glibc.name
nix eval github:NixOS/nixpkgs/release-20.09#glibc.name
nix eval github:NixOS/nixpkgs/release-21.05#glibc.name
nix eval github:NixOS/nixpkgs/release-21.11#glibc.name
nix eval github:NixOS/nixpkgs/release-22.05#glibc.name
nix eval github:NixOS/nixpkgs/release-22.11#glibc.name
nix eval github:NixOS/nixpkgs/release-23.05#glibc.name
nix eval github:NixOS/nixpkgs/nixpkgs-unstable#glibc.name
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
readelf -sV \
$(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --expr \
  '
    (
      let
        nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
        pkgs = import nixpkgs { 
                                system = "x86_64-linux";
                              };
      in
        pkgs.stdenv.cc.cc.lib
    )
  '
)/lib/libstdc++.so.6.0.28 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
```

```bash
nix shell nixpkgs#binutils --command ldd --version
nix eval nixpkgs#glibc.version
```

```bash
strings $(
  nix \
  build \
  --no-link \
  --print-out-paths \
  github:NixOS/nixpkgs/release-21.11#stdenv.cc.cc.lib \
)/lib/libstdc++.so.6 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
```


```bash
strings $( cat \
$(
  nix \
  build \
  --no-link \
  --print-out-paths \
  github:NixOS/nixpkgs/nixpkgs-unstable#stdenv.cc.cc.lib.out \
)/nix-support/propagated-build-inputs)/lib/libstdc++.so.6 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
```


```bash
readelf -sV \
$(
  nix \
  build \
  --no-link \
  --print-out-paths \
  github:NixOS/nixpkgs/release-21.11#stdenv.cc.cc.lib \
)/lib/libstdc++.so.6 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
```



```bash
readelf -sV \
$(
  nix \
  build \
  --no-link \
  --print-out-paths \
  github:NixOS/nixpkgs/nixpkgs-unstable#stdenv.cc.cc.lib \
)/lib/libstdc++.so.6 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
```


```bash
readelf -sV \
$(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --expr \
  '
    (
      let
        nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
        pkgs = import nixpkgs { 
                                system = "x86_64-linux"; 
                                overlays = [
                                  (self: super: {
                                    glibc = super.glibc.overrideAttrs (oldAttrs: {
                                      version = "3.4.21";
                                    });
                                  })
                                ];
                              };
      in
        pkgs.stdenv.cc.cc.lib
    )
  '
)/lib/libstdc++.so.6.0.28 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V \
 | tail -1
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
        version = "3.4.21";
      });
    })
  ];
  }
).hello
')/bin/hello | grep 'glibc-3.4.21/lib'
```


```bash
ldd \
$(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --expr \
  '
    (
      let
        nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b"); 
        pkgs = import nixpkgs { 
                                system = "x86_64-linux"; 
                                overlays = [
                                  (self: super: {
                                    glibc = super.glibc.overrideAttrs (oldAttrs: {
                                      version = "3.4.21";
                                    });
                                  })
                                ];
                              };
      in
        pkgs.hello
    )
  '
)/bin/hello
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

##### GLIBC_ vs GLIBCXX_

```bash
strings $(nix build --no-link --print-out-paths --print-build-logs \
nixpkgs#glibc.out)/lib/libc.so.6 \
 | sed -n 's/.*@@GLIBC_//p' \
 | sort -u -V
 
 
strings $(nix build --no-link --print-out-paths --print-build-logs \
github:NixOS/nixpkgs/nixpkgs-unstable#glibc.out)/lib/libc.so.6 \
 | sed -n 's/.*@@GLIBC_//p' \
 | sort -u -V
```


```bash
strings $(nix build --no-link --print-out-paths --print-build-logs \
nixpkgs#stdenv.cc.cc.lib)/lib/libstdc++.so.6 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V

strings $(nix build --no-link --print-out-paths --print-build-logs \
github:NixOS/nixpkgs/nixpkgs-unstable#stdenv.cc.cc.lib)/lib/libstdc++.so.6 \
 | sed -n 's/.*@@GLIBCXX_//p' \
 | sort -u -V
```


```bash
# nix-shell -p hello --command 'patchelf --print-rpath $(which hello)'

nix \
shell \
--ignore-environment \
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
nix \
shell \
--ignore-environment \
nixpkgs#hello \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which hello) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#python3Minimal \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bashInteractive \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which bash) | wc -l'

nix \
shell \
--ignore-environment \
nixpkgs#python3Minimal \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which python3) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#git \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which git) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#python3Full \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which python3) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#bash \
nixpkgs#coreutils \
nixpkgs#glibc.bin \
nixpkgs#pandoc \
nixpkgs#which \
--command \
sh \
-c \
'ldd $(which pandoc) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#nodejs \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which node) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#nix \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which nix) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#imagemagick \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which magick) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#jre \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which java) | wc -l'


nix \
shell \
--ignore-environment \
nixpkgs#ffmpeg-full \
nixpkgs#which \
nixpkgs#glibc.bin \
nixpkgs#bash \
nixpkgs#coreutils \
--command \
sh \
-c \
'ldd $(which ffmpeg) | wc -l'
```

```bash
podman run --rm alpine sh -c \
'apk add ffmpeg && ldd $(which ffmpeg) && ldd $(which ffmpeg) | wc -l'

podman run --rm ubuntu bash -c \
'
apt-get update -y \
&& apt-get install -y ffmpeg \
&& ldd $(which ffmpeg) \
&& ldd $(which ffmpeg) | wc -l
'

podman run --rm ubuntu bash -c \
'
apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y ffmpeg \
&& ldd $(which ffmpeg) \
&& ldd $(which ffmpeg) | wc -l
'

podman run --rm fedora bash -c \
'
dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
&& dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm \
&& yum -y install ffmpeg which \
&& ldd $(which ffmpeg) \
&& ldd $(which ffmpeg) | wc -l
'
```

TODO: how to find the n biggest ones?
```bash
ldd {} | wc -l
find . -perm /555 | sort -u

find . -perm /555 -exec echo -n -- {} +
find . -perm /555 -exec ldd {} +
```
Refs.:
- https://unix.stackexchange.com/a/164777


```bash
objdump -x $(which ffmpeg) \ 
| grep 'R.*PATH' \
| cut -d'H' -f2 \
| tr -d ' ' \
| tr ':' '\n' \
| cut -d '-' -f2 \
| sort
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


TODO: do test all possible things overridable.
```bash
nix repl '<nixpkgs>' <<<'lib.attrNames (stdenv.overrides pkgs pkgs)'
```
Refs.:
- https://stackoverflow.com/a/58765599


TODO: Broken:
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



### Trick to troubleshooting, mastering the nix develop

> Note: the nix-shell is from the legacy CLI
https://nixos.org/manual/nix/stable/#managing-build-environments
https://stackoverflow.com/a/31627258


> The replacement is the `nix develop` command which uses the devShell.${system}` flake 
> output if it exists or `defaultPackage.${system}` otherwise.
> https://github.com/NixOS/nix/issues/2854#issuecomment-673923349 by Eelco


Legacy, do not use.
```bash
nix-shell '<nixpkgs>' -A pan
```

Modern (ironically it is broken):
```bash
nix \
develop \
nixpkgs#pan \
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
&& ./pan/gui/pan
'
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/017c0ef738ca1570b516c503d6327717e00ac8be/pkgs/applications/networking/newsreaders/pan/default.nix



```bash
unpackPhase
cd pan-*
configurePhase
buildPhase
./pan/gui/pan
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
du -h $( 
nix \
build \
--no-link \
--print-out-paths \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (pkgsStatic.redis.overrideAttrs (oldAttrs: { 
                                          dontStrip = false;
                              }
                        )
  )
)
'
)/bin/redis-server


du -h $( 
nix \
build \
--no-link \
--print-out-paths \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (pkgsStatic.redis.overrideAttrs (oldAttrs: { 
                                          dontStrip = true;
                              }
                        )
  )
)
'
)/bin/redis-server

# note: the file command is beeing tricked!
# https://github.com/NixOS/nixpkgs/issues/21667#issuecomment-270899104
file $( 
nix \
build \
--no-link \
--print-out-paths \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  (pkgsStatic.redis.overrideAttrs (oldAttrs: { 
                                          dontStrip = false;
                              }
                        )
  )
)
'
)/bin/redis-server
```
Refs.:
- https://github.com/NixOS/nixpkgs/issues/21667#issuecomment-270899104




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
TODO: why it is not deterministic, has not the same sha256sum?


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
# pwd
# mkdir -pv "$(pwd)/"tmp/out
# export out="$(pwd)/"tmp/out
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
cat \
$(
nix \
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
--ignore-environment \
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

TODO:
```bash
❯ nix-shell -p iana-etc
[nix-shell:~]$ env | grep NIX_ETC
NIX_ETC_SERVICES=/nix/store/aj866hr8fad8flnggwdhrldm0g799ccz-iana-etc-20210225/etc/services
NIX_ETC_PROTOCOLS=/nix/store/aj866hr8fad8flnggwdhrldm0g799ccz-iana-etc-20210225/etc/protocols
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
      buildInputs = [iana-etc];
      phases = [ "buildPhase" "installPhase" "fixupPhase" ];
      installPhase = "mkdir $out; env > $out/log.txt";
    })
)'
```

## overlays

Remember, unless P=NP, every thing has tradeoffs!


> You probably built part of the app with one gcc version 
> (and thus libstdc++ version) and part with another one.
> https://github.com/NixOS/nixpkgs/issues/216361#issuecomment-1431560404
> 
> You were right! kind of. I was using an overlay that was based on an 
> older nixpkgs. I had to rebase that on the current master, and now it works.



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
    (import <nixpkgs> { overlays = [ (self: super: { stdenv = super.stdenv 
                                                     // { overrides = self2: super2: super.stdenv.overrides self2 super2 
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


### overlays, final.symlinkJoin


```bash
nix repl '<nixpkgs>' <<<'builtins.functionArgs symlinkJoin'
```

```bash
nix \
shell \
--impure \
--expr \
'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = self: super: {
            Fabric = super.Fabric.overrideAttrs (old: rec{
              version = "1.14.post1";
              doInstallCheck = false;
              src =  super.fetchPypi {
                pname = "Fabric3";
                inherit version;
                sha256 = "108ywmx2xr0jypbx26cqszrighpzd96kg4ighs3vac1zr1g4hzk4";
              };
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Let"s put together a package set to use later
      myPythonPackages = ps: with ps; [
        Fabric
        # and other modules you"d like to add
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41")
             { overlays = [ overlay ]; }
             ).python3.withPackages myPythonPackages
    )

' \
--command \
python3 \
-c \
'import fabric; import fabric.version; print(fabric.version.get_version())'
```


```bash
nix \
shell \
--impure \
--expr \
'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = self: super: {
            numpy = super.numpy.overrideAttrs (old: rec{
              version = "1.23.0";
              doInstallCheck = false;
              src =  super.fetchPypi {
                pname = "numpy";
                inherit version;
                sha256 = "vT+k/i44Uz1TNuEnL8TnZcq7veFEMJzO6GdVCdXNewU=";
              };
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Let"s put together a package set to use later
      myPythonPackages = ps: with ps; [
        numpy
        # and other modules you"d like to add
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c")
             { overlays = [ overlay ]; }
             ).python3.withPackages myPythonPackages
    )

' \
--command \
python3 \
-c \
'import numpy as np; np.show_config(); print(np.__version__)'
```


First some idiomatic and simple example:
```bash
# nix flake metadata github:NixOS/nixpkgs/release-22.05
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/0874168639713f547c05947c76124f78441ea46c";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [
                                     pandas
                                   ]
                        )
)' \
--command \
python \
-c \
'import pandas as pd; print(pd.DataFrame(data={"col1": [1, 2], "col2": [3, 4]}))'
```


Testing the structure:
```bash
nix \
shell \
--impure \
--expr \
'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = self: super: {
            pandas = super.pandas;
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0ef02c4792fbde4b78957a46a8cb107b6c7aa3cc")
             { overlays = [ overlay ]; }
             ).python3.withPackages myPythonPackages
    )

' \
--command \
python \
-c \
'import pandas as pd; print(pd.DataFrame(data={"col1": [1, 2], "col2": [3, 4]}))'
```



```bash
EXPR=$(cat <<-END
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = self: super: {
            pandas = super.pandas;
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0ef02c4792fbde4b78957a46a8cb107b6c7aa3cc")
             { overlays = [ overlay ]; }
             ).python3.withPackages myPythonPackages
    )
END
)

nix \
build \
--impure \
--expr \
$EXPR
```

```bash
nix-store --query --tree --include-outputs $(readlink -f result/bin/python3) | wc -l
```

```bash
nix-store --query --graph --include-outputs $(readlink -f result/bin/python3) | dot -Tps > pandas.ps
```




```bash
EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            pandas = superPy.pandas.overrideAttrs (oldAttrs: rec{
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.patchelf super.addOpenGLRunpath ];
              postFixup = let rpath = super.lib.makeLibraryPath [ super.stdenv.cc.cc.lib ]; in (oldAttrs.postFixup or "") + ''
                find $out/${python3.sitePackages}/pandas/_libs/window -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
                  echo "setting rpath for $lib..."
                  patchelf --set-rpath "${rpath}:$out/${python3.sitePackages}/pandas/_libs/window " "$lib"
                  addOpenGLRunpath "$lib"
                done
              '';
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0ef02c4792fbde4b78957a46a8cb107b6c7aa3cc")
             { overlays = [ overlay ]; }
             ).python3.withPackages myPythonPackages
    )
EOF
)



nix \
shell \
--impure \
--expr \
"$EXPR" \
--command \
python \
-c \
'import pandas as pd; print(pd.DataFrame(data={"col1": [1, 2], "col2": [3, 4]}))'
```
Refs.:
- https://discourse.nixos.org/t/xorg-on-non-nixos/13455/2
- https://stackoverflow.com/a/67972927



```bash
nix \
log \
$(
  nix \
  build \
  --print-out-paths \
  --impure \
  --expr \
  "$EXPR"
) | cat
``` 

```bash
nix-store --query --tree --include-outputs $(readlink -f result/bin/python3) | wc -l
```

```bash
nix-store --query --graph --include-outputs $(readlink -f result/bin/python3) | dot -Tps > pandas-test-opengl.ps
```


```bash
EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            pandas = superPy.pandas.overrideAttrs (oldAttrs: rec{
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.patchelf super.addOpenGLRunpath ];
              postFixup = let rpath = super.lib.makeLibraryPath [ super.stdenv.cc.cc.lib ]; in (oldAttrs.postFixup or "") + ''
                find $out/${python3.sitePackages}/pandas/lib -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
                  echo "setting rpath for $lib..."
                  patchelf --set-rpath "${rpath}:$out/${python3.sitePackages}/pandas/_libs/window " "$lib"
                  addOpenGLRunpath "$lib"
                done
              '';
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0ef02c4792fbde4b78957a46a8cb107b6c7aa3cc")
             { overlays = [ overlay ]; }
             ).python3Packages.pandas
    )
EOF
)


nix \
show-derivation \
--impure \
--expr \
$EXPR | jq -r '.[].env.postFixup'
```
Refs.:
- https://discourse.nixos.org/t/xorg-on-non-nixos/13455/2
- https://stackoverflow.com/a/67972927


```bash
ldd $(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --print-build-logs \
  github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b#python3Packages.mmh3
)/lib/python3.10/site-packages/mmh3.cpython-310-x86_64-linux-gnu.so 
```


```bash
EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            mmh3 = superPy.mmh3.overrideAttrs (oldAttrs: rec {
              doCheck = false;
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ 
                                                                          super.autoPatchelfHook 
                                                                        ];
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        mmh3
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b")
             { overlays = [ overlay ]; }
             ).python3Packages.mmh3 # Could be python3.withPackages myPythonPackages
    )
EOF
)


ldd $(
nix \
build \
--no-link \
--print-out-paths \
--print-build-logs \
--impure \
--expr \
"$EXPR"
)/lib/python3.10/site-packages/mmh3.cpython-310-x86_64-linux-gnu.so 

```



```bash
ldd $(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --print-build-logs \
  github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b#python3Packages.pandas
)/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so
  
  
ldd $(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --print-build-logs \
  github:NixOS/nixpkgs/nixpkgs-unstable#python3Packages.pandas
)/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so
```



```bash
EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            pandas = superPy.pandas.overrideAttrs (oldAttrs: rec {
              doCheck = false;
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ 
                                                                          # super.autoPatchelfHook 
                                                                        ];
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b")
             { overlays = [ overlay ]; }
             ).python3Packages.pandas # Could be python3.withPackages myPythonPackages
    )
EOF
)


ldd $(
nix \
build \
--no-link \
--print-out-paths \
--print-build-logs \
--impure \
--expr \
"$EXPR"
)/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so


EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            pandas = superPy.pandas.overrideAttrs (oldAttrs: rec {
              doCheck = false;
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ 
                                                                          super.autoPatchelfHook 
                                                                        ];
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b")
             { overlays = [ overlay ]; }
             ).python3Packages.pandas # Could be python3.withPackages myPythonPackages
    )
EOF
)


ldd $(
nix \
build \
--no-link \
--print-out-paths \
--print-build-logs \
--impure \
--expr \
"$EXPR"
)/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so



nix \
shell \
--impure \
--expr \
"$EXPR" \
--command \
python \
-c \
'import pandas as pd; print(pd.DataFrame(data={"col1": [1, 2], "col2": [3, 4]}))'
```


--option enforce-determinism true

TODO: what are the minimal installation packages needed?
- https://stackoverflow.com/a/52976331
- https://codepyre.com/2019/12/arming-yourself/#required-packages-ubuntu-1804


TODO: 
it is on some link that `apt-get build-dep` does not take into acount what is already instaled.
```bash
podman \
run \
--interactive=true \
--rm=true \
--tty=false \
docker.io/library/ubuntu \
bash<<'EOF'
# cp /etc/apt/sources.list /etc/apt/sources.list~
sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
&& apt-get update \
&& apt-get --simulate build-dep ubuntu-desktop
EOF
```
Refs.:
- https://askubuntu.com/a/1422519
- https://superuser.com/questions/151557/what-are-build-essential-build-dep/151558#151558
- https://superuser.com/questions/1413089/how-can-i-determine-build-dependencies-automatically#comment2132547_1413093
- https://askubuntu.com/questions/21379/how-do-i-find-the-build-dependencies-of-a-package#comment1804798_21388
- https://askubuntu.com/a/1222437


```bash
cat << 'EOF' > Dockerfile
FROM ubuntu

RUN export DEBIAN_FRONTEND=noninteractive ; \
 sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
 && apt-get -y update \
 && apt-get -y install git \
 && apt-get -y build-dep qemu

RUN git clone git://git.qemu.org/qemu.git \
 && cd qemu \
 && git submodule update --init --recursive

EOF

podman build --file Dockerfile --tag ubuntu-qemu

podman \
run \
--interactive=true \
--rm=true \
--tty=false \
docker.io/library/ubuntu \
bash<<'EOF'
export DEBIAN_FRONTEND=noninteractive
sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list \
&& apt-get -y update \
&& apt-get -y install git \
&& apt-get -y build-dep qemu \
&& git clone git://git.qemu.org/qemu.git \
&& cd qemu \
&& git submodule update --init --recursive \
&& ./configure \
    --prefix=$(cd ..; pwd)/qemu-user-static \
    --static \
    --disable-system \
    --enable-linux-user
EOF
```
Refs.:
- http://logan.tw/posts/2018/02/18/build-qemu-user-static-from-source-code/



TODO: 
- help https://superuser.com/questions/1470611/install-pycurl-on-docker-using-fedora-image 

```bash
cat << 'EOF' > Dockerfile
FROM fedora:39

USER root

RUN dnf update -y \
 && dnf install -y \
    curl-devel \
    gcc \
    openssl \
    openssl-devel \
    python3-devel \
    python3-pip \
    python36

# "upgrade" pip to an pinned version
RUN pip3 --version \
 && pip3 install --upgrade pip \
 && pip3 --version \

# install pycurl
RUN pip3 install --install-option="--with-openssl" pycurl
EOF

podman build --file Dockerfile --tag fedora-with-pycurl
```

```bash
cat << 'EOF' > Dockerfile
FROM fedora:39

USER root

RUN dnf update -y \
 && dnf install -y \
    gcc \
    curl-devel \
    openssl-devel \
    python3-devel \
    python3-pip \
    python36

RUN pip3 --version \
 && pip3 install --upgrade pip==23.2.1 \
 && pip3 --version 

RUN pip3 install pycurl==7.45.2 \
 && pip3 freeze \
 && python3 -c 'import pycurl; print(pycurl.version_info())'
EOF

podman build --file Dockerfile --tag fedora-with-pycurl
```




```bash
ldd $(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --print-build-logs \
  github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b#python3Packages.pycurl
)/lib/python3.10/site-packages/pycurl.cpython-310-x86_64-linux-gnu.so
```

```bash
ldd $(
  nix \
  build \
  --no-link \
  --print-out-paths \
  --print-build-logs \
  github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b#pkgsMusl.python3Packages.pycurl
)/lib/python3.10/site-packages/pycurl.cpython-310-x86_64-linux-gnu.so
```


```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN env

RUN nix flake metadata nixpkgs \
 && cp -v $(nix \
      build \
      --max-jobs 0 \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#python3Packages.pycurl.dist)/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl

RUN ls -ahl /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl


FROM python:3.10.13-slim-bookworm as test-pycurl
USER root

COPY --from=build-from-nixos-cache-dist /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl
RUN pip3 install /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl


RUN pip3 freeze
EOF


podman \
build \
--file Dockerfile \
--target test-pycurl \
--tag test-pycurl \
.

podman kill container-test-pycurl \
&& podman rm --force container-test-pycurl || true \
&& podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=container-test-pycurl \
--interactive=true \
--name=conteiner-test-pycurl \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-pycurl:latest \
bash \
-c \
"
python3 -c '
import pycurl
from io import BytesIO 

b_obj = BytesIO() 
crl = pycurl.Curl() 

# Set URL value
crl.setopt(crl.URL, \"https://wiki.python.org/moin/BeginnersGuide\")

# Write bytes that are utf-8 encoded
crl.setopt(crl.WRITEDATA, b_obj)

# Perform a file transfer 
crl.perform() 

# End curl session
crl.close()

# Get the content stored in the BytesIO object (in byte characters) 
get_body = b_obj.getvalue()

# Decode the bytes stored in get_body to HTML and print the result 
print(get_body.decode(\"utf8\")) 
'
"
```
Refs.:
- https://stackabuse.com/using-curl-in-python-with-pycurl/

TODO: test it using the official alpine python image
```bash
nix build --no-link --print-out-paths --print-build-logs nixpkgs#pkgsMusl.python3Packages.numpy.dist
```


```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix -vv registry pin nixpkgs github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b

RUN cp -v $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#python311Packages.mmh3.dist)/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl

RUN ls -ahl /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl


FROM python:3.11.4-slim-bookworm as test-mmh3

USER root

COPY --from=build-from-nixos-cache-dist /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl
RUN pip3 install /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl

RUN pip3 freeze
EOF


podman \
build \
--cap-add=SYS_ADMIN \
--file Dockerfile \
--target test-mmh3 \
--tag test-mmh3 \
.


podman kill conteiner-test-mmh3 \
&& podman rm --force conteiner-test-mmh3 || true \
&& podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=container-nix \
--interactive=true \
--name=conteiner-test-mmh3 \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-mmh3:latest \
bash \
-c \
"
python3 -c 'import mmh3; print(mmh3.hash128(bytes(123)))'
python -c 'import site; print(site.getsitepackages())'
ldd /usr/local/lib/python3.11/site-packages/mmh3.cpython-311-x86_64-linux-gnu.so
ls -ahl /lib/x86_64-linux-gnu/libstdc++.so.6
"
```



```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix -vv registry pin nixpkgs github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b

RUN cp -v $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#python311Packages.mmh3.dist)/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl

RUN ls -ahl /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl


FROM python:3.11.4-slim-bookworm as test-mmh3

USER root

COPY --from=build-from-nixos-cache-dist /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl
RUN pip3 install /root/mmh3-3.0.0-cp311-cp311-linux_x86_64.whl

RUN pip3 freeze
EOF


podman \
build \
--cap-add=SYS_ADMIN \
--file Dockerfile \
--target test-mmh3 \
--tag test-mmh3 \
.


podman kill conteiner-test-mmh3 \
&& podman rm --force conteiner-test-mmh3 || true \
&& podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=container-nix \
--interactive=true \
--name=conteiner-test-mmh3 \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-mmh3:latest \
bash \
-c \
"
python3 -c 'import mmh3; print(mmh3.hash128(bytes(123)))'
python -c 'import site; print(site.getsitepackages())'
ldd /usr/local/lib/python3.11/site-packages/mmh3.cpython-311-x86_64-linux-gnu.so
ls -ahl /lib/x86_64-linux-gnu/libstdc++.so.6
"
```


```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix -vv registry pin nixpkgs github:NixOS/nixpkgs/51d906d2341c9e866e48c2efcaac0f2d70bfd43e

RUN env \
 && echo \
 && pwd

RUN nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#pkgsMusl.python310Packages.mmh3.dist

RUN ls -alh $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#pkgsMusl.python310Packages.mmh3.dist)

RUN cp -v $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#pkgsMusl.python310Packages.mmh3.dist)/mmh3-4.0.1-cp310-cp310-linux_x86_64.whl /root/mmh3-4.0.1-cp310-cp310-linux_x86_64.whl

RUN ls -ahl /root/


FROM python:3.10.13-alpine3.18 as test-mmh3-alpine

USER root

COPY --from=build-from-nixos-cache-dist /root/mmh3-4.0.1-cp310-cp310-linux_x86_64.whl /root/mmh3-4.0.1-cp310-cp310-linux_x86_64.whl
RUN pip3 install /root/mmh3-4.0.1-cp310-cp310-linux_x86_64.whl


RUN pip3 freeze
EOF


podman \
build \
--cap-add=SYS_ADMIN \
--file Dockerfile \
--target test-mmh3-alpine \
--tag test-mmh3-alpine \
.


podman kill conteiner-test-mmh3-alpine &> /dev/null || true \
&& podman rm --force conteiner-test-mmh3-alpine &> /dev/null || true \
&& podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=container-nix \
--interactive=true \
--name=conteiner-test-mmh3 \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-mmh3-alpine:latest \
sh \
-c \
"
python3 -c 'import mmh3; print(mmh3.hash128(bytes(123)))'
python -c 'import site; print(site.getsitepackages())'
#ldd /usr/local/lib/python3.10/site-packages/mmh3.cpython-310-x86_64-linux-gnu.so
#ls -ahl /lib/ld-musl-x86_64.so.1
"
```



```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN env \
 && echo \
 && pwd

RUN nix -vv registry pin nixpkgs github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b

RUN echo \
 && nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#pkgsMusl.python311Packages.numpy.dist

RUN ls -ahl /root/


FROM python:3.11.5-alpine3.18 as test-numpy-alpine

USER root

COPY --from=build-from-nixos-cache-dist /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl
RUN pip3 install /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl


RUN pip3 freeze
EOF


podman \
build \
--cap-add=SYS_ADMIN \
--file Dockerfile \
--target test-numpy-alpine \
--tag test-numpy-alpine \
.


podman kill conteiner-test-mmh3 \
&& podman rm --force conteiner-test-mmh3 || true \
&& podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=container-nix \
--interactive=true \
--name=conteiner-test-mmh3 \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-mmh3:latest \
bash \
-c \
"
python3 -c 'import pycurl; print(dir(pycurl))'
"

```



```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix -vv registry pin nixpkgs github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b

RUN ls -al $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#pkgsMusl.python311Packages.numpy.dist)

RUN ls -ahl /root/


FROM python:3.11.5-alpine3.18 as test-numpy-alpine

USER root

COPY --from=build-from-nixos-cache-dist /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl
RUN pip3 install /root/pycurl-7.45.1-cp310-cp310-linux_x86_64.whl


RUN pip3 freeze
EOF


podman \
build \
--cap-add=SYS_ADMIN \
--file Dockerfile \
--target test-numpy-alpine \
--tag test-numpy-alpine \
.


podman kill conteiner-test-numpy-alpine \
&& podman rm --force conteiner-test-numpy-alpine || true \
&& podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=conteiner-test-numpy-alpine \
--interactive=true \
--name=conteiner-test-numpy-alpine \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-numpy-alpine:latest \
bash \
-c \
"
python3 -c 'import numpy as np; print(np.dot([2j, 3j], [2j, 3j]))'
"

```



```bash
nix build --no-link --print-out-paths --print-build-logs nixpkgs#pkgsMusl.python3Packages.pandas.dist
```



##### The mmh3


```bash
nix build --no-link --max-jobs 0 --print-out-paths --print-build-logs nixpkgs#python3Packages.mmh3.dist
```


```bash
ldd \
"$(
nix build --no-link --max-jobs 0 --print-out-paths --print-build-logs nixpkgs#python3Packages.mmh3
)"/lib/python3.10/site-packages/mmh3.cpython-310-x86_64-linux-gnu.so
```

```bash
nix \
shell \
--max-jobs 0 \
nixpkgs#busybox-sandbox-shell \
nixpkgs#binutils \
-c \
sh<<COMMANDS
ldd \
"$(
     nix build --no-link --max-jobs 0 --print-out-paths --print-build-logs nixpkgs#python3Packages.mmh3
)"/lib/python3.10/site-packages/mmh3.cpython-310-x86_64-linux-gnu.so
COMMANDS
```



```bash
nix \
shell \
--impure \
--expr \
'
  (
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b");
      pkgs = import nixpkgs { };    
    in
      pkgs.python3.withPackages (pypkgs: with pypkgs; [
                                       mmh3
                                     ]
                                )
  )
' \
--command \
python3 -c 'import mmh3; print(mmh3.hash128(bytes(123)))'
```


```bash
EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            mmh3 = superPy.mmh3.overrideAttrs (oldAttrs: rec{
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.patchelf super.autoPatchelfHook ];
              postFixup = let rpath = super.lib.makeLibraryPath [ 
                                        super.python3Full
                                        super.boost
                                        super.stdenv.cc.cc.lib 
                                        super.pythonManylinuxPackages.manylinux2010Package 
                                        super.pythonManylinuxPackages.manylinux2014Package 
                                      ]; in (oldAttrs.postFixup or "") + ''
                find $out/${python3.sitePackages} -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
                  echo "setting rpath for $lib..."
                  patchelf --set-rpath "${rpath}:$out/${python3.sitePackages}" "$lib"
                done
              '';
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        mmh3
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0ef02c4792fbde4b78957a46a8cb107b6c7aa3cc")
             { overlays = [ overlay ]; }
             ).python3Packages.mmh3
    )
EOF
)

nix \
shell \
--max-jobs 0 \
nixpkgs#busybox-sandbox-shell \
nixpkgs#binutils \
-c \
sh<<COMMANDS
ldd \
"$(
    nix \
    build \
    --no-link \
    --print-build-logs \
    --print-out-paths \
    --impure \
    --expr \
    "$EXPR"
)"/lib/python3.10/site-packages/mmh3.cpython-310-x86_64-linux-gnu.so
COMMANDS

nix \
show-derivation \
--impure \
--expr \
$EXPR | jq -r '.[].env.postFixup'
```


```bash
ldd $(nix build --no-link --print-out-paths --print-build-logs nixpkgs#imagemagick)/bin/magick | wc -l
```


TODO: LD_DEBUG=statistics
```bash
ldd $(nix build --no-link --print-out-paths --print-build-logs nixpkgs#ffmpeg-full)/bin/ffmpeg | wc -l
```
Refs.:
- https://softwareengineering.stackexchange.com/a/391668




##### The `window/aggregations.cpython-38-x86_64-linux-gnu.so` thing:




```bash
nix build --no-link --max-jobs 0 --print-out-paths --print-build-logs nixpkgs#python3Packages.pandas
```


```bash
ldd \ 
"$(
     nix build --no-link --max-jobs 0 --print-out-paths --print-build-logs nixpkgs#python3Packages.pandas
)"/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so
```


```bash
nix \
shell \
--max-jobs 0 \
nixpkgs#busybox-sandbox-shell \
nixpkgs#binutils \
-c \
sh<<COMMANDS
ldd \
"$(
     nix build --no-link --max-jobs 0 --print-out-paths --print-build-logs nixpkgs#python3Packages.pandas
)"/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so
COMMANDS
```


```bash
nix \
shell \
--impure \
--expr \
'
  (
    let
      p = (builtins.getFlake "github:NixOS/nixpkgs/8ba90bbc63e58c8c436f16500c526e9afcb6b00a");
      pkgs = p.legacyPackages.${builtins.currentSystem};
      customPython3 = (pkgs.python3.withPackages (p: with p; [ pandas ]));
    in
      [
        customPython3
        (pkgs.writeScriptBin "python3_site_packages" "ldd ${customPython3}/${customPython3.sitePackages}/pandas/_libs/window/aggregations.cpython-310-${builtins.currentSystem}-gnu.so" )
      ]
  )
' \
--command \
python3_site_packages
```






```bash
EXPR=$(cat <<-'EOF'
(  
   let
      overlay = (self: super: rec {
        python3 = super.python3.override {
          packageOverrides = selfPy: superPy: {
            pandas = superPy.pandas.overrideAttrs (oldAttrs: rec{
              nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ super.patchelf ];
              postFixup = let rpath = super.lib.makeLibraryPath [ 
                                        super.stdenv.cc.cc.lib 
                                        super.pythonManylinuxPackages.manylinux2010Package 
                                        super.pythonManylinuxPackages.manylinux2014Package               
              ]; in (oldAttrs.postFixup or "") + ''
                find $out/${python3.sitePackages}/pandas/_libs -type f \( -name '*.so' -or -name '*.so.*' \) | while read lib; do
                  echo "setting rpath for $lib..."
                  patchelf --set-rpath "${rpath}:$out/${python3.sitePackages}/pandas/_libs" "$lib"
                done
              '';
            });
          };
        };

        python3Packages = python3.pkgs;
      });
      
      # Puts together a package set to use later
      myPythonPackages = ps: with ps; [
        pandas
        # and other python packages
      ];      
   in
     (import (builtins.getFlake "github:NixOS/nixpkgs/0ef02c4792fbde4b78957a46a8cb107b6c7aa3cc")
             { overlays = [ overlay ]; }
             ).python3Packages.pandas
    )
EOF
)


ldd \ 
"$(
  nix \
  build \
  --no-link \
  --print-build-logs \
  --print-out-paths \
  --impure \
  --expr \
  "$EXPR"
)"/lib/python3.10/site-packages/pandas/_libs/window/aggregations.cpython-310-x86_64-linux-gnu.so


nix \
show-derivation \
--impure \
--expr \
$EXPR | jq -r '.[].env.postFixup'
```
Refs.:
- https://discourse.nixos.org/t/xorg-on-non-nixos/13455/2
- https://stackoverflow.com/a/67972927



##### The python311Packages.ffmpeg-python




```bash
nix build --no-link --print-out-paths --print-build-logs nixpkgs#python311Packages.ffmpeg-python.dist
```



```bash
cat << 'EOF' > Dockerfile
FROM docker.nix-community.org/nixpkgs/nix-flakes as build-from-nixos-cache-dist

ENV PATH=/root/.nix-profile/bin:/usr/bin:/bin

RUN nix -vv registry pin nixpkgs github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b

RUN  ls -al $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#python311Packages.ffmpeg-python.dist)

RUN cp -v $(nix \
      build \
      --print-out-paths \
      --print-build-logs \
      nixpkgs#python311Packages.ffmpeg-python.dist)/ffmpeg_python-0.2.0-py3-none-any.whl /root/ffmpeg_python-0.2.0-py3-none-any.whl
      

RUN ls -ahl /root/ffmpeg_python-0.2.0-py3-none-any.whl


FROM docker.io/library/python:3.11.4-slim-bookworm as test-ffmpeg-python

USER root

COPY --from=build-from-nixos-cache-dist /root/ffmpeg_python-0.2.0-py3-none-any.whl /root/ffmpeg_python-0.2.0-py3-none-any.whl
RUN pip3 install /root/ffmpeg_python-0.2.0-py3-none-any.whl


RUN pip3 freeze
EOF

sudo \
podman \
build \
--cap-add=SYS_ADMIN \
--file Dockerfile \
--target test-ffmpeg-python \
--tag test-ffmpeg-python \
.


sudo podman kill conteiner-test-ffmpeg-python \
&& sudo podman rm --force conteiner-test-ffmpeg-python || true \
&& sudo podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/kvm:rw \
--hostname=container-nix \
--interactive=true \
--name=conteiner-test-ffmpeg-python \
--privileged=true \
--tty=true \
--rm=true \
localhost/test-ffmpeg-python:latest \
bash \
-c \
"
python3 -c 'import ffmpeg; print(dir(ffmpeg))'
python -c 'import site; print(site.getsitepackages())'
"
```




```bash
nix \
shell \
--impure \
--expr \
'(
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/ea4c80b39be4c09702b0cb3b42eab59e2ba4f24b");
      pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};

      customPython3 = (pkgs.python3.withPackages (pyPkgs: with pyPkgs; [ numpy matplotlib ]));
    in
      with pkgs; [ bashInteractive coreutils ffmpeg-full customPython3 ]
)' \
--command \
python3 -c 'import matplotlib.pyplot as plt'
```

    plt.axes()
    # Radius: 1, face-color: red, edge-color: blue
    circle = plt.Circle((1,1),0.5, fc='red',ec="blue")
    plt.gca().add_patch(circle)
    plt.axis('scaled')
    plt.show()


```bash
ffmpeg -r 30 -i {1,2,3}.jpg -vcodec mpeg4 -y movie.mp4 -vcodec mpeg4 -y -vb 40M
```
Refs.:
- https://stackoverflow.com/a/44951066
- https://stackoverflow.com/questions/50643085/generate-a-2-fps-mp4-from-images-using-ffmpeg#comment88299429_50643272
- https://stackoverflow.com/a/37478183

```python
video_format = "flv"
server_url = "http://127.0.0.1:8080"

process = (
    ffmpeg
    .input("input.mp4")
    .output(
        server_url, 
        codec = "copy", # use same codecs of the original video
        listen=1, # enables HTTP server
        f=video_format)
    .global_args("-re") # argument to act as a live stream
    .run()
)
```
https://github.com/kkroening/ffmpeg-python/tree/master/examples#stream-from-a-local-video-to-http-server



##### Emacs

```bash
nix \
build \
--impure \
--expr \
'
(  
   let
      overlay = final: prev: rec {
        my-emacs =
            final.symlinkJoin {
              name = "my-emacs";
              meta.mainProgram = "emacs";
              paths = with final; [
                emacs
                deno # LSP: JavaScript support
                nodePackages.vscode-html-languageserver-bin # LSP: HTML
              ];
              # symlinkJoin can not handle symlinked dirs and nodePackages
              # symlinks ./bin -> ./lib/node_modules/.bin/.

            };
      };
   in
   import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41")
  { overlays = [ overlay ]; }
).emacs
'
```

```bash
cat << 'EOF' > flake.nix
{
  description = "Emacs, with runtime dependencies";

  outputs = { nixpkgs, ... }:
    let
      overlay = final: prev: rec {
        my-emacs =
            final.symlinkJoin {
              name = "my-emacs";
              meta.mainProgram = "emacs";
              paths = with final; [
                emacs
                deno # LSP: JavaScript support
                nodePackages.vscode-html-languageserver-bin # LSP: HTML
              ];

              # symlinkJoin can't handle symlinked dirs and nodePackages
              # symlinks ./bin -> ./lib/node_modules/.bin/.
              postBuild = ''
                for f in $out/lib/node_modules/.bin/*; do
                   path="$(readlink --canonicalize-missing "$f")"
                   ln -s "$path" "$out/bin/$(basename $f)"
                done
              '';
            };
      };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in {
      inherit overlay;
      defaultPackage.x86_64-linux = pkgs.my-emacs;
    };
}
EOF

nix build -L .#
```
Refs.:
- https://www.ertt.ca/blog/2022/01-12-nix-symlinkJoin-nodePackages/



#####






```bash
cat << 'EOF' > flake.nix
{
  description = "Emacs, with runtime dependencies";

  outputs = { nixpkgs, ... }:
    let
      overlay = final: prev: 
        {
          pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
            (python-final: python-prev: {
              pottery = (python-final.buildPythonPackage rec {
                          name = "pottery";
                          version = "3.0.0";
                          src = prev.fetchFromGitHub {
                            owner = "brainix";
                            repo = "pottery";
                            rev = "c7be6f1f25c5404a460b676cc60d4e6a931f8ee7";
                            # sha256 = "${lib.fakeSha256}";
                            sha256 = "sha256-LP7SjQ4B9xckTKoTU0m1hZvFPvACk9wvCi54F/mp6XM=";
                          };
                          checkInputs = with prev.python3Packages; [ pytest ];
                          doCheck = true;
                          # buildInputs = with prev.python3Packages; [ uvloop ];
                          propagatedBuildInputs = with prev.python3Packages; [ typing-extensions redis mmh3 uvloop ];
                        });
            })
          ];
        
          python3 =
            let
              self = prev.python3.override {
                inherit self;
                packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
              }; in
            self;
        
          python3Packages = final.python3.pkgs;
        
        };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in {
      inherit overlay;
      # defaultPackage.x86_64-linux = pkgs.python3;
      # defaultPackage.x86_64-linux = pkgs.python3Packages.pottery;
      defaultPackage.x86_64-linux = (pkgs.python3.withPackages (ps: with ps; [ pottery numpy ]));    
    };
}
EOF

# nix build -L .#
# nix shell .# --command python3 -c 'import sys; print(sys.path)'
nix shell .# --command python3 -c 'from pottery import ReleaseUnlockedLock'
```
Refs.:
- https://discourse.nixos.org/t/add-python-package-via-overlay/19783/4


#### deeper...

```bash
django-admin-shell
django-celery-results
django-dry-rest-permissions
django-extended-choices
django-ip
django-simple-history
django-user-agents
pottery          
pycpfcnpj
python-decouple
django-ses = {extras = ["events"], version = "^3.1.0"}
django-ufilter
```


```bash
cat << 'EOF' > flake.nix
{
  description = "TODO";

  outputs = { nixpkgs, ... }:
    let
      overlay = final: prev: 
        {
          pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
            (python-final: python-prev: {
              pottery = (python-final.buildPythonPackage rec {
                          name = "pottery";
                          version = "3.0.0";
                          src = prev.fetchFromGitHub {
                            owner = "brainix";
                            repo = "pottery";
                            rev = "c7be6f1f25c5404a460b676cc60d4e6a931f8ee7";
                            # sha256 = "${lib.fakeSha256}";
                            sha256 = "sha256-LP7SjQ4B9xckTKoTU0m1hZvFPvACk9wvCi54F/mp6XM=";
                          };
                          checkInputs = with prev.python3Packages; [ pytest ];
                          doCheck = true;
                          # buildInputs = with prev.python3Packages; [ uvloop ];
                          propagatedBuildInputs = with prev.python3Packages; [ typing-extensions redis mmh3 uvloop ];
                        });
            })
          ];
        
          python3 =
            let
              self = prev.python3.override {
                inherit self;
                packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
              }; in
            self;
        
          python3Packages = final.python3.pkgs;
        
        };
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in {
      inherit overlay;
      # defaultPackage.x86_64-linux = pkgs.python3;
      # defaultPackage.x86_64-linux = pkgs.python3Packages.pottery;
      defaultPackage.x86_64-linux = (pkgs.python3.withPackages (ps: with ps; [ 
        pottery 
      ]));    
    };
}
EOF

# nix build -L .#
# nix shell .# --command python3 -c 'import sys; print(sys.path)'
nix shell .# --command python3 -c \
'
from pottery import ReleaseUnlockedLock
'
```
Refs.:
- https://discourse.nixos.org/t/add-python-package-via-overlay/19783/4




```bash
cat << 'EOF' > flake.nix
{
  description = "TODO";

  outputs = { nixpkgs, ... }:
    let
      overlay = final: prev: 
        {
          pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
            (python-final: python-prev: {
              pycpfcnpj = (python-final.buildPythonPackage rec {
                          name = "pycpfcnpj";
                          version = "1.0.2";
                          src = prev.fetchFromGitHub {
                            owner = "matheuscas";
                            repo = "pycpfcnpj";
                            rev = "70451946ae001757e7d065933741d9b2d6e8513c";
                            # sha256 = "${final.lib.fakeSha256}";
                            sha256 = "sha256-TN3aKViaeLCcV4ypNyYlrktWhp5HAqfPgoO7aefJhbU=";
                          };
                          checkInputs = with prev.python3Packages; [ nose ];
                          doCheck = true;                          
                        });
            })
          ];
        
          python3 =
            let
              self = prev.python3.override {
                inherit self;
                packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
              }; in
            self;
        
          python3Packages = final.python3.pkgs;
        };

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in {
      inherit overlay;
      # defaultPackage.x86_64-linux = pkgs.python3;
      # defaultPackage.x86_64-linux = pkgs.python3Packages.pottery;
      defaultPackage.x86_64-linux = (pkgs.python3.withPackages (ps: with ps; [ 
        pycpfcnpj 
      ]));    
    };
}
EOF

# nix build -L .#
# nix shell .# --command python3 -c 'import sys; print(sys.path)'
nix shell .# --command python3 -c \
'
from pycpfcnpj import cpfcnpj
print(cpfcnpj.validate("67170904055")) 
'
```



```bash
cat << 'EOF' > flake.nix
{
  description = "TODO";

  outputs = { nixpkgs, ... }:
    let
      overlay = final: prev: 
        {
          pythonPackagesOverlays = (prev.pythonPackagesOverlays or [ ]) ++ [
            (python-final: python-prev: {
              numpngw = (python-final.buildPythonPackage rec {
                          name = "numpngw";
                          version = "0.1.2";
                          src = prev.fetchFromGitHub {
                            owner = "WarrenWeckesser";
                            repo = "numpngw";
                            rev = "bae044cf659e9cee1d395f9ca1bdc36917e75e0d";
                            # sha256 = "${final.lib.fakeSha256}";
                            sha256 = "sha256-TgBhinPXcT+1SMpsTNE+CqkihlxuJdGNwmcr7HTLsqo=";
                          };
                          # checkInputs = with prev.python3Packages; [ ];
                          buildInputs = with prev.python3Packages; [ numpy ];
                          nativeBuildInputs = with prev.python3Packages; [ numpy ];
                          propagatedBuildInputs = with prev.python3Packages; [ numpy ];
                          doCheck = true;                          
                        });
            })
          ];
        
          python3 =
            let
              self = prev.python3.override {
                inherit self;
                packageOverrides = prev.lib.composeManyExtensions final.pythonPackagesOverlays;
              }; in
            self;
        
          python3Packages = final.python3.pkgs;
        };

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ overlay ];
      };
    in {
      inherit overlay;
      # defaultPackage.x86_64-linux = pkgs.python3;
      # defaultPackage.x86_64-linux = pkgs.python3Packages.pottery;
      defaultPackage.x86_64-linux = (pkgs.python3.withPackages (ps: with ps; [ 
        numpngw 
      ]));    
    };
}
EOF

# nix build -L .#
# nix shell .# --command python3 -c 'import sys; print(sys.path)'
nix shell .# --command python3 -c \
'
import numpy as np
import numpngw


img0 = np.zeros((64, 64, 3), dtype=np.uint8)
img0[:32, :32, :] = 255
img1 = np.zeros((64, 64, 3), dtype=np.uint8)
img1[32:, :32, 0] = 255
img2 = np.zeros((64, 64, 3), dtype=np.uint8)
img2[32:, 32:, 1] = 255
img3 = np.zeros((64, 64, 3), dtype=np.uint8)
img3[:32, 32:, 2] = 255
seq = [img0, img1, img2, img3]
for img in seq:
    img[16:-16, 16:-16] = 127
    img[0, :] = 127
    img[-1, :] = 127
    img[:, 0] = 127
    img[:, -1] = 127

numpngw.write_apng("squares.png", seq, delay=250, use_palette=True)
'
```
Refs.:
- https://github.com/WarrenWeckesser/numpngw/tree/bae044cf659e9cee1d395f9ca1bdc36917e75e0d
- https://stackoverflow.com/questions/753190/programmatically-generate-video-or-animated-gif-in-python/32978565#32978565


```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  ( 
    let
      p = (builtins.getFlake "github:NixOS/nixpkgs/8ba90bbc63e58c8c436f16500c526e9afcb6b00a");
      pkgs = p.legacyPackages.${builtins.currentSystem};
    in
      pkgs.poetry2nix.mkPoetryApplication {
        projectDir = ./.;
      }
  )
'
```



```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  ( 
    let
      p = (builtins.getFlake "github:NixOS/nixpkgs/8ba90bbc63e58c8c436f16500c526e9afcb6b00a");
      pkgs = p.legacyPackages.${builtins.currentSystem};
    in
      pkgs.poetry2nix.mkPoetryApplication rec {
        src = pkgs.fetchFromGitHub {
                            owner = "django-ses";
                            repo = "django-ses";
                            rev = "f9ebfab30d2b8dab9a9c73fc9ec2f36037533e65";
                            # sha256 = "${pkgs.lib.fakeSha256}";
                            sha256 = "sha256-daeOc8c4FLBu/Zvvdo2/FEszCzBR28z0lUxJFfv3fGk=";
                          };
        projectDir = "${src}";
      }
  )
'
```

Broken as of now
```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  ( 
    let
      p = (builtins.getFlake "github:NixOS/nixpkgs/8ba90bbc63e58c8c436f16500c526e9afcb6b00a");
      pkgs = p.legacyPackages.${builtins.currentSystem};
    in
      pkgs.poetry2nix.mkPoetryApplication rec {
        src = pkgs.fetchFromGitHub {
                            owner = "sdispater";
                            repo = "pendulum";
                            rev = "46b27c122d060ae9df139311ca0d4d880ac5137e";
                            # sha256 = "${pkgs.lib.fakeSha256}";
                            sha256 = "sha256-g23HZIuUuJUGdKiENH3wNOeb6eAGhCy6E6ZAlTe7O/k=";
                          };
        projectDir = "${src}";
      }
  )
'
```


```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  ( 
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c");
      pkgs = nixpkgs.legacyPackages.${builtins.currentSystem};
    in
      pkgs.poetry2nix.mkPoetryApplication rec {
        src = pkgs.fetchFromGitHub {
                            owner = "python-poetry";
                            repo = "poetry";
                            rev = "cfdba43923b7ec386c44583055077cb697ced7bd";
                            sha256 = "sha256-USH1dYc4nwNUTcqzgfB/5iZSr2lY19TI0Z2BUdS6o2E=";
                          };
        projectDir = "${src}";
      }
  )
'
```


TODO: make this huge thing work!

```bash
cat << 'EOF' > flake.nix
{
  description = "Application packaged using poetry2nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.poetry = {
    url = "github:python-poetry/poetry";
    flake = false;
  };
  
  outputs = { self, nixpkgs, flake-utils, poetry2nix, poetry }:
    {
      # Nixpkgs overlay providing the application
      overlay = nixpkgs.lib.composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          # The application
          myapp = prev.poetry2nix.mkPoetryApplication {
            projectDir = "${poetry}";
          };
          # The env
          myenv = prev.poetry2nix.mkPoetryEnv {
            projectDir = "${poetry}";
          };

          poetry2nix = prev.poetry2nix.overrideScope' (p2nixfinal: p2nixprev: {
            # pyfinal & pyprev refers to python packages
            defaultPoetryOverrides = (p2nixprev.defaultPoetryOverrides.extend (pyfinal: pyprev:
              {
                ### dodge infinite recursion ###
                setuptools = prev.python310Packages.setuptools.override {
                  inherit (pyfinal)
                    bootstrapped-pip
                    pipInstallHook
                    setuptoolsBuildHook
                  ;
                };
              }
            ));
          });
        })
      ];
    } // (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      {

        packages.default = pkgs.myapp;
        packages.myapp = pkgs.myapp;
        packages.myenv = pkgs.myenv;
        
        devShells.dev = pkgs.mkShell {
          buildInputs = with pkgs; [
            #(python310.withPackages (ps: with ps; [ poetry ]))
            pkgs.myenv
          ];
        };
        
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python310.withPackages (ps: with ps; [ poetry ]))
          ];
        };
      }));
}
EOF

nix build -L .#

nix run .#
```
Refs.:
- https://discourse.nixos.org/t/how-to-create-a-poetry2nix-environment-with-a-flake/23604/9


#### dockerTools.examples.redis + overlays


```bash
EXPR_NIX='
  (
    let
      overlayPkgsStaticRedis = self: super: {
        redis = super.pkgsStatic.redis.overrideAttrs (old: {
          doCheck = false;
        });
      };
    
      pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") { overlays = [ overlayPkgsStaticRedis ]; };
    
    in
      pkgs.dockerTools.examples.redis
  )
'

cat $(nix \
build \
--print-out-paths \
--impure \
--expr \
"$EXPR_NIX") | podman load
```


#### income-front, private repo

```bash
nix \
build \
--print-build-logs \
--impure \
--expr \
'
  ( 
    let
      p = (builtins.getFlake "github:NixOS/nixpkgs/8ba90bbc63e58c8c436f16500c526e9afcb6b00a");
      pkgs = p.legacyPackages.${builtins.currentSystem};
    in
      pkgs.stdenv.mkDerivation {
                name = "income-front";
                src = fetchGit {
                            # owner = "imobanco";
                            # repo = "income-front";
                            # rev = "cfdba43923b7ec386c44583055077cb697ced7bd";
                            # sha256 = "";
                            url = "git+ssh://git@github.com/imobanco/income-front/archive/refs/tags/v5.0.16.tar.gz";
                          };
                buildPhase = "mkdir -pv $out/site; cp -R . $out/site";
                dontInstall = true;
              }
  )
'
```




```bash
nix \
-L \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ba6ba2b90096dc49f448aa4d4d783b5081b1cc87";
  with legacyPackages.${builtins.currentSystem};
    (
      podman-unwrapped.overrideAttrs (oldAttrs: {
          src = fetchFromGitHub {
            owner = "containers";
            repo = "podman";
            rev = "9fbf91801d4540d48f51b11fb3ca33182d2525e7";
            sha256 = "sha256-WX3/gKuHkZfotc/YtAXuCfLfkSh3HT8QmFqHrdMZNXI=";
          };
          patches = [];
      }
    )
  )
)
'
```
