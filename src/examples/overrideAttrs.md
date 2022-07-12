

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
