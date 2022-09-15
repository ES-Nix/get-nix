

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