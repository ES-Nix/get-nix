## The .overrides and .overrideAttrs


```bash
! ldd $(nix build --print-out-paths nixpkgs#pkgsStatic.sqlite)/bin/sqlite3 || echo Error
```

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
      (pkgs.python3.override { sqlite = pkgsStatic.sqlite; })
    )
  )
'
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
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (python3Minimal.override
    {
      reproducibleBuild = true;
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



