

https://www.youtube.com/watch?v=6VepnulTfu8

> I'm not convinced getting rid of `NIX_CFLAGS_COMPILE` is a good idea. 
> `NIX_CFLAGS_COMPILE` is consistent and reliable, unlike figuring out the magic 
> incantation (often silently ignored) to tell the build system to pass a flag to the C compiler.
https://github.com/NixOS/nixpkgs/issues/79303#issuecomment-720647170


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
NIXPKGS_ALLOW_BROKEN=1 \
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
        preFixup = "";
      }
    )
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
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem}.pkgsStatic; 
    (
      catatonit.overrideAttrs (oldAttrs: {
        nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [ patchelf ];
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

####

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



### Old gcc version


https://discourse.nixos.org/t/compiling-with-old-glibc/12054/4