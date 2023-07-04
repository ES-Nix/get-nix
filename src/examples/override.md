## The .overrides and .overrideAttrs


```bash
! ldd $(nix build --print-out-paths nixpkgs#pkgsStatic.sqlite)/bin/sqlite3 || echo Error
```


TODO:

busybox.override {
  enableStatic = true;
  enableMinimal = true;
  extraConfig = ''
    CONFIG_FEATURE_FANCY_ECHO y
    CONFIG_FEATURE_SH_MATH y
    CONFIG_FEATURE_SH_MATH_64 y
    CONFIG_FEATURE_TEST_64 y

    CONFIG_ASH y
    CONFIG_ASH_OPTIMIZE_FOR_SIZE y

    CONFIG_ASH_ALIAS y
    CONFIG_ASH_BASH_COMPAT y
    CONFIG_ASH_CMDCMD y
    CONFIG_ASH_ECHO y
    CONFIG_ASH_GETOPTS y
    CONFIG_ASH_INTERNAL_GLOB y
    CONFIG_ASH_JOB_CONTROL y
    CONFIG_ASH_PRINTF y
    CONFIG_ASH_TEST y
  '';
}

https://github.com/NixOS/nixpkgs/blob/master/pkgs/os-specific/linux/busybox/sandbox-shell.nix
https://www.reddit.com/r/NixOS/comments/mfnar8/how_do_i_overwrite_the_busybox_utilities/
https://github.com/NixOS/nixpkgs/issues/10716

Other TODO:
pkgs.mkShell.override {stdenv = pkgs.gcc10Stdenv} {
  inputsFrom = ...;
  ...
}
https://stackoverflow.com/questions/62592923/nix-how-to-change-stdenv-in-nixpkgs-mkshell

```bash
nix \
build \
--no-link \
--print-build-logs \
--print-out-paths \
--impure \
--expr \
'
(
  let
    nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c");
    pkgs = import nixpkgs {};
  in
    (curl.override { gnutlsSupport = true; opensslSupport = false; })
)
'
```

TODO: Broken:
```bash
nix \             
build \
--no-link \
--print-build-logs \
--print-out-paths \
--impure \
--expr \
'
(
  let
    nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c");
    pkgs = import nixpkgs {};
  in
    (pkgs.pkgsStatic.curl.override { gnutlsSupport = false; opensslSupport = true; })
)
'
```

TODO: Broken:
```bash
EXPR_NIX='
  (
    let
    
      overlay = self: super:
        let
          coreutils = pkgs.coreutils.override {
            selinuxSupport = false;
          };
        in
            {
              # Overrides for stuff from stdenv go here. They are applied last
              # so we use the same stdenv for builds but a custom coreutils etc for
              # our system. This allows use to still use cache.nixos.org.
              stdenv = super.stdenv // {
                overrides = self2: super2: super.stdenv.overrides self2 super2 // {
                  inherit coreutils;
                };
              };
            };
    in 
      let 
        nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c");
        pkgs = import nixpkgs { overlays = [ overlay ]; };
      in
        pkgs.stdenv
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
Refs.:
- https://stackoverflow.com/a/58765599


```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ef2f213d9659a274985778bff4ca322f3ef3ac68";
  with legacyPackages.${builtins.currentSystem};
    (
        let
          python = pkgs.python38.override {
            packageOverrides = self: super: {
              pytest = super.pytest.overridePythonAttrs (old: rec {
                doCheck = false;
                doInstallCheck = false;
              });
            };
          };
          myPy = python.withPackages
            (p: with p; [ numpy pip pytest ]);
        in pkgs.mkShell {
          buildInputs = with pkgs; [
            myPy
          ];
        }
    )
  )
' 

\
--command \
python \
-c \
'
```
Refs.:
- https://rgoswami.me/posts/ccon-tut-nix/#non-standard-python


```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c";
  with legacyPackages.${builtins.currentSystem};
    (
        let python =
          let packageOverrides = self: super: {
            dask = super.buildPythonPackage rec {
              pname = "dask";
              version = "2.15.0";
              src = super.fetchPypi {
                inherit pname version;
                sha256 = "17bca7rdrkvwf8yib7g58hsd7yrmfaslnq10vm9sw9lzcyszl7li";
              };
              checkInputs = with pkgs.python3.pkgs; [ pytest ];
              propagatedBuildInputs = with pkgs.python3.pkgs; [
                bokeh cloudpickle dill fsspec numpy pandas partd toolz
              ];
              doCheck = false;
            };
          };
          in pkgs.python3.override {
            inherit packageOverrides;
            self = python;
          };
        in pkgs.mkShell {
          buildInputs = with pkgs; [
            python3.pkgs.dask bashInteractive
          ];
        }
    )
  )                                                                                                                                                              
' \
--command \
bash
```


https://stackoverflow.com/questions/72814871/nixpkgs-overlays-and-nixpkgs-config-packageoverrides-not-being-reflected-in-envi



```bash
nix \
shell \
--impure \
--expr \
'
(
    let
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c");
    in
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

          pkgs = import nixpkgs { overlays = [ overlay ]; };
        in
          with pkgs; [ 
            (python3.withPackages (ps: with ps; [ Fabric ])) 
            cowsay
          ]
    )
  )                                                                                                                                                              
' \
--command \
python3 -c 'from fabric.api import local; local("cowsay Hello Fabric world!")'
```


```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ef2f213d9659a274985778bff4ca322f3ef3ac68";
  with legacyPackages.${builtins.currentSystem};
    (
      (pkgs.python3.override { sqlite = pkgsStatic.sqlite; })
    )
  )
' \
--command \
python \
-c \
'
import platform, sqlite3
print("Oper Sys : %s %s" % (platform.system(), platform.release()))
print("Platform : %s %s" % (platform.python_implementation(), platform.python_version()))
print("SQLite   : %s" % (sqlite3.sqlite_version))
'
```

[Customizing packages in Nix](https://bobvanderlinden.me/customizing-packages-in-nix/)



```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
    with legacyPackages.${builtins.currentSystem};
    (python3Minimal.override
      {
        reproducibleBuild = true;
      }
    )
  )
'
```


```bash
EXPR_NIX='
  (
    with builtins.getFlake "github:NixOS/nixpkgs/3364b5b117f65fe1ce65a3cdd5612a078a3b31e3";
    with legacyPackages.${builtins.currentSystem};
    (pkgsStatic.python3Minimal.override
      {
        reproducibleBuild = true;
      }
    )
  )
'

nix \
build \
--impure \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--expr \
"$EXPR_NIX"

EXPECTED_SHA512SUM=b6621c62c76c3d09c488222a5813e2f67f4f256c66780ca0da41eb6fe71d798c702e270c35cfa3b761484eef8a539589b3b3824523ecf6a8ad837ab74a3ce506
FULL_PATH=$(nix eval --impure --raw --expr $EXPR_NIX)/bin/python
echo "$EXPECTED_SHA512SUM"'  '"$FULL_PATH" | sha512sum -c
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (python3Minimal.override
    {
      packageOverrides = final: prev: {
        flask = prev.flask.overrideAttrs (oldAttrs: {
          preFixup = (oldAttrs.preFixup or "") + "set -x";
        });
      };
    }
  )
)'
```



```bash
nix \
shell \
--refresh \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
      (python3.buildEnv.override
        {
          extraLibs = with python3Packages; [ numpy ];
        }
      )
)
' \
--command \
python \
-c \
'import numpy as np; np.show_config(); print(np.__version__)'
```


```bash
nix \
run \
--refresh \
--impure \
--expr \
'
(
  import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992")
  { overlays = [(final: prev: {
                  python3 = prev.python3.override {
                    packageOverrides = final: prev: {
                      flask = prev.isort.overridePythonAttrs (oldAttrs: rec {
                          postFixup = (prev.postFixup or "abcdefg") + "";
                        });
                      };
                    };
                  })
               ];
  }
).python3.pkgs.isort
'
```


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (python3.buildEnv.override
    {
      extraLibs = with python3Packages; [ numpy ];
    }
  )
).env
'
```


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (python3.buildEnv.override
    {
      extraLibs = with python3Packages; [ flask hello ];
    }
  )
).env
'
```


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
      podman-unwrapped.override { systemd = null; }
    )
  )
'
```


Broken (for `.override` work it must be the unwrapped one):
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
      podman.override { systemd = null; }
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
      podman-unwrapped.override {
        systemd = null;
      }
  )
)
'
```


```bash
nix \
show-derivation \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
    (
      podman-unwrapped.override {
        systemd = null;
      }
  )
)
'
```

```bash
nix build --no-link --print-build-logs nixpkgs#podman.inputDerivation
```
Refs.:
- 

## nginx

TODO:
https://discourse.nixos.org/t/does-nginx-package-in-the-nixpkgs-repos-compiled-with-mail-proxy-support/9429/4


## enableDebugging for hello

https://github.com/NixOS/nixpkgs/issues/136756#issuecomment-917264024


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ef2f213d9659a274985778bff4ca322f3ef3ac68";
  with legacyPackages.${builtins.currentSystem};
    (
      (pkgs.python3.override { postFixup = (final.postFixup or "asdff") + ""; })
    )
  )
'
```

## static sudo with pam = null

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/ef2f213d9659a274985778bff4ca322f3ef3ac68";
  with legacyPackages.${builtins.currentSystem};
    (
      (pkgs.pkgsStatic.sudo.override { pam = null; })
    )
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
  with builtins.getFlake "github:NixOS/nixpkgs/ba6ba2b90096dc49f448aa4d4d783b5081b1cc87";
  with legacyPackages.${builtins.currentSystem};
    (
      (pkgs.podman.override { 
          src = fetchFromGitHub {
            owner = "containers";
            repo = "podman";
            rev = "9fbf91801d4540d48f51b11fb3ca33182d2525e7";
            sha256 = "";
          };
      })
    )
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
      p = (builtins.getFlake "github:NixOS/nixpkgs/0874168639713f547c05947c76124f78441ea46c");
      pkgs = p.legacyPackages.${builtins.currentSystem};
      fc-cache-fix = "${builtins.readFile ./fc-cache-fix.patch}";
    in
      ( 
        pkgs.fontconfig.overrideAttrs (oldAttrs: {
          patches = [ fc-cache-fix ];
          # buildInputs = (oldAttrs.buildInputs or []) ++ [ pkgs.neovim pkgs.git ];
        }
      )
    )
  )
'
```


source $stdenv/setup

cd "$(mktemp -d)" \
&& unpackPhase \
&& cd */ 

\
&& pwd \
&& phases="configurePhase buildPhase patchPhase" genericBuild

    let
      #
      nixpkgs = (builtins.getFlake "github:NixOS/nixpkgs/0938d73bb143f4ae037143572f11f4338c7b2d1c"); 
      pkgs = import nixpkgs { system = "x86_64-linux"; };

      nixuserKeys = pkgs.writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
(wine.override { wineBuild = "wine64"; })
https://nixos.wiki/wiki/Wine