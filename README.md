# get-nix

Is an unofficial wrapper of the nix installer, unstable for now!

https://nixos.org/guides/install-nix.html

https://nix.dev/tutorials/install-nix

## Single user


https://nixos.org/manual/nix/stable/#sect-single-user-installation


```bash
test -d /nix || (sudo mkdir -m 0755 /nix && sudo -k chown "$USER": /nix); \
test $(stat -c %a /nix) -eq 0755 || sudo -kv chmod 0755 /nix; \
BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& NIX_RELEASE_VERSION='2.10.2' \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version
```

Maybe, if you use `zsh`, you need `. ~/.zshrc` to get the zsh shell working again.

You may need to install curl (sad, i know, but it might be the last time):
```bash
sudo apt-get update
sudo apt-get install -y curl
```

About the 2.4 release: [Nix 2.4 released](https://discourse.nixos.org/t/nix-2-4-released/15822), 
https://github.com/NixOS/nix/pull/5247#issuecomment-920207863, https://github.com/NixOS/nix/milestone/11, 
https://github.com/NixOS/nix/releases/tag/2.4.


https://github.com/NixOS/nix/tags

### Testing your installation (not a must, it is probably broken in your system!)

Optional: to test your installation.
Note: it needs lots of memory and internet and time, it needs some improvements.
```bash
nix \
develop \
--refresh \
github:ES-Nix/get-nix/draft-in-wip \
--command \
run all-tests
```

```bash
nix flake check github:ES-Nix/get-nix/draft-in-wip \
&& nix develop github:ES-Nix/get-nix/draft-in-wip --command echo 'End.' \
&& nix develop github:ES-Nix/get-nix/draft-in-wip --command run test_config_1 \
&& nix store gc --verbose \
&& nix store optimise --verbose \
&& nix flake --version \
&& nix flake metadata nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc
```

```bash
nix develop .# --command echo 'End.'
```


```bash
nix flake check github:ES-Nix/get-nix/draft-in-wip
```

```bash
nix develop github:ES-Nix/get-nix/draft-in-wip --command echo 'End.'
```

## Troubleshoot commands



### Remove nix

Sometimes useful:
```bash
rm -rfv "$HOME"/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.cache/nix}
sudo rm -fr /nix
```

When you get an error like this (only after many huge builds, but depends on how much memory you have)
`error: committing transaction: database or disk is full (in '/nix/var/nix/db/db.sqlite')`

### About memory

```bash
nix store gc -v \
&& du -L -h -s /nix \
&& nix profile install nixpkgs#hello nixpkgs#figlet \
&& nix store gc \
&& hello | figlet \
&& du -L -h -s /nix \
&& nix profile remove $(nix eval --raw nixpkgs#hello) $(nix eval --raw nixpkgs#figlet) \
&& nix store gc \
&& command -v hello || echo 'The hello excutable/binary was not found on $PATH.' \
&& command -v figlet || echo 'The figlet excutable/binary was not found on $PATH.' \
&& du -L -h -s /nix
```


#### For check size of /nix: long flags version

```bash
du --dereference --human-readable --summarize /nix
```

#### For check size of /nix: short flags version:

```bash
du -L -h -s /nix
```

```bash
jq --version || nix profile install nixpkgs#jq
nix path-info --json --all | jq 'map(.narSize) | add'
nix path-info nixpkgs#nix_2_4
```

```bash
echo "$(dirname "$(dirname "$(readlink -f "$(which nix)")")")"
```

```bash
nix shell nixpkgs#libselinux --command getenforce
```

Remove all things in the default profile and garbage collect :
```bash
nix profile remove '.*' \
&& nix store gc --verbose
```


```bash
nix-shell \
-I nixpkgs=channel:nixos-21.05 \
--packages \
nixFlakes \
--run \
'nix --version'
```

```bash
nix-shell \
-I nixpkgs=channel:nixos-21.09 \
--packages \
nixFlakes \
--run \
"nix --version && nix flake metadata nixpkgs"
```

```bash
nix-shell \
-I nixpkgs=channel:nixos-21.11 \
--packages \
nixFlakes \
--run \
"nix --version && nix flake metadata nixpkgs"
```

```bash
nix flake metadata github:NixOS/nixpkgs/nixos-21.11
```

```bash
nix \
run \
nixpkgs#nix-info -- --markdown
nix shell nixpkgs#nix-info --command nix-info --markdown
nix show-config
jq --version || nix profile install nixpkgs#jq
nix show-config --json | jq .

nix verify
nix doctor 
nix path-info
nix path-info nixpkgs#nix_2_4
nix flake metadata nixpkgs
jq --version || nix profile install nixpkgs#jq
nix flake metadata nixpkgs --json | jq .

nix run nixpkgs#neofetch
nix run nixpkgs#neofetch -- --json
nix shell nixpkgs#neofetch --command neofetch
```

```bash
nix flake show nixpkgs
nix flake show github:nixos/nixpkgs
nix flake show github:nixos/nixpkgs/nixpkgs-unstable

# For development version use nix flake metadata '.#'
nix flake metadata nixpkgs
nix flake metadata github:nixos/nixpkgs
nix flake metadata github:nixos/nixpkgs/nixpkgs-unstable

# It requires that the flake has as input the nixpkgs
echo 'github:NixOS/nixpkgs/'"$(nix flake metadata '.#' --json | jq -r '.locks.nodes.nixpkgs.locked.rev')"
```

```bash
jq --version || nix profile install nixpkgs#jq
echo $(nix show-config --json) | jq -S 'keys'
```


```bash
jq --version || nix profile install nixpkgs#jq
echo $(nix show-config --json) | jq -M '."warn-dirty"[]'
```
TODO: create tests asserting for each key an expected value?! 
Use a fixed output derivation to test this output?

[Processing JSON using jq](https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4)
[jqplay](https://jqplay.org/s/K_-O_YrxD5)

Useful for debug:
```bash
stat $(readlink "$HOME"/.nix-defexpr/nixpkgs)
stat $(readlink /nix/var/nix/gcroots)
stat $(echo $(echo $NIX_PATH) | cut --delimiter='=' --field=2)
echo -e " "'"$ENV->"'"$ENV\n" '"$NIX_PATH"->'"$NIX_PATH\n" '"$PATH"->'"$PATH\n" '"$USER"->' "$USER\n"
```

Excellent:
```bash
echo "${PATH//:/$'\n'}"
ls -al "$HOME"/.nix-profile
ls -al $(echo "$PATH" | cut -d ':' -f 1 | cut -d '=' -f 1 )
nix profile list --profile "$HOME"/.nix-profile
```
From: https://askubuntu.com/a/600028

For detect KVM:
```
egrep -c '(vmx|svm)' /proc/cpuinfo
egrep -q 'vmx|svm' /proc/cpuinfo && echo yes || echo no
egrep '^flags.*(vmx|svm)' /proc/cpuinfo
nix shell nixpkgs#ripgrep --command rg 'vmx|svm' /proc/cpuinfo
ls -l /dev/kvm
```

TODO: use ripgrep?
https://github.com/actions/virtual-environments/issues/183#issuecomment-580992331
https://github.com/sickcodes/Docker-OSX/issues/15#issuecomment-640088527
https://minikube.sigs.k8s.io/docs/drivers/kvm2/#installing-prerequisites
https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-virtualization/#installing-virtualization-software
https://github.com/aerokube/windows-images#system-requirements


## 

Many commands to check/help to troubleshoot:
```bash

# nix show-config
nix show-config | rg flakes
nix show-config | rg ca-references
nix show-config | rg ca-derivations

nix show-config | rg benchmark
nix show-config | rg big-parallel
nix show-config | rg kvm nixos-test

nix-store --verify --check-contents
# echo "$(nix-store --query --requisites "$(nix eval --raw github:ES-Nix/podman-rootless/from-nixpkgs)")" | grep shadow
# nix-store --verify-path $(nix-store --query --requisites $(which nix))
nix-store --verify-path $(nix-store --query --requisites $(which nix))
echo $(nix-store --query --requisites $(which nix)) | tr ' ' '\n'
nix-build '<nixpkgs>' --attr nix --check --keep-failed
nix-build '<nixpkgs>' --attr nixFlakes --check --keep-going

nix-build '<nixpkgs>' --attr commonsCompress --check --keep-failed
nix-build '<nixpkgs>' --attr gnutar --check --keep-failed
nix-build '<nixpkgs>' --attr lzma.bin --check --keep-failed
nix-build '<nixpkgs>' --attr git --check --keep-failed

nix-store --gc --print-roots
nix-store --gc --print-live
nix-store --gc --print-dead

nix-store --gc --print-roots
nix-store --gc --print-live
nix-store --gc --print-dead

nix-store --query --requisites $(which nix) | cat
nix-store --query --requisites --include-outputs $(which nix) | cat

nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which nix)) | cat
nix-store --query --graph --include-outputs $(nix-store --query --deriver $(which nix)) | dot -Tps > graph.ps


nix build nixpkgs#hello --no-link
nix-store --query --graph --include-outputs $(nix path-info --derivation nixpkgs#hello) | dot -Tps > graph.ps
```


```bash
nix build nixpkgs#awscli --no-link
nix-store --query --graph --include-outputs $(nix path-info nixpkgs#awscli) | dot -Tps > graph.ps
```


```bash
command -v jq || nix profile install nixpkgs/18de53ca965bd0678aaf09e5ce0daae05c58355a#jq
command -v dot || nix profile install nixpkgs/18de53ca965bd0678aaf09e5ce0daae05c58355a#graphviz

nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#pkgsStatic.hello --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#pkgsStatic.hello) \
| dot -Tps > graph.ps
```


```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Minimal --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Minimal) \
| dot -Tps > graph.ps
```



```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3 --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3) \
| dot -Tps > graph.ps
```


```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Full --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Full) \
| dot -Tps > graph.ps
```


```bash
nix build --impure github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#vscodium --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#vscodium) \
| dot -Tpdf > graph.pdf
```


```bash
nix build --impure github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#vscode --no-link

nix-store --query --graph --include-outputs \
$(nix path-info --impure github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#vscode) \
| dot -Tpdf > graph.pdf
```


```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#pkgsStatic.python3Minimal --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#pkgsStatic.python3Minimal) \
| dot -Tps > graph.ps
```
 

```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.numpy --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.numpy) \
| dot -Tps > graph.ps
```


```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.opencv3 --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.opencv3) \
| dot -Tpdf > graph.pdf
```


```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.opencv4 --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.opencv4) \
| dot -Tpdf > graph.pdf
```

```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.keras --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.keras) \
| dot -Tps > graph.ps
```

```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#gcc48 --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#gcc48) \
| dot -Tpdf > graph.pdf
```

```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.tensorflow --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#python3Packages.tensorflow) \
| dot -Tpdf > graph.pdf
```

```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#nixosTests.kubernetes.dns-single-node.driverInteractive --no-link

nix-store --query --graph \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#nixosTests.kubernetes.dns-single-node.driverInteractive) \
| dot -Tpdf > graph.pdf
```


```bash
nix build github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#podman-unwrapped --no-link

nix-store --query --graph --include-outputs \
$(nix path-info github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#podman-unwrapped) \
| dot -Tps > graph.ps
```
Refs.:
- https://github.com/NixOS/nix/issues/6142#issuecomment-1048538683



```bash
nix \
profile \
install \
nixpkgs/0571aa40532d78cc8c0793452f02ca60106d0d3#{coreutils,graphviz,hello,which,okular,python3Minimal}
```

```bash
echo $(nix-store --query --graph $(nix-store --query $(which python))) | dot -Tps > graph.ps \
&& sha256sum graph.ps
```

```bash
echo $(nix-store --query --graph $(nix-store --query $(which hello))) | dot -Tps > graph.ps \
&& sha256sum graph.ps
```

The correct one if you do not need legacy:
```bash
nix build nixpkgs#hello --print-out-paths
```

```bash
nix \
profile \
install \
nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#{coreutils,graphviz}
```


```bash
nix-store --query --graph --include-outputs \
$(
    nix \
    build \
    github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#hello \
    --print-out-paths
) | dot -Tps > hello.ps \
&& echo 73443914cae501b96145b6d96b5cc27377582900e5182cbd152f7dcab05265b8'  'hello.ps | sha256sum -c
```

```bash
nix-store --query --graph --include-outputs \
$(
    nix \
    build \
    --derivation \
    github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#python311 \
    --print-out-paths
) | dot -Tps > python311.ps \
&& echo e9191c6519bf9ac34feda13b5f11b2e5e39fa4872b3a30f98617a2695f836e18'  'python311.ps | sha256sum -c
```


```bash
nix-store --query --graph --include-outputs \
$(
    nix \
    build \
    --derivation \
    github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#python3Packages.geopandas \
    --print-out-paths
) | dot -Tps > geopandas.ps \
&& echo 260253c89cadbd72d662dfe5c34d8bee553bf3bd64dbdb5ca2b4677732ad4628'  'geopandas.ps | sha256sum -c
```

```bash
echo $(nix-store --query --graph $(nix-store --query $(nix eval --raw nixpkgs#hello.drvPath))) | dot -Tps > graph.ps \
&& sha256sum graph.ps
```


```bash
nix-store --query --graph --include-outputs \
$(
    nix \
    build \
    --derivation \
    github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#hello \
    --print-out-paths
) | dot -Tps > hello.ps \
&& echo 73443914cae501b96145b6d96b5cc27377582900e5182cbd152f7dcab05265b8'  'hello.ps | sha256sum -c
```

```bash
nix-store --query --graph --include-outputs \
$(
    nix \
    build \
    --impure \
    --print-out-paths \
    --expr \
    '
    (
      with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
      with legacyPackages.${builtins.currentSystem};
      with lib;
      gcc
    )
    '
) | dot -Tps > gcc.ps \
&& echo 
```

```bash
nix-store --query --graph --include-outputs \
$(
    nix \
    build \
    --derivation \
    --impure \
    --print-out-paths \
    --expr \
    '
    (
      with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
      with legacyPackages.${builtins.currentSystem};
      with lib;
      (gcc.overrideAttrs (oldAttrs: { propagetedBuildInputs = (oldAttrs.propagetedBuildInputs or []) ++ [hello]; }))
    )
    '
) | dot -Tps > gcc.ps \
&& echo 
```


```bash
FILE_NAME='graph.ps'

nix-store \
  --store https://cache.nixos.org/ \
  --query \
  --references $(nix eval --raw github:NixOS/nixpkgs/8c7576622aeb4707351a17e83429667f42e7d910#gcc) \
 | xargs nix-store --query --graph \
 | dot -Tps > "${FILE_NAME}"


EXPECTED_SHA256='c527370967bcd73d54d8004e53e143b3cd595a6f15c16eaec8cc9bc09c2db298'
EXPECTED_SHA512='8810404805850f06620a9cd7274ae4b7c6c7202312401f2e9d256d2b3c2eec9695baec75e47d4046d17a9a2e54de359398ceafdc61217cb59936b3699210f7d0'

 sha256sum "${FILE_NAME}"
 sha512sum "${FILE_NAME}"

echo "${EXPECTED_SHA256}"'  '"${FILE_NAME}" | sha256sum -c
echo "${EXPECTED_SHA512}"'  '"${FILE_NAME}" | sha512sum -c
```


```bash
FILE_NAME='graph.pdf'

command -v dot || nix profile install nixpkgs/18de53ca965bd0678aaf09e5ce0daae05c58355a#graphviz

nix-store \
  --store https://cache.nixos.org/ \
  --query \
  --references $(nix eval --raw github:NixOS/nixpkgs/18de53ca965bd0678aaf09e5ce0daae05c58355a#gcc) \
 | xargs nix-store --query --graph \
 | dot -Tpdf > "${FILE_NAME}"


EXPECTED_SHA256='c33dc3e3995010c7c9d899bf126f54728670e3042921383dea25876c34c6e042'
EXPECTED_SHA512='50fdbe25d531d9cf3899c7e1fa57dce43a2630fd43890322e6783817f7a5438ac1798f9a87d160953a9abc09fef6b560eea899551e3eeb432489002942555f2a'

# sha256sum "${FILE_NAME}"
# sha512sum "${FILE_NAME}"

echo "${EXPECTED_SHA256}"'  '"${FILE_NAME}" | sha256sum -c
echo "${EXPECTED_SHA512}"'  '"${FILE_NAME}" | sha512sum -c
```


```bash
nix \
shell \
nixpkgs#{coreutils,graphviz,hello,which} \
--command \
echo $(nix-store --query --graph $(nix-store --query $(which hello))) | dot -Tps > graph.ps 
```

```bash
nix \
shell \
nixpkgs#{coreutils,graphviz,which} \
--command \
echo $(nix-store --query --graph $(nix-store --query $(readlink -f $(which nix)))) | dot -Tps > graph.ps 
```

Broken:
```bash
echo $(nix-store --query --graph $(nix eval --raw github:NixOS/nix#nix-static))
```

```bash
echo $(nix-store --query --graph $(nix eval --raw github:NixOS/nix#nix-static)) | dot -Tpdf > nix-static.pdf
echo $(nix-store --query --graph $(nix eval --raw github:NixOS/nix#nix-static.drvPath)) | dot -Tpdf > nix-static-drvPath.pdf
```

```bash
nix path-info nixpkgs#hello
nix path-info --derivation nixpkgs#hello

nix path-info --derivation --json --recursive nixpkgs#hello | jq .

nix eval --raw nixpkgs#hello.drvPath
nix eval --raw nixpkgs#lib.version
nix eval nixpkgs#lib.fakeSha256

echo $(nix-store --query --graph $(nix eval --raw nixpkgs#hello.drvPath)) | dot -Tpdf > hello.pdf
```


```bash
nix show-derivation nixpkgs#hello


command -v jq || nix profile install nixpkgs#jq
nix show-derivation --recursive nixpkgs#pkgsStatic.hello \
| jq -r '.[] | select(.outputs.out.hash and .env.urls) | .env.urls' \
| uniq \
| sort
```

```bash
nix path-info -hS /run/current-system
```

```bash
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which nix)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which nixFlakes)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which commonsCompress)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which gnutar)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which lzma.bin)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which git)) | cat
```

TODO: https://github.com/NixOS/nix/issues/1918#issuecomment-444110195

https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-why-depends.html#examples

```bash
nix-store --query --requisites $(readlink -f $(which nix)) | cat
nix-store --query --requisites --include-outputs $(readlink -f $(which nix)) | cat

nix-store --query --requisites "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" | cat 
nix-store --query --referrers "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" | cat
 
nix-store --query --requisites --include-outputs "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" | cat 
nix-store --query --referrers --include-outputs "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" | cat
 
nix-store --query --deriver "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)"/bin/nix

nix-store --query --hash "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)"/bin/nix

nix-store --query --requisites --include-outputs "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" | xargs nix-store --query --hash 

nix-store --query --referrers-closure --include-outputs "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)" | wc -l
--referrers-closure
--use-output

nix-store --query --tree --include-outputs $(nix-store --query --deriver $(readlink -f  $(which nix))) | cat
nix-store --query --requisites --tree --include-outputs $(nix-store --query --deriver $(readlink -f  $(which nix))) | cat
nix-store --query --graph --include-outputs $(nix-store --query --deriver $(readlink -f $(which nix))) | dot -Tps > graph.ps

# Adapted from:
# https://github.com/NixOS/nix/issues/1245#issuecomment-726138112
nix-store --query --references $(nix eval --raw nixpkgs#hello.drvPath) \
 | xargs nix-store --realise \
 | xargs nix-store --query --requisites \
 | cat 
```

```bash
nix eval nix#checks --apply builtins.attrNames
nix eval nix#checks.x86_64-linux --apply builtins.attrNames
```

Needs `dot`, `jq`, `tr`, `wc`:
```bash
nix eval --raw /etc/nixos#nixosConfigurations."$(hostname)".config.system.build.toplevel
nix eval /etc/nixos#nixosConfigurations."$(hostname)".config.environment --apply builtins.attrNames | tr ' ' '\n'

nix-store --query --requisites --include-outputs $(nix eval --raw /etc/nixos#nixosConfigurations."$(hostname)".config.system.build.toplevel)
echo $(nix-store --query --requisites --include-outputs $(nix eval --raw /etc/nixos#nixosConfigurations."$(hostname)".config.system.build.toplevel)) | tr ' ' '\n' | wc -l
echo $(nix-store --query --graph --include-outputs $(nix eval --raw /etc/nixos#nixosConfigurations.pedroregispoar.config.system.build.toplevel)) | dot -Tpdf > system.pdf

nix-instantiate --strict "<nixpkgs/nixos>" -A system
nix-instantiate --strict --json --eval -E 'builtins.map (p: p.name) (import <nixpkgs/nixos> {}).config.environment.systemPackages' | jq -c | jq -r '.[]' | sort -u

nix eval --impure --expr 'with import <nixpkgs>{}; idea.pycharm-community.outPath'

nix build --impure --expr \
'with import <nixpkgs> {};
runCommand "foo" {
buildInputs = [ hello ];
}
"hello > $out"'

nix eval --impure --expr 'with import <nixpkgs/nixos>{}; /etc/nixos#nixosConfigurations."$(hostname)".config.environment.systemPackages.outPath'

nix eval --impure --json --expr 'builtins.map (p: p.name) (import <nixpkgs/nixos> {}).config.environment.systemPackages' | jq -c | jq -r '.[]' | sort -u

nix eval --raw nixpkgs#git.outPath; echo
nix realisation info nixpkgs#hello --json

nix eval --expr '(import <nixpkgs> {}).vscode.version'
nix eval --impure --expr '(import <nixpkgs> {}).vscode.version'
nix build --impure --expr '(import <nixpkgs> {}).vscode' 
nix build nixpkgs#vscode
 
export NIXPKGS_ALLOW_UNFREE=1 \
&& nix eval --impure --file '<nixpkgs>' 'vscode.outPath'

nix path-info -r /run/current-system

nix-store --query /run/current-system
nix-store --query --requisites /nix/var/nix/profiles/default
nix-store --query --requisites /run/current-system

nix profile list
# For NixOS systems:
nix profile list --profile /nix/var/nix/profiles/default
ls -al /nix/var/nix/profiles/default
ls -al ~/.nix-profile/bin/
ls -al /run/current-system/sw/bin/

nix profile install nixpkgs#hello
nix profile list --profile "${HOME}"/.nix-profile
nix profile list --profile /nix/var/nix/profiles/per-user/"$USER"/profile
nix profile remove "$(nix eval --raw nixpkgs#hello)"

# In NixOS
sudo nix profile install nixpkgs#hello --profile /nix/var/nix/profiles/default

# It only removed the hello package
sudo nix profile remove '.*' --profile /nix/var/nix/profiles/default
# Same for this other profile
# /nix/var/nix/profiles/per-user/root/channels

nix show-derivation -r "${HOME}"/.nix-profile
nix show-derivation -r /run/current-system
```
Refs.:
- https://search.nixos.org/options?channel=21.11&show=environment.systemPackages&from=0&size=50&sort=relevance&type=packages&query=environment.systemPackages
- https://www.reddit.com/r/NixOS/comments/fsummx/how_to_list_all_installed_packages_on_nixos/
- https://discourse.nixos.org/t/can-i-inspect-the-installed-versions-of-system-packages/2763/8
- https://functor.tokyo/blog/2018-02-20-show-packages-installed-on-nixos
- https://stackoverflow.com/a/46173041
- https://discourse.nixos.org/t/nix-eval-raw-nixos-package-outpath-prints-wrong-path/15103
- https://discourse.nixos.org/t/can-i-run-nix-instantiate-eval-strict-on-my-configuration-nix/7105/2
- https://nixos.org/manual/nix/unstable/command-ref/new-cli/nix3-realisation-info.html#examples
- https://discourse.nixos.org/t/eval-nix-expression-from-the-command-line/8993/2


```bash
nix why-depends --all --derivation nixpkgs#gcc nixpkgs#glibc | cat
nix why-depends --all --derivation nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes | cat
```

TODO: 
```bash
nix \
build \
nixpkgs#nix

nix \
path-info \
--human-readable \
--closure-size \
nixpkgs#nix
```

Really cool:
```bash
du --human-readable --summarize --total /nix
du --human-readable --summarize --total $(nix-store --query --requisites $(which nix)) | sort --human-numeric-sort
```

```bash
nix profile install nixpkgs#{file,ripgrep}
```

```bash
file /home/ubuntu/.nix-profile | rg 'broken' \
&& echo 'Broken symbolic link to profile' $(file /home/ubuntu/.nix-profile)
```
It can be a symbolic link broken!



## TMP, TMPDIR, XDG_RUNTIME_DIR


```bash
env | grep TMP
env | grep TMPDIR
env | grep XDG_RUNTIME_DIR
```

```bash
env | rg TMP
env | rg TMPDIR
env | rg XDG_RUNTIME_DIR
```


```bash
echo -e ${PATH//:/\\n}
echo "${PATH//:/$'\n'}"
mount | grep /run/user
```
From: https://unix.stackexchange.com/a/80153



```bash
df --print-type /tmp
```
From: https://unix.stackexchange.com/a/118476


```bash
df --human-readable --print-type "$TMPDIR"
```

```bash
mount | grep /run/user
```

https://unix.stackexchange.com/a/214386
https://superuser.com/a/542772

```bash
MKTEMP=$(mktemp --directory)
TMP={TMP:-"$MKTEMP"}
TMPDIR={TMPDIR:-"$MKTEMP"}
```

TODOs:
- https://github.com/NixOS/nixpkgs/issues/54707#issuecomment-522566108
- help in this: https://github.com/NixOS/nixpkgs/issues/31133
- https://www.reddit.com/r/NixOS/comments/g46m05/no_space_left_on_device_during_nixinstall/

Explanation: cd https://github.com/NixOS/nixpkgs/issues/34091#issuecomment-399680215


# Uninstalling nix


```bash
rm -rfv "$HOME"/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.cache/nix}
sudo rm -fr /nix
```
From: https://stackoverflow.com/questions/51929461/how-to-uninstall-nix#comment119190356_51935794, 
[Eelco in discourse.nixos](https://discourse.nixos.org/t/building-a-statically-linked-nix-for-hpc-environments/10865/18)



## The new CLI commands

[Missing 'nix' subcommands](https://github.com/NixOS/nix/issues/4429)

```bash
nix \
flake \
update \
--override-input nixpkgs
```

```bash
nix-store \
--gc \
--print-dead \
--option \
keep-derivations true
```

```bash
nix \
--experimental-features 'nix-command flakes ca-references ca-derivations' \
profile \
install \
nixpkgs#toybox

echo

nix \
--experimental-features 'nix-command flakes ca-references ca-derivations' \
profile \
remove \
$(nix eval --raw nixpkgs#toybox)
```

## chroot and others

[Local Nix without Root (HPC)](https://www.reddit.com/r/NixOS/comments/iod7wi/local_nix_without_root_hpc/)

```bash
nix diff-closures /nix/var/nix/profiles/system-655-link /nix/var/nix/profiles/system-658-link
```
From: [Add 'nix diff-closures' command](https://github.com/NixOS/nix/pull/3818). TODO: write it in an generic way, 
not hardcoding the profile number.


### nix statically built, WIP

It should be working, specially after nix 2.10.0+.
Take a look in:
- https://discourse.nixos.org/t/nix-2-10-0-released/20291

- See:
> `~/.local/share/nix/root`

May be?
> `~/.local/share/nix/someuser`


Things that may be automagically solved by not using the store in `/nix/store`:
- https://discourse.nixos.org/t/nix-var-nix-opt-nix-usr-local-nix/7101/66


#### Install nix statically built



```bash
test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix
```

```bash
SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"${SHA256}"/nix-static.sh | sh \
&& . ~/.profile \
&& nix flake --version \
&& nix flake metadata nixpkgs \
&& nix store gc --verbose
```



```bash
mkdir -pv "${HOME}"/.nix-profile
mkdir -pv "${HOME}"/nix/var/nix/profiles/per-user/"${USER}"/profile
ln -sfv "${HOME}"/.nix-profile "${HOME}"/nix/var/nix/profiles/per-user/"${USER}"/profile
```





```bash
test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix


mkdir -pv /nix/var/nix/profiles/per-user/vagrant/profile
ln -fsv /nix/var/nix/profiles/per-user/vagrant/profile $HOME/.nix-profile

# 183832936
# 184221926
# 
BUILD_ID='183946375'
curl -L https://hydra.nixos.org/build/"${BUILD_ID}"/download/1/nix > nix \
&& chmod +x nix \
&& ./nix --extra-experimental-features 'nix-command flakes' run nixpkgs#python3 -- --version 

ls -al /nix/store

./nix --extra-experimental-features 'nix-command flakes' run nixpkgs#podman images 

echo $USER:10000000:65536 | sudo tee -a /etc/subuid -a /etc/subgid
```

```bash
nix run nixpkgs#qemu -- --version

# ./nix --extra-experimental-features 'nix-command flakes' profile install nixpkgs#hello 

# ./nix --extra-experimental-features 'nix-command flakes' develop github:ES-Nix/fhs-environment/enter-fhs
```


```bash
sudo useradd -s '/bin/bash' -m evauser
sudo groupadd evagroup
sudo usermod -aG evagroup evauser

sudo passwd evauser

sudo nano /etc/sudoers
evauser ALL = ALL, !/usr/bin/sudo

sudo su evauser
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
```

```bash
sudo groupadd evagroup \
&& sudo useradd -g evagroup -s /bin/bash -m -c "Eva User" evauser \
&& echo "nixuser:123" | sudo chpasswd
```

```bash
nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/01b8587401f41aecd4b77aa9698c0cba65a38882
```


```bash
podman run --rm -it -u 1005 alpine
apk add --no-cache curl tar

xhost +
podman \
run \
--env="DISPLAY=${DISPLAY:-:0}" \
--interactive=true \
--tty=true \
--rm=true \
--workdir=/code \
--volume="$(pwd)":/code \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
python:3.9 \
bash \
-c \
"id && echo \$DISPLAY && python -c 'from tkinter import Tk; Tk()'"



podman \
build \
--tag test-with-sudo-nix-single-user-installer \
--file src/pkgs/oci-test-nix-single-user-installer/Containerfile \
--target=ubuntu-sudo-and-nix-install-deps .

podman \
build \
--tag test-nix-single-user-installer \
--file src/pkgs/oci-test-nix-single-user-installer/Containerfile \
--target=ubuntu-and-nix-install-deps .

podman \
run \
--privileged=true \
--rm=true \
--interactive=true \
--tty=true \
--user=$(id -u ${USER}):$(id -g ${USER}) \
localhost/test-nix-single-user-installer:0.0.1 \
bash

podman \
run \
--privileged=true \
--rm=true \
--interactive=true \
--tty=true \
--user=$(id -u ${USER}):$(id -g ${USER}) \
localhost/test-with-sudo-nix-single-user-installer:latest \
bash 
```

```bash
  --qemu-commandline QEMU_COMMANDLINE
                        Pass arguments directly to the QEMU emulator. Ex:
                        --qemu-commandline='-display gtk,gl=on'
                        --qemu-commandline env=DISPLAY=:0.1
```
From:
- virt-install --help | rg DISPLAY -B3
- virt-install --version == 4.0.0


##### build-vm, qemu-vm, pkgsStatic.nix, ssh, X11


```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519

export NIXPKGS_ALLOW_UNFREE=1

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        # system = "aarch64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
                  bpytop
                  firefox
                  vscode
                  (python3.buildEnv.override
                    {
                      extraLibs = with python3Packages; [ scikitimage opencv2 numpy ];
                    }
                  )
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;

              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];

              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"ls -al /nix/store\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 3072; # Use MiB memory.
                diskSize = 4096; # Use MiB memory.
                cores = 3;         # Simulate 3 cores.
                #
                docker.enable = true;
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = pkgsStatic.nix;
                # package = pkgsCross.aarch64-multiplatform-musl.pkgsStatic.nix;
                extraOptions = "experimental-features = nix-command flakes repl-flake";
                readOnlyStore = false;
              };
              boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

              # Enable the X11 windowing system.
              services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };
              programs.ssh.forwardX11 = true;
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              time.timeZone = "America/Recife";

              environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
              environment.etc."containers/registries.conf" = {
                mode = "0644";
                text = "[registries.search] \n registries = [\"docker.io\", \"localhost\"]";
              };

              # Is this ok to kubernetes? Why free -h still show swap stuff but with 0?
              swapDevices = pkgs.lib.mkForce [ ];

            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
#<<COMMANDS
#id
#COMMANDS
#"$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```

```bash
file $(readlink -f $(which hello))
file $(readlink -f $(which nix))
du -hs $(readlink -f $(which nix))
```



###### ARM

```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        # system = "x86_64-linux";
        system = "aarch64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyAMA0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  # pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
                  # pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
                  firefox
                  (python3.buildEnv.override
                    {
                      extraLibs = with python3Packages; [ scikitimage opencv2 numpy ];
                    }
                  )
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;

              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];

              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"ls -al /nix/store\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 3072; # Use MiB memory.
                diskSize = 4096; # Use MiB memory.
                cores = 3;         # Simulate 3 cores.
                #
                docker.enable = true;
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = pkgsStatic.nix;
                # package = pkgsCross.aarch64-multiplatform-musl.pkgsStatic.nix;
                extraOptions = "experimental-features = nix-command flakes repl-flake";
                readOnlyStore = false;
              };
              # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
              # boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

              # Enable the X11 windowing system.
              services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };
              programs.ssh.forwardX11 = true;
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              time.timeZone = "America/Recife";

              environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
              environment.etc."containers/registries.conf" = {
                mode = "0644";
                text = "[registries.search] \n registries = [\"docker.io\", \"localhost\"]";
              };

              # Is this ok to kubernetes? Why free -h still show swap stuff but with 0?
              swapDevices = pkgs.lib.mkForce [ ];

            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-tt \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
#<<COMMANDS
#id
#COMMANDS
#"$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```


#### Other similar projects

- https://github.com/DavHau/nix-portable


#### Part 1:

```bash
IMAGE_NAME='unprivileged-ubuntu22'
CONTAINER_NAME='container'"${IMAGE_NAME}"'-test-nix'
podman rm --force --ignore "${CONTAINER_NAME}"

podman \
run \
--name="${CONTAINER_NAME}" \
--detach=false \
--privileged=true \
--rm=false \
--interactive=true \
--tty=true \
docker.io/library/ubuntu:22.04 \
bash \
-c \
"
echo 'Creating user' \
&& groupadd evagroup \
&& useradd -g evagroup -s /bin/bash -m -c 'Eva User' evauser \
&& echo 'evauser:123' | chpasswd \
&& echo 'Start apt-get stuff' \
&& apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates \
     curl \
     tar \
     podman \
     xz-utils \
&& apt-get -y autoremove \
&& apt-get -y clean \
&& rm -rf /var/lib/apt/lists/*

echo evauser:10000:5000 > /etc/subuid
echo evauser:10000:5000 > /etc/subgid

mkdir -m 0755 /nix && chown evauser /nix
" \
podman commit -q "${CONTAINER_NAME}" "${IMAGE_NAME}" \
&& podman images \
&& podman rm --force --ignore "${CONTAINER_NAME}"
```

#### Part 2: 

```bash
IMAGE_NAME='unprivileged-ubuntu22'
CONTAINER_NAME='container'"${IMAGE_NAME}"'-test-nix'

podman \
run \
--env="USER=evauser" \
--name="${CONTAINER_NAME}" \
--rm=true \
--privileged=true \
--interactive=true \
--tty=true \
--user=evauser \
--workdir=/home/evauser \
localhost/"${IMAGE_NAME}" \
bash
```

```bash
IMAGE_NAME='unprivileged-ubuntu22'
CONTAINER_NAME='container'"${IMAGE_NAME}"'-test-nix'

podman rm --force --ignore "${CONTAINER_NAME}"

podman \
run \
--name="${CONTAINER_NAME}" \
--detach=false \
--privileged=true \
--rm=false \
--interactive=true \
--tty=true \
docker.io/library/ubuntu:22.04 \
bash \
-c \
"
echo 'Start apt-get stuff' \
&& apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates \
     curl \
     tar \
     xz-utils \
     sudo libpcap-dev \
&& apt-get -y autoremove \
&& apt-get -y clean \
&& rm -rf /var/lib/apt/lists/* \
&& echo 'Creating user' \
&& groupadd evagroup \
&& useradd -g evagroup -s /bin/bash -m -c 'Eva User' evauser \
&& echo 'evauser:123' | chpasswd \
&& echo 'evauser ALL=(ALL) NOPASSWD:SETENV: ALL' > /etc/sudoers.d/evauser \
&& echo '###'                                                                                                                         


echo evauser:10000:5000 > /etc/subuid
echo evauser:10000:5000 > /etc/subgid

mkdir -m 0755 /nix && chown evauser /nix
" \
podman commit -q "${CONTAINER_NAME}" "${IMAGE_NAME}" \
&& podman images \
&& podman rm --force --ignore "${CONTAINER_NAME}"
```

```bash
podman \
run \
--device=/dev/fuse \
--env="USER=evauser" \
--interactive=true \
--mount=type=tmpfs,tmpfs-size=6000M,destination=/var/tmp \
--mount=type=tmpfs,tmpfs-size=10000M,destination=/home/evauser/.local/share/containers/storage \
--name="${CONTAINER_NAME}" \
--privileged=true \
--rm=true \
--security-opt="label=disable" \
--tty=true \
--user=evauser \
--workdir=/home/evauser \
"${IMAGE_NAME}" \
bash \
-c \
'
test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix \
&& BASE_URL="https://raw.githubusercontent.com/ES-Nix/get-nix/" \
&& SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& NIX_RELEASE_VERSION="2.10.2" \
&& curl -fsSL "${BASE_URL}""$SHA256"/get-nix.sh | sh -s -- ${NIX_RELEASE_VERSION} \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& nix flake --version

nix \
profile \
install \
github:ES-Nix/podman-rootless/from-nixpkgs#podman


# Some fixes                                        
sudo mount -o remount,shared / / \
&& nix profile install nixpkgs#libcap \
&& P_SETPATH="$(nix eval --raw nixpkgs#libcap)"/bin/setcap \
&& echo "${P_SETPATH}" \
&& ls -la /nix/store/*-shadow-4.11.1/bin/newuidmap \
&& echo \
&& sudo env "PATH=$PATH" "USER=$USER" "P_SETPATH=$P_SETPATH" "${P_SETPATH}" "cap_setuid=+ep" /nix/store/*-shadow-4.11.1/bin/newuidmap \
&& sudo env "PATH=$PATH" "USER=$USER" "P_SETPATH=$P_SETPATH" "${P_SETPATH}" "cap_setgid=+ep" /nix/store/*-shadow-4.11.1/bin/newgidmap
podman images
podman images
podman run -it --rm ubuntu bash -c "apt-get update"
'
```


#### Alpine


##### Part 1:

```bash
cat > Containerfile << 'EOF'
FROM alpine:3.16.1
RUN apk add --no-cache \
     ca-certificates \
     curl \
     shadow \
     tar \
     xz \
 && echo 'Creating user' \
 && groupadd abcgroup \
 && useradd -g abcgroup -s /bin/sh -m -c 'Eva User' abcuser \
 && echo 'abcuser:123' | chpasswd \
 && echo abcuser:10000:5000 > /etc/subuid \
 && echo abcuser:10000:5000 > /etc/subgid \
 && mkdir -m 0755 /nix && chown abcuser /nix

USER abcuser
WORKDIR /home/abcuser
ENV USER="abcuser"
ENV PATH=/home/abcuser/.nix-profile/bin:/home/abcuser/.local/bin:"$PATH"

EOF

podman \
build \
--file=Containerfile \
--tag=unprivileged-alpine3161 .
```

```bash
nix run nixpkgs#xorg.xhost -- +
podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/unprivileged-alpine3161:latest \
sh
nix run nixpkgs#xorg.xhost -- -
```


```bash
nix run nixpkgs#xorg.xhost -- +
podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/unprivileged-alpine3161:latest \
sh
nix run nixpkgs#xorg.xhost -- -
```


```bash
nix run nixpkgs#xorg.xhost -- +
podman \
run \
--detach=true \
--device=/dev/fuse:rw \
--device=/dev/kvm:rw \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=false \
--name=conteiner-alpine \
--privileged=true \
--rm=false \
--tty=true \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/unprivileged-alpine3161:latest \
sh
nix run nixpkgs#xorg.xhost -- -
```


```bash
podman \
exec \
--interactive=true \
--tty=true \
conteiner-alpine sh
```

```bash
podman rm -f conteiner-alpine
```



```bash
poetry config virtualenvs.in-project true \
&& poetry config virtualenvs.path . \
&& poetry install
```

##### Part 2:

```bash
BASE_IMAGE_NAME_AND_TAG='alpine:3.16.1'
IMAGE_NAME='unprivileged-''alpine3161'
CONTAINER_NAME='container'"${IMAGE_NAME}"'-test-nix'
podman rm --force --ignore "${CONTAINER_NAME}"

podman \
run \
--env="USER=evauser" \
--name="${CONTAINER_NAME}" \
--rm=true \
--privileged=true \
--interactive=true \
--tty=true \
--user=evauser \
--workdir=/home/evauser \
localhost/"${IMAGE_NAME}" \
sh
```


##### unprivileged


```bash
cat > Containerfile << 'EOF'
FROM ubuntu:22.04
RUN apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates \
     curl \
     tar \
     xz-utils \
     libpcap-dev \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
     
RUN adduser user --home /home/user --disabled-password --gecos "" --shell /bin/bash

# RUN mkdir /nix && chmod a+rwx /nix && chown -v user: /nix
USER user
ENV USER user
WORKDIR /home/user

# RUN curl https://nixos.org/nix/install | sh

# RUN nix --version
EOF

podman \
build \
--file=Containerfile \
--tag=unprivileged-ubuntu22 .

podman \
run \
--privileged=true \
-it \
--rm \
localhost/unprivileged-ubuntu22:latest \
bash \
-c \
'
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon \
&& . /home/user/.nix-profile/etc/profile.d/nix.sh \
&& nix --option extra-experimental-features "nix-command flakes" profile install nixpkgs#hello \
&& hello
'

podman run --privileged=true -it --rm localhost/unprivileged-ubuntu22:latest
```



```bash
cat > Containerfile << 'EOF'
FROM ubuntu:22.04
RUN apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates \
     curl \
     tar \
     xz-utils \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
RUN addgroup abcgroup --gid 4455  \
 && adduser -q \
     --gecos '"An unprivileged user with an group"' \
     --disabled-password \
     --ingroup abcgroup \
     --uid 3322 \
     abcuser

# Uncomment that to compare
# RUN mkdir /nix && chmod 0755 /nix && chown -v abcuser: /nix
USER abcuser
WORKDIR /home/abcuser
ENV USER="abcuser"
EOF

podman \
build \
--file=Containerfile \
--tag=unprivileged-ubuntu22 .


podman \
run \
--privileged=true \
--interactive=true \
--tty=true \
--rm=true \
localhost/unprivileged-ubuntu22:latest \
bash \
-c \
'
curl -L https://releases.nixos.org/nix/nix-2.10.3/install | sh -s -- --no-daemon \
&& . /home/abcuser/.nix-profile/etc/profile.d/nix.sh \
&& nix --option extra-experimental-features "nix-command flakes" profile install nixpkgs#hello \
&& hello
'

podman \
run \
--privileged=true \
--interactive=true \
--tty=true \
--rm=true \
localhost/unprivileged-ubuntu22:latest \
bash \
-c \
'
mkdir -pv "$HOME"/.local/bin \
&& export PATH="$HOME"/.local/bin:"$PATH" \
&& curl -L https://hydra.nixos.org/build/188965270/download/2/nix > nix \
&& mv nix "$HOME"/.local/bin \
&& chmod +x "$HOME"/.local/bin/nix
# Works!
nix --option extra-experimental-features "nix-command flakes" run nixpkgs#hello
# Works!
nix --option extra-experimental-features "nix-command flakes" \
build nixpkgs#nixosTests.kubernetes.rbac-single-node.driverInteractive
# Broken
nix --option extra-experimental-features "nix-command flakes" profile install nixpkgs#hello
'

# To play interactive
podman \
run \
--privileged=true \
--interactive=true \
--tty=true \
--rm=true \
localhost/unprivileged-ubuntu22:latest
```


```bash
cat > Containerfile << 'EOF'
FROM ubuntu:22.04

RUN apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates \
     curl \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

RUN addgroup abcgroup --gid 4455  \
 && adduser -q \
     --gecos '"An unprivileged user with an group"' \
     --disabled-password \
     --ingroup abcgroup \
     --uid 3322 \
     abcuser

USER abcuser
WORKDIR /home/abcuser
ENV USER="abcuser"
ENV PATH=/home/abcuser/.local/bin:"$PATH"

# Not DRY, I know
RUN mkdir -pv /home/abcuser/.local/bin \
 && export PATH=/home/abcuser/.local/bin:"$PATH" \
 && curl -L https://hydra.nixos.org/build/188965270/download/2/nix > nix \
 && mv nix /home/abcuser/.local/bin \
 && chmod +x /home/abcuser/.local/bin/nix \
 && mkdir -p ~/.config/nix \
 && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
EOF


podman \
build \
--file=Containerfile \
--tag=unprivileged-ubuntu22 .


podman \
run \
--privileged=true \
--interactive=true \
--tty=true \
--rm=true \
localhost/unprivileged-ubuntu22:latest \
bash \
-c \
'
# Broken
nix profile install nixpkgs#hello
'
```



#### Testing the installer

```bash
curl -L https://nixos.org/nix/install | sh -s -- --no-daemon
```


```bash
# https://hydra.nixos.org/project/nix
BUILD_ID='185724653'
curl -L https://hydra.nixos.org/build/"${BUILD_ID}"/download/1/nix > nix
chmod +x nix

# mkdir -pv /home/"${USER}"/.local/share/nix/root/nix/var/nix/profiles/per-user/"${USER}"
# ln -sfv /home/"${USER}"/.local/share/nix/root/nix/var/nix/profiles/per-user/abcuser/profile "${HOME}"/.nix-profile
```

```bash
./nix --extra-experimental-features 'nix-command flakes' profile install nixpkgs#hello
```


```bash
podman rm --force "${CONTAINER_NAME}"
```


```bash
# Just because it has the user named podman
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
--user=podman \
--workdir=/home/podman \
quay.io/podman/stable

# --volume=/nix/store:/home/podman/.local/share/nix/root:ro \
```

```bash
mkdir -pv "$HOME"/.local/bin \
&& export PATH="$HOME"/.local/bin:"$PATH" \
&& curl -L https://hydra.nixos.org/build/207340490/download/1/nix > nix \
&& mv nix "$HOME"/.local/bin \
&& chmod +x "$HOME"/.local/bin/nix \
&& mkdir -p "$HOME"/.config/nix \
&& echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf
```


```bash
nix \
build \
--experimental-features 'nix-command flakes' \
--no-sandbox \
--cores 0 \
-j auto \
--impure \
--expr \
'
(builtins.getFlake "github:NixOS/nixpkgs").legacyPackages.x86_64-linux.nixFlakes.override 
{ 
  storeDir = builtins.getEnv "NIX_STORE_DIR";
  stateDir = builtins.getEnv "NIX_STATE_DIR";
  confDir = builtins.getEnv "NIX_CONF_DIR";
}
'
```
Refs.:
- https://gist.github.com/NickCao/0b938bd476e0bc2439e66663529d59bc



```bash
TARGET_HOME=/home/podman
BUILD_HOME=/home/podman

NIX_REMOTE=local?root=$BUILD_HOME/rootfs/ \
	NIX_CONF_DIR=$BUILD_HOME/nix/etc \
	NIX_LOG_DIR=$BUILD_HOME/nix/var/log/nix \
	NIX_STORE=$BUILD_HOME/nix/store \
	NIX_STATE_DIR=$BUILD_HOME/nix/var \
	nix \
	build \
	--impure \
	--expr \ 
	'
	  with import <nixpkgs> {}; 
	  nix.override { storeDir = "'$TARGET_HOME'/nix/store"; stateDir = "'$TARGET_HOME'/nix/var"; confDir = "'$TARGET_HOME'/nix/etc"; }
	'

```
Refs.:
- https://gist.github.com/infinisil/1111bdfc548d41be744ca9a5d1fe2837



About:
```bash
$ENV{'NIX_REMOTE'} = "local?store=$nix_store_dir&state=$nix_state_dir&log=$nix_log_dir";
$ENV{'NIX_STATE_DIR'} = $nix_state_dir; # FIXME: remove
$ENV{'NIX_STORE_DIR'} = $nix_store_dir; # FIXME: remove
```
Refs.:
- https://github.com/NixOS/hydra/pull/1237



```bash
nix \
profile \
install \
nixpkgs#hello \
nixpkgs#lolcat \
nixpkgs#figlet \
nixpkgs#cowsay \
nixpkgs#ponysay \
nixpkgs#cmatrix
```



```bash
nix \
run \
nixpkgs#pkgsStatic.nix \
-- \
    --store "${HOME}" \
    profile \
    install \
    --profile "${HOME}"/.nix-profile \
    nixpkgs#gcc
```

```bash
CONTAINER_NAME='container-test-nix'
IMAGE_NAME='image-test-nix'

podman \
exec \
--interactive=true \
--tty=false \
"${CONTAINER_NAME}" \
bash \
<<COMMANDS
ls -la
COMMANDS
```


#### tests for the nix statically built




```bash
EXPECTED_SHA512SUM='42cf60ebf5b547df476c7b4f9807785b32540f3c6a4777a902148b2e4d09b02aa137be6c813afeab2722892444b28b88c5b4032cd82664bfc1920ccda58f1afb'

nix \
shell \
--store "${HOME}" \
nixpkgs#bashInteractive \
nixpkgs#uutils-coreutils \
--command \
bash \
-c \
"echo "${EXPECTED_SHA512SUM}"'  '"$HOME"/.local/bin/nix | sha512sum -c"
```


```bash
nix \
run \
nixpkgs#hello
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  flake \
  --version
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  run \
  --store "${HOME}" \
  nixpkgs#pkgsStatic.hello
```

```bash
nix \
build \
--store "${HOME}" \
nixpkgs#pkgsCross.s390x.pkgsStatic.busybox-sandbox-shell \
--option sandbox true
```


```bash
./nix \
--extra-experimental-features 'nix-command flakes' \
run \
nixpkgs#pkgsStatic.nix \
-- \
  --extra-experimental-features 'nix-command flakes' \
  build \
  nixpkgs#pkgsCross.s390x.pkgsStatic.busybox-sandbox-shell \
  --option substitute true \
  --option sandbox false
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  build \
  --store "${HOME}" \
  nixpkgs#pkgsCross.s390x.pkgsStatic.busybox-sandbox-shell \
  --option substitute true \
  --option sandbox false
```

```bash
./nix \
--extra-experimental-features 'nix-command flakes' \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}.pkgsCross.aarch64-multiplatform.pkgsStatic;
  (shadow.override { pam = null; }).su
)'
```

```bash
nix \
build \
--store "${HOME}" \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}.pkgsCross.aarch64-multiplatform.pkgsStatic;
  (shadow.override { pam = null; }).su
)'
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  build \
  --store "${HOME}" \
  --impure \
  --expr \
  '(
    with builtins.getFlake "nixpkgs"; 
    with legacyPackages.${builtins.currentSystem}.pkgsCross.aarch64-multiplatform.pkgsStatic;
    (shadow.override { pam = null; }).su
  )'
```


```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
```

In:
```bash
file result/bin/hello
```

Out:
```bash
result/bin/hello: ELF 64-bit LSB executable, ARM aarch64, version 1 (SYSV), statically linked, not stripped
```


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-cross";
      nodes = {
        machine = { config, pkgs, ... }: {
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          environment.systemPackages = [
            pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
          ];
        };
      };

      testScript = ''
        "machine.succeed(\"hello\")"
      '';
    })
)
'
```


```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform-musl.pkgsStatic.python310Packages.rsa
```




```bash
nix \
build \
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
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-pottery";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            (python3.buildEnv.override
              {
                extraLibs = with python3Packages; [ 
                  (
                    let
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
                  ];
                }
              )
          ];
        };
      };

      testScript = ''
        "machine.succeed(\"python\")"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-cross-python3-isort";
      nodes = {
        machine = { config, pkgs, ... }: {
          boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
          environment.systemPackages = [
              (pkgsCross.aarch64-multiplatform-musl.python3.buildEnv.override
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
'
```

#### Nesting


```bash
nix \
run \
nixpkgs#pkgsStatic.nix \
-- \
  flake \
  --version
```

Nesting (broken):
```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
  -- \
  run \
  --store "${HOME}" \
  nixpkgs#pkgsStatic.nix \
    -- \
    run \
    --store "${HOME}" \
    nixpkgs#pkgsStatic.nix \
      -- \
      --version
```


```bash
error: setting up a private mount namespace: Operation not permitted
```


```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
shell \
--store "${HOME}" \
--impure \
--expr \
'
(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem};
  (gnused.overrideDerivation (oldAttrs: {
        name = "sed-4.2.2-pre";
        src = fetchurl {
          url = ftp://alpha.gnu.org/gnu/sed/sed-4.2.2-pre.tar.bz2;
          sha256 = "11nq06d131y4wmf3drm0yk502d2xc6n5qy82cg88rb9nqd2lj41k";
        };
        patches = [];
      }
    )
  )
)
' \
--command \
bash \
-c \
'sed --version && which sed'
```




```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
  -- \
  develop \
  --store "${HOME}" \
  github:ES-Nix/fhs-environment/enter-fhs
```



#### Why this error? 

```bash
error: executing '/nix/store/scysmz0g4177wm01aa2xjlr0jcvv0wk0-nix-2.9.1-x86_64-unknown-linux-musl/libexec/nix/build-remote': No such file or directory
error: unexpected EOF reading a line

       … while reading the response from the build hook
```

```bash
nix \
build \
--store "${HOME}" \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem};
  (sudo.override { pam = null; withInsults = true; })
)'
```

```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
/nix/store/scysmz0g4177wm01aa2xjlr0jcvv0wk0-nix-2.9.1-x86_64-unknown-linux-musl/libexec/nix/build-remote
```

```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
/nix/store/scysmz0g4177wm01aa2xjlr0jcvv0wk0-nix-2.9.1-x86_64-unknown-linux-musl/libexec/nix/build-remote
```



```bash
nix \
run \
nixpkgs#pkgsStatic.nix \
-- \
develop \
github:ES-Nix/fhs-environment/enter-fhs
```


```bash
nix \
run \
nixpkgs#pkgsStatic.nix \
-- \
profile \
install \
--refresh \
github:ES-Nix/podman-rootless/from-nixpkgs#podman
```

Works:
```bash
nix \
run \
nixpkgs#pkgsStatic.nix \
-- \
  run \
  github:ES-Nix/podman-rootless/from-nixpkgs#podman \
  -- \
    run \
    --rm=true \
    docker.io/library/alpine:3.14.2 \
    sh \
    -c \
    "
      cat /etc/os-release \
      && apk update \
      && apk add --no-cache python3 \
      && python3 --version
    "
```


```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  run \
  --store "${HOME}" \
  github:ES-Nix/podman-rootless/from-nixpkgs#podman \
  -- \
    run \
    --rm=true \
    docker.io/library/alpine:3.14.2 \
    sh \
    -c \
    "
      cat /etc/os-release \
      && apk update \
      && apk add --no-cache python3 \
      && python3 --version
    "
```


```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  build \
  --store "${HOME}" \
  github:ES-Nix/poetry2nix-examples/2cb6663e145bbf8bf270f2f45c869d69c657fef2#poetry2nixOCIImage
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  build \
  --store "${HOME}" \
  --impure \
  --expr \
  '(                                                                                     
    (
      (
        builtins.getFlake "github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c"
      ).lib.nixosSystem {
          system = "${builtins.currentSystem}";
          modules = [ "${toString (builtins.getFlake "github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
      }
    ).config.system.build.isoImage
  )
  '

EXPECTED_SHA256='ed705ad772e8a616d58c11447787d68d9ba867d8589dc698021af0da0daf9395' \
&& EXPECTED_SHA512='736f8f29e457cb00038c64147f063f95eeb35aa709daeff2e620e74366887cf1e3184654bdcce8afcb7ee9d625b4c661940580cb5ab59bb88cffd9f9b6946ad1' \
&& ISO_PATTERN_NAME="$(echo "${HOME}""$(readlink result)"/iso/nixos-22.05.*.*-x86_64-linux.iso)"

# sha256sum "${ISO_PATTERN_NAME}"
# sha512sum "${ISO_PATTERN_NAME}"

echo "${EXPECTED_SHA256}"'  '"${ISO_PATTERN_NAME}" | sha256sum -c
echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c
```


```bash
nix --store "$HOME" flake metadata nixpkgs \
&& nix --store "$HOME"/store store gc --verbose
```

```bash
nix \
profile \
install \
--store "$HOME" \
nixpkgs#hello
```

```bash
nix \
shell \
--store "$HOME" \
nixpkgs#hello \
--command \
hello
```

```bash
nix \
shell \
--store "$HOME" \
nixpkgs#podman \
--command \
podman \
--version
```


TODO: with some flakes I got this same error 
https://github.com/NixOS/nix/issues/2794

```bash
ls -al $(readlink -f "$HOME"/.nix-profile)
```

```bash
nix \
flake \
show \
--store "$HOME" \
github:GNU-ES/hello
```

```bash
nix \
shell \
--store "$HOME" \
github:GNU-ES/hello \
--command \
hello
```


```bash
nix \
build \
--store "$HOME" \
github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp
```

`[0/1 built] Real-time signal 0` why?

https://stackoverflow.com/questions/6345973/who-uses-posix-realtime-signals-and-why

strings $HOME/bin/nix | grep Real

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
build \
--store "${HOME}" \
github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp
```


```bash
nix-build -A pkgsStatic.nix
From: https://github.com/NixOS/nixpkgs/pull/56281
```

`--with-store-dir=path`
From: https://stackoverflow.com/a/37231726

`--with-store-dir` in the nix derivation https://github.com/NixOS/nixpkgs/blob/a3f85aedb1d66266b82d9f8c0a80457b4db5850c/pkgs/tools/package-management/nix/default.nix#L124


TODO: make tests for this in QEMU
https://github.com/NixOS/nixpkgs/pull/56281#issuecomment-484242510

```bash
t=$(mktemp -d) \
&& curl https://matthewbauer.us/nix > $t/nix.sh \
&& (cd $t && bash nix.sh --extract) \
&& mkdir -p $HOME/bin/ $HOME/share/nix/corepkgs/ \
&& mv $t/dat/nix-x86_64 $HOME/bin/nix \
&& mv $t/dat/share/nix/corepkgs/* $HOME/share/nix/corepkgs/ \
&& echo export 'PATH=$HOME/bin:$PATH' >> $HOME/.profile \
&& echo export 'NIX_DATA_DIR=$HOME/share' >> $HOME/.profile \
&& source $HOME/.profile \
&& rm -rf $t
```

TODO: it is probably going to be usefull
https://github.com/NixOS/nixpkgs/pull/56281#issuecomment-466804361

TODO: test it :/ 
[Nix-anywhere: run nix-shell script in nix-user-chroot](https://discourse.nixos.org/t/nix-anywhere-run-nix-shell-script-in-nix-user-chroot/2594)


TODO: test it :]
[Nix without (p)root: error getting status of `/nix`](https://discourse.nixos.org/t/nix-without-p-root-error-getting-status-of-nix/9858)

TODO: try it
https://github.com/freuk/awesome-nix-hpc

TODO:
Matthew shows how using statically linked Nix in a 5MB binary, one can use Nix without root. 
With an one-liner shell, you can use Nix to install any software on a Linux machine.
[Static Nix: a command-line swiss army knife](https://matthewbauer.us/blog/static-nix.html)


TODO: [Packaging with Nix](https://www.youtube.com/embed/Ndn5xM1FgrY?start=329&end=439&version=3), start=329&end=439

[Nix Portable: Nix - Static, Permissionless, Install-free, Pre-configured](https://discourse.nixos.org/t/nix-portable-nix-static-permissionless-install-free-pre-configured/11719)

https://support.glitch.com/t/install-prebuilt-packages-without-root-from-nixpkgs/43775


> Oh yeah, chroot stores won’t work on macOS. Neither will proot. Having a flat-file binary cache in the shared dir
> and copying to/from that will be your only option there.
[How to use a local directory as a nix binary cache?](https://discourse.nixos.org/t/how-to-use-a-local-directory-as-a-nix-binary-cache/655/14)


In this [issue comment](https://github.com/NixOS/nixpkgs/pull/70024#issuecomment-717568914)
[see too](https://matthewbauer.us/blog/static-nix.html).

```bash
nix build nixpkgs#nix

nix build github:NixOS/nix#nix-static
nix build github:NixOS/nix/9feca5cdf64b82bfb06dfda07d19d007a2dfa1c1#nix-static

nix build nixpkgs#pkgsStatic.nix
```


```bash
nix build nixpkgs#pkgsStatic.hello
nix path-info -rsSh nixpkgs#pkgsStatic.hello
```

```bash
nix build nixpkgs#pkgsStatic.toybox
nix path-info -rsSh nixpkgs#pkgsStatic.toybox
```

```bash
nix build nixpkgs#pkgsStatic.busybox
nix path-info -rsSh nixpkgs#pkgsStatic.busybox
```


```bash
nix build nixpkgs#pkgsStatic.redis
nix path-info -rsSh nixpkgs#pkgsStatic.redis
```


```bash
nix build nixpkgs#pkgsStatic.nix
nix path-info -rsSh nixpkgs#pkgsStatic.nix
```

```bash
nix build github:NixOS/nix#nix-static
nix path-info -rsSh github:NixOS/nix#nix-static
```

nix search nixpkgs ' sed'


nix path-info -r /nix/store/sb7nbfcc1ca6j0d0v18f7qzwlsyvi8fz-ocaml-4.10.0 --store https://cache.nixos.org/
nix path-info -r "$(nix eval --raw nixpkgs#hello)" --store https://cache.nixos.org/

nix store ls --store https://cache.nixos.org/ -lR /nix/store/0i2jd68mp5g6h2sa5k9c85rb80sn8hi9-hello-2.10

```bash
nix run github:NixOS/nixpkgs/release-20.03#ocaml -- --version
nix run github:NixOS/nixpkgs/release-21.11#ocaml -- --version
```

```bash
nix-build '<nixpkgs>' -A hello --arg crossSystem '{ config = "aarch64-unknown-linux-gnu"; }'
```



```bash
nix \
  profile \
  install \
  github:NixOS/nix#nix-static \
  --profile ~/.nix-static \
&& nix store gc --verbose \
&& mkdir --parent --mode=0755 ~/output/store \
&& cp \
   --no-dereference \
   --recursive \
   --verbose \
   $(nix-store --query --requisites ~/.nix-static) \
   ~/output/store \
&& export PATH="$(nix eval --raw github:NixOS/nix#nix-static)/bin":"$PATH" \
&& nix \
profile \
install \
--store "~" \
nixpkgs#hello
```

nix \
profile \
install \
--store "${HOME}" \
nixpkgs#hello


&& export PATH="$HOME":"$PATH" \

```bash
nix \
  build \
  github:NixOS/nix#nix-static \
&& cp "$(nix eval --raw github:NixOS/nix#nix-static)/bin/nix" "$HOME" \
&& nix \
profile \
install \
--store "$HOME" \
nixpkgs#hello
```

```bash
nix \
profile \
install \
--store "$HOME"/store \
github:ES-Nix/podman-rootless/from-nixpkgs \
&& nix \
develop \
--store "$HOME"/store \
github:ES-Nix/podman-rootless/from-nixpkgs \
--command \
podman \
--version \
&& podman \
run \
--rm \
docker.io/library/alpine:3.14.2 \
apk add --no-cache curl
```


```bash
podman \
run \
--log-level=error \
--privileged=true \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--name=nix-flake \
--network=host \
--tty=true \
--rm=true \
--user=nixuser \
--workdir='/home/nixuser' \
localhost/test-nix-installer
```

```bash
file ~/output/store/*-nix-2.4pre20210727_706777a-x86_64-unknown-linux-musl/bin/nix
file ~/output/store/*-profile/bin/nix
```


where nix is the static nix from https://matthewbauer.us/nix and a pkgsStatic.busybox
RUN ln -sf /bin/busybox /bin/sh
https://discourse.nixos.org/t/dockertools-buildimage-and-user-writable-tmp/5397/8

TODO: use this to troubleshoot
- https://stackoverflow.com/a/22686512
- https://serverfault.com/a/615344

```bash
nix build nixpkgs#pkgsStatic.busybox
result/bin/busybox sh -c 'echo $$ && uname --all'
```

```bash
nix run nixpkgs#pkgsStatic.busybox -- sh -c 'echo $$ && uname --all'
```
nix run nixpkgs#pkgsStatic.xorg.xclock
[LinuxCon Portland 2009 - Roundtable - Q&A 1](https://www.youtube.com/embed/K3FsmpXeqHc?start=342&end=350&version=3)

TODO: `umask` 
https://github.com/NixOS/nix/issues/2377#issuecomment-633165541
https://ivanix.wordpress.com/tag/umask/

TODO:
- https://github.com/NixOS/nixpkgs/pull/56281#issuecomment-484242510 and https://github.com/lethalman/nix-user-chroot/pull/13#issuecomment-462200418
- https://github.com/NixOS/nix/blob/d9cfd853e52d0173f86a1648246360faa96c516c/flake.nix#L87

### Install direnv and nix-direnv using nix + flakes

```bash
SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/install_direnv_and_nix_direnv.sh | sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& direnv --version
```

To remove:
```bash
nix profile remove "$(nix eval --raw github:NixOS/nixpkgs/60e774ff2ca18570a93a2992fd18b8f5bf3ba57b#direnv)"
nix profile remove "$(nix eval --raw github:NixOS/nixpkgs/60e774ff2ca18570a93a2992fd18b8f5bf3ba57b#nix-direnv)"

rm -rfv ~/.direnvrc
```

You might want to run this one to:
```bash
nix store gc --verbose \
&& nix store optimise --verbose
```

```bash
string='/nix/store/d71am745ykqnhniz19hxncxz0yfrhclj-nix-direnv-1.6.0/share/nix-direnv/direnvrc'
SEARCH_REGEX='/nix/store/[0-9a-z]\{32\}-nix-direnv-\([0-9]\{1,\}\).\([0-9]\{1,\}\).\([0-9]\{1,\}\)/share/nix-direnv/direnvrc'
echo $string | grep -q -e '/nix/store/[0-9a-z]\{32\}-nix-direnv-\([0-9]\{1,\}\).\([0-9]\{1,\}\).\([0-9]\{1,\}\)/share/nix-direnv/direnvrc'
echo $?


string='/nix/store/gx80b9p7xdyjmbkns86zl8kkkaz5bfsl-direnv-2.30.3/bin:'
SEARCH_REGEX='/nix/store/[0-9a-z]\{32\}-direnv-\([0-9]\{1,\}\).\([0-9]\{1,\}\).\([0-9]\{1,\}\)/bin:'
echo $string | grep -q -e "${SEARCH_REGEX}"
echo $?

string='/nix/store/gx80b9p7xdyjmbkns6zl8kkkaz5bfsl-direnv-2.30.3/bin:'
SEARCH_REGEX='/nix/store/[0-9a-z]\{32\}-direnv-\([0-9]\{1,\}\).\([0-9]\{1,\}\).\([0-9]\{1,\}\)/bin:'
echo $string | grep -q -e "${SEARCH_REGEX}"
echo $?


string='eval "$(direnv hook bash)"'
SEARCH_REGEX='eval "$(direnv hook ''\([a-z]\{1,\}\)'')"'
echo $string | grep -q -e "${SEARCH_REGEX}"
echo $?
```

#### Testing the direnv's installation

```bash
SHA256=5443257f9e3ac31c5f0da60332d7c5bebfab1cdf \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/src/tests/test_install_direnv_nix_direnv.sh | sh \
&& cd ~/foo-bar
```

```bash
hello
```

```bash
sed \
-i \
's/hello/hello figlet/' \
flake.nix
```

```bash
hello | figlet
```

```bash
sed \
-i \
's/hello figlet/figlet/' \
flake.nix
```

Tried, but does not work:
```bash
timeout 20 bash -c 'until command -v hello; do sleep 1; echo "Waiting for hello..."; done' || true
timeout 20 bash -c 'until command -v figlet; do sleep 1; echo "Waiting for figlet..."; done'
```


```bash
sed -i '/^[^#]/ s/\(^.*plugins.*$\)/#\ \1/' "$GUESSED_SHELL_RC"
```
From: https://stackoverflow.com/a/29685539

https://github.com/direnv/direnv/issues/301#issuecomment-335752541
&& echo 'export DIRENV_BASH=$(which bash)' >> "$GUESSED_SHELL_RC" \

https://github.com/chisui/zsh-nix-shell/issues/17


#### Troubleshoot direnv and nix-direnv

```bash
nano /nix/store/*-nix-direnv-1.2.6/share/nix-direnv/direnvrc

NIX_BIN_PREFIX=$(dirname "$(nix-shell -I nixpkgs=channel:nixos-20.09 --packages which nixFlakes gnugrep --run 'which nix | grep -v warning')")

echo "$(nix eval --raw nixpkgs#nix)"
echo "$(nix eval --raw nixpkgs#nixFlakes)"

nix profile install nixpkgs#nixFlakes

nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix profile install nixpkgs#nixFlakes'

$(nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix eval --raw nixpkgs#nixFlakes')/bin/nix profile install nixpkgs#nixFlakes

nix-env --install --attr nixpkgs.nixFlakes

nix-env --uninstall "$(readlink -f $(which nix-env))"

nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix profile install nixpkgs#nixFlakes'

nix flake --version
readlink -f $(which nix)
```

TODO:
```bash
nix-store \
--gc \
--print-dead \
--option keep-derivations false \
--option keep-outputs true


nix store gc \
--verbose \
--option keep-derivations false \
--option keep-outputs false
```

## Tests

This is an environment that is used to test the installer:

```bash
nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev \
--command bash -c 'vm-kill; run-vm-kvm && prepares-volume && ssh-vm'
```


### Tests

stdenvNoCC
https://wellquite.org/posts/latex_fonts_and_nixos/

#### Minimal build

```bash
nix build --expr '{}' --no-link
```

```bash
cat <<'EOF' | xargs -I{} nix build --expr {} --no-link
'{}'
EOF
```

```bash
nix -vvvvv build --expr '{ inputs.nixpkgs.url = "nixpkgs";  outputs = { ... }: {  }; }' --no-link
```

```bash
nix-build \
--no-substitute \
-E \
'derivation { name = "foo"; system = "x86_64-linux"; builder = "/bin/sh"; args = ["-c" "echo foobar > \$out"]; }'
```

Hope it works:
```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform.pkgsStatic.hello --no-link
```
From:
- https://www.youtube.com/watch?v=OV2hi8b5t48

```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform.pkgsStatic.nix --no-link
```

```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform.pkgsStatic.python3Minimal --no-link
```


```bash
nix \
build \
--impure \
--expr \
'(import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992") {}).nixosTests.podman'
```


```bash
nix \
build \
--impure \
--expr \
'let pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992") {}; in pkgs.nixosTests.podman'
```

```bash
nix \
build \
--impure \
--expr \
'
  let
    pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992") {};
    nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = with pkgs; [
            hello
          ];
        };
      };
  in pkgs.nixosTests ({
      name = "hello-test";
      nodes = nodes;
      testScript = ''"machine.succeed(\"hello\")"'';
    })
'
```


That is insane to be possible, but it is, well hope it does not brake for you:

```bash
nix \
shell \
--store "$HOME" \
nixpkgs/a3f85aedb1d66266b82d9f8c0a80457b4db5850c#{\
gcc10,\
gcc6,\
gfortran10,\
gfortran6,\
julia_16-bin,\
nodejs,\
poetry,\
python39,\
rustc,\
yarn\
}

gcc --version
gfortran --version
julia --version
node --version
poetry --version
python3 --version
rustc --version
yarn --version
```

```bash
mkdir -p ~/.config/containers
cat << 'EOF' >> ~/.config/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}
EOF

mkdir -p ~/.config/containers
cat << 'EOF' >> ~/.config/containers/registries.conf
[registries.search]
registries = ['docker.io']
[registries.block]
registries = []
EOF

nix \
shell \
nixpkgs#podman \
--command \
podman \
run \
--privileged=true \
--device=/dev/fuse \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--network=host \
--mount=type=tmpfs,destination=/var/lib/containers \
--tty=true \
--rm=true \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
--volume=/dev:/dev \
docker.nix-community.org/nixpkgs/nix-flakes \
bash \
-c \
'id'
```

```bash
nix build nixpkgs#pkgsCross.aarch64-multiplatform.stdenv

RESULT_PATH='result/bin/busybox'


RESULT_SHA256='93c70940186e32f6a36e6a9c63c3ceb5d5ad3f4b6ead6f6078842ad164009e89'
RESULT_SHA512='04491ffe77bd56bc9a9cbb428079ceb75bc65398fcdc9586ad4a3420c962ebfec4a4ccc5c61f6c2e11d0c155c0d6f63bed2336de578289c872aede7e06142371'

nix \
build \
nixpkgs#pkgsCross.aarch64-multiplatform.pkgsStatic.busybox-sandbox-shell \
--option substitute true

echo "${RESULT_SHA256}"'  '"${RESULT_PATH}" | sha256sum -c
echo "${RESULT_SHA512}"'  '"${RESULT_PATH}" | sha512sum -c

nix \
build \
nixpkgs#pkgsCross.s390x.pkgsStatic.busybox-sandbox-shell \
--option substitute true

echo "${RESULT_SHA256}"'  '"${RESULT_PATH}" | sha256sum -c
echo "${RESULT_SHA512}"'  '"${RESULT_PATH}" | sha512sum -c

echo 'Using now the correct shas:'
RESULT_SHA256='45de8827ef49b643050aa845a68449e5b5d10404103e61e88008bb1ea2c617bb'
RESULT_SHA512='ef1cff43e13d6940228cf57532cfd4de9f7eabd003fe658bb97bcb3ccae5a8e6ffe4abd70f3abbd57a0d752c2fa70ed2e1ab29282e23aa573f8a8badb7dc8b4a'

echo "${RESULT_SHA256}"'  '"${RESULT_PATH}" | sha256sum -c
echo "${RESULT_SHA512}"'  '"${RESULT_PATH}" | sha512sum -c
```


```bash
nix build nixpkgs#pkgsCross.s390x.busybox-sandbox-shell
```

```bash
nix build nixpkgs#pkgsCross.armv7l-hf-multiplatform.dockerTools.examples.redis
```

```bash
nix build nixpkgs#pkgsCross.armv7l-hf-multiplatform.pkgsStatic.dockerTools.examples.redis
```

```bash
echo "Hello Nix" | nix run "nixpkgs#ponysay"
```

```bash
nix \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "nixpkgs";
    with legacyPackages.${builtins.currentSystem};
    [
      hello
      cowsay
    ]
  )
' \
--command \
sh \
-c \
'hello | cowsay'
```



```bash
nix \
build \
--impure \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/nixpkgs-unstable"
    ).lib.nixosSystem {
        system = "${builtins.currentSystem}";
        modules = [];
    }
  ).config.system.build.vm 
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
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/nixpkgs-unstable"
    ).lib.nixosSystem {
        system = "${builtins.currentSystem}";
        modules = [({ pkgs, ... }: {
            boot.isContainer = true;

            # Network configuration.
            networking.useDHCP = false;
            networking.firewall.allowedTCPPorts = [ 80 ];

            # Enable a web server.
            services.httpd = {
              enable = true;
              adminAddr = "morty@example.org";
            };
          })
        ];
    }
  ).config.system.build.toplevel 
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
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf"
    ).lib.nixosSystem {
        system = "${builtins.currentSystem}";
        modules = [ "${toString (builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
    }
  ).config.system.build.isoImage
)
'
```


```bash
nix \
--option sandbox true \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/aebc7fd7e2a816801862b1892db35c4653a48225"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ "${toString (builtins.getFlake "github:NixOS/nixpkgs/aebc7fd7e2a816801862b1892db35c4653a48225")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
    }
  ).config.system.build.isoImage
)
'
```

```bash
nix flake metadata github:NixOS/nixpkgs/nixos-22.05-small
github:NixOS/nixpkgs/aebc7fd7e2a816801862b1892db35c4653a48225
```

```bash
ISO_PATH="$(echo result/iso/nixos-22.05.*.*-x86_64-linux.iso)"


sha1sum "${ISO_PATH}"
sha256sum "${ISO_PATH}"
sha512sum "${ISO_PATH}"

ISO_SHA1='c9fef27e86190a1ef16b902cce37735f7bd24ea5'
ISO_SHA256='f20ecfd64b0d9a222ef07d3331b250da938bd475887734e46a2ffcf2bd8481f2'
ISO_SHA512='37aa13d449ac66413cb47b4fb4b091c37e2df6a414d73764ac88b4d34a9d5916a83310b3056bdab6e29f669a36f8c041a118b10a2e3b4dc2d674f66bd350f955'

echo "${ISO_SHA1}"'  '"${ISO_PATH}" | sha1sum -c
echo "${ISO_SHA256}"'  '"${ISO_PATH}" | sha256sum -c
echo "${ISO_SHA512}"'  '"${ISO_PATH}" | sha512sum -c

nix run nixpkgs#neofetch -- --json
{
    "OS": "NixOS 22.05 (Quokka) x86_64",
    "Host": "LENOVO",
    "Kernel": "5.15.28",
    "Uptime": "1 day, 1 hour, 30 mins",
    "Packages": "1280 (nix-system), 132 (nix-user), 234 (nix-default)",
    "Shell": "zsh 5.8.1",
    "Resolution": "1366x768, 1366x768",
    "DE": "Plasma 5.23.5",
    "WM": "KWin",
    "Theme": "Breeze [GTK2/3]",
    "Icons": "breeze [GTK2/3]",
    "Terminal": ".konsole-wrappe",
    "CPU": "Intel i3-4130 (4) @ 3.400GHz",
    "GPU": "Intel  4th Generation Core Processor Family ",
    "GPU": "Intel 4th Generation Core Processor Family",
    "Memory": "6625MiB / 7777MiB",
    "Version": "7.1.0"
}
```


```bash
sha1sum result/iso/nixos-22.05.20220501.b283b64-x86_64-linux.iso
sha256sum result/iso/nixos-22.05.20220501.b283b64-x86_64-linux.iso
sha512sum result/iso/nixos-22.05.20220501.b283b64-x86_64-linux.iso

b763f9da3d5f48ce52142f62c484725b52ca431d  result/iso/nixos-22.05.20220501.b283b64-x86_64-linux.iso
1242cef387cdedbff99db4dd415633ef43f1e642bcc8f2f4cb5b2a89ec2f1d32  result/iso/nixos-22.05.20220501.b283b64-x86_64-linux.iso
8114af918b87715ef3a1b4e637762bf0b5ae33ef292c266bfacde4c2946b1b62715fd3cb7a20f254ff615a95b462140ed45e3c3c863c35ea83eb6ea7802e7ab8  result/iso/nixos-22.05.20220501.b283b64-x86_64-linux.iso

nix run nixpkgs#neofetch -- --json
```



#### config.system.build.vm nixos/modules/virtualisation/build-vm.nix

Bare minimum (not so useful, just to test with nix build):
```bash
nix \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
        ];
    }
  ).config.system.build.vm
)
'
```

If you try to execute that command with `nix run` rather then `nix build` it needs DISPLAY and 
as is it is you does not have a way to login.


##### Custom build-vm


TODO: make a minimal version of that.
```bash
nix run nixpkgs#xorg.xhost -- +localhost

export QEMU_OPTS='-nographic -display gtk,gl=on'
export SHARED_DIR="$(pwd)"

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"
            ];

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              # initialPassword = "test";
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [ 
                  # hello
                  pkgsCross.aarch64-multiplatform.pkgsStatic.hello
                  direnv
                  gitFull
                  xorg.xclock
                  file 
                  libvirt
                  pciutils
                  vagrant
                  virt-manager
                  qemu
                  kmod
                  gcc
                  gnumake
                  which
                  
                  xorg.xorgserver
                  xorg.xf86inputevdev
                  xorg.xf86inputsynaptics
                  xorg.xf86inputlibinput
                  xorg.xf86videointel
                  xorg.xf86videoati
                  xorg.xf86videonouveau                  
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

#              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
#              systemd.services.fix-mount = {
#                script = "mkdir -pv /home/nixuser/code && chown -v nixuser:nixgroup /home/nixuser/code && echo sudo mount -t 9p -o trans=virtio hostsharetag /home/nixuser/code -oversion=9p2000.L,posixacl,msize=104857600,cache=loose >> /home/nixuser/.profile";
#                wantedBy = [ "multi-user.target" ];
#              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"touch /tmp/shared/log.txt; ls -al /tmp/shared/\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              services.getty.autologinUser = "nixuser";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 1024; # Use 1024MiB memory.
                cores = 3;         # Simulate 3 cores.
                libvirtd.enable = true;
                # docker.enable = true;
                
                podman = {
                    enable = true;
                    # Creates a `docker` alias for podman, to use it as a drop-in replacement
                    # dockerCompat = true;
                };                
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];
              
              boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
              
              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;
                        
              nixpkgs.config.allowUnfree = true;
              nix = {
                # What about github:NixOS/nix#nix-static can it be injected here? What would break?
                # keep-outputs = true
                # keep-derivations = true
                # system-features = benchmark big-parallel kvm nixos-test
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver.enable = true;
              services.xserver.displayManager.lightdm.enable = true;
              services.spice-vdagentd.enable = true;
              # See https://discourse.nixos.org/t/display-scaling-with-nixos-as-qemu-kvm-guest/4466 and https://discourse.nixos.org/t/nixos-as-a-guest-os-in-qemu-kvm-how-to-share-clipboard-displaying-scaling-etc/8124
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              environment.variables = {
                VAGRANT_DEFAULT_PROVIDER = "libvirt";
                # VAGRANT_DEFAULT_PROVIDER = "virtualbox";
              };
            
              time.timeZone = "America/Recife";

            users.users.root.initialPassword = "root";
          })
        ];
    }
  ).config.system.build.vm
)
'; \
rm -fv nixos.qcow2
```
Refs.:
- https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
- https://discourse.nixos.org/t/default-login-and-password-for-nixos/4683
- https://discourse.nixos.org/t/nixos-rebuild-build-vm-option-virtualisation-cores-does-not-exist/22929/2
- https://nixos.wiki/wiki/Using_X_without_a_Display_Manager



##### Xorg, X11, xauth, build-vm, ssh

###### minimal

```bash
# nix run nixpkgs#xorg.xhost -- +localhost
# export QEMU_OPTS='-nographic -display gtk,gl=on'
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOK55vtFrqxd5idNzCd2nhr5K3ocoyw1JKWSM1E7f9i";
    in 
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"
            ];
            
            boot.tmpOnTmpfsSize = "95%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              # initialPassword = "test";
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [ 
                  hello
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  which
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;
              
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
          
              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];              
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };
              
              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"touch /tmp/shared/log.txt; ls -al /tmp/shared/\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.populate-history2 = {
                script = "echo \"xauth list\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              # services.getty.autologinUser = "nixuser";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 5120; # Use MiB memory.
                diskSize = 4096; # Use MiB memory.
                cores = 3;         # Simulate 3 cores.
                # libvirtd.enable = true;
                # docker.enable = true;

                podman = {
                    enable = true;
                    # Creates a `docker` alias for podman, to use it as a drop-in replacement
                    # dockerCompat = true;
                };                
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = { 
                enable = true; 
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;
              
              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];             
              };
              programs.ssh.forwardX11 = true;

              # environment.loginShellInit = "if test \"$(tty)\" = \"/dev/ttyS0\" && ! pgrep -f xserver \n then startx &\n fi"; 
              # See https://discourse.nixos.org/t/display-scaling-with-nixos-as-qemu-kvm-guest/4466 and https://discourse.nixos.org/t/nixos-as-a-guest-os-in-qemu-kvm-how-to-share-clipboard-displaying-scaling-etc/8124
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              environment.variables = {
                VAGRANT_DEFAULT_PROVIDER = "libvirt";
                # VAGRANT_DEFAULT_PROVIDER = "virtualbox";
              };
            
              time.timeZone = "America/Recife";
            
            system.stateVersion = "22.11";

            # users.mutableUsers = false;
            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022<<COMMANDS
timeout 10 xclock
COMMANDS
# rm -fv nixos.qcow2
```


##### Xorg, X11, xauth, build-vm, ssh, vscode


```bash
xhost +localhost || nix run nixpkgs#xorg.xhost -- +localhost
# export QEMU_OPTS='-nographic -display gtk,gl=on'
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

export NIXPKGS_ALLOW_UNFREE=1

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/37b97ae3dd714de9a17923d004a2c5b5543dfa6d";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOK55vtFrqxd5idNzCd2nhr5K3ocoyw1JKWSM1E7f9i";
    in 
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/37b97ae3dd714de9a17923d004a2c5b5543dfa6d")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/37b97ae3dd714de9a17923d004a2c5b5543dfa6d")}/nixos/modules/virtualisation/qemu-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/37b97ae3dd714de9a17923d004a2c5b5543dfa6d")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"
            ];
            
            boot.tmpOnTmpfsSize = "95%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              # initialPassword = "test";
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [ 
                  hello
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  which
                  vscode
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;
              
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
          
              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];              
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };
              
              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"touch /tmp/shared/log.txt; ls -al /tmp/shared/\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.populate-history2 = {
                script = "echo \"xauth list\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              # services.getty.autologinUser = "nixuser";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 5120; # Use MiB memory.
                diskSize = 4096; # Use MiB memory.
                cores = 3;         # Simulate 3 cores.
                # libvirtd.enable = true;
                # docker.enable = true;

                podman = {
                    enable = true;
                    # Creates a `docker` alias for podman, to use it as a drop-in replacement
                    # dockerCompat = true;
                };                
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = { 
                enable = true; 
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;
              
              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];             
              };
              programs.ssh.forwardX11 = true;

              # environment.loginShellInit = "if test \"$(tty)\" = \"/dev/ttyS0\" && ! pgrep -f xserver \n then startx &\n fi"; 
              # See https://discourse.nixos.org/t/display-scaling-with-nixos-as-qemu-kvm-guest/4466 and https://discourse.nixos.org/t/nixos-as-a-guest-os-in-qemu-kvm-how-to-share-clipboard-displaying-scaling-etc/8124
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;
            
              time.timeZone = "America/Recife";
            
            system.stateVersion = "22.11";

            # users.mutableUsers = false;
            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
# rm -fv nixos.qcow2
```

```bash
# nix run nixpkgs#xorg.xhost -- +localhost
# export QEMU_OPTS='-nographic -display gtk,gl=on'
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      PedroRegisPOARKeys = writeText "pedro-regis-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOK55vtFrqxd5idNzCd2nhr5K3ocoyw1JKWSM1E7f9i";
    in 
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"
            ];
            
            boot.tmpOnTmpfsSize = "95%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              # initialPassword = "test";
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [ 
                  # hello
                  pkgsCross.aarch64-multiplatform.pkgsStatic.hello
                  direnv
                  gitFull
                  xorg.xclock
                  file 
                  libvirt
                  pciutils
                  vagrant
                  virt-manager
                  qemu
                  kmod
                  gcc
                  gnumake
                  which
                  
                  xorg.xinit
                  xorg.xhost
                  xorg.xorgserver
                  xorg.xdpyinfo
                  xorg.xf86inputevdev
                  xorg.xf86inputsynaptics
                  xorg.xf86inputlibinput
                  xorg.xf86videointel
                  xorg.xf86videoati
                  xorg.xf86videonouveau                  
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;
              
              openssh.authorizedKeys.keyFiles = [
                PedroRegisPOARKeys
              ];
          
              openssh.authorizedKeys.keys = [
                "${PedroRegisPOARKeys}"
              ];              
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

#              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
#              systemd.services.fix-mount = {
#                script = "mkdir -pv /home/nixuser/code && chown -v nixuser:nixgroup /home/nixuser/code && echo sudo mount -t 9p -o trans=virtio hostsharetag /home/nixuser/code -oversion=9p2000.L,posixacl,msize=104857600,cache=loose >> /home/nixuser/.profile";
#                wantedBy = [ "multi-user.target" ];
#              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };
              
              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"touch /tmp/shared/log.txt; ls -al /tmp/shared/\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.populate-history2 = {
                script = "echo \"xauth list\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              # services.getty.autologinUser = "nixuser";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 5120; # Use 2048MiB memory.
                diskSize = 4096; # Use 4096MiB memory.
                cores = 3;         # Simulate 3 cores.
                libvirtd.enable = true;
                # docker.enable = true;
                
                podman = {
                    enable = true;
                    # Creates a `docker` alias for podman, to use it as a drop-in replacement
                    # dockerCompat = true;
                };                
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];
              
              boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
              
              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;
                        
              nixpkgs.config.allowUnfree = true;
              nix = {
                # What about github:NixOS/nix#nix-static can it be injected here? What would break?
                # keep-outputs = true
                # keep-derivations = true
                # system-features = benchmark big-parallel kvm nixos-test
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = { 
                enable = true; 
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;
              
              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString PedroRegisPOARKeys}"
                ];             
              };
              programs.ssh.forwardX11 = true;

              # environment.loginShellInit = "if test \"$(tty)\" = \"/dev/ttyS0\" && ! pgrep -f xserver \n then startx &\n fi"; 
              # See https://discourse.nixos.org/t/display-scaling-with-nixos-as-qemu-kvm-guest/4466 and https://discourse.nixos.org/t/nixos-as-a-guest-os-in-qemu-kvm-how-to-share-clipboard-displaying-scaling-etc/8124
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              environment.variables = {
                VAGRANT_DEFAULT_PROVIDER = "libvirt";
                # VAGRANT_DEFAULT_PROVIDER = "virtualbox";
              };
            
              time.timeZone = "America/Recife";
            
            system.stateVersion = "22.11";

            # users.mutableUsers = false;
            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                PedroRegisPOARKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022<<COMMANDS
timeout 10 xclock
COMMANDS
# rm -fv nixos.qcow2
```
Refs.:
- https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
- https://discourse.nixos.org/t/default-login-and-password-for-nixos/4683
- https://discourse.nixos.org/t/nixos-rebuild-build-vm-option-virtualisation-cores-does-not-exist/22929/2
- https://nixos.wiki/wiki/Using_X_without_a_Display_Manager
- https://github.com/NixOS/nixpkgs/issues/18523#issuecomment-323389189


```bash
while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022<<'COMMANDS'
file $(readlink -f $(which hello))
hello
COMMANDS
# rm -fv nixos.qcow2
```


Nesting:
```bash
export QEMU_NET_OPTS='hostfwd=tcp::10023-:10023'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      PedroRegisPOARKeys = writeText "pedro-regis-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOK55vtFrqxd5idNzCd2nhr5K3ocoyw1JKWSM1E7f9i";
    in 
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"
            ];

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              # initialPassword = "test";
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [ 
                  # hello
                  direnv
                  gitFull
                  xorg.xclock
                  file 
                  libvirt
                  pciutils
                  vagrant
                  virt-manager
                  qemu
                  kmod
                  gcc
                  gnumake
                  which
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;
              
              openssh.authorizedKeys.keyFiles = [
                PedroRegisPOARKeys
              ];
          
              openssh.authorizedKeys.keys = [
                "${PedroRegisPOARKeys}"
              ];              
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

#              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
#              systemd.services.fix-mount = {
#                script = "mkdir -pv /home/nixuser/code && chown -v nixuser:nixgroup /home/nixuser/code && echo sudo mount -t 9p -o trans=virtio hostsharetag /home/nixuser/code -oversion=9p2000.L,posixacl,msize=104857600,cache=loose >> /home/nixuser/.profile";
#                wantedBy = [ "multi-user.target" ];
#              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };
              
              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"touch /tmp/shared/log.txt; ls -al /tmp/shared/\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.populate-history2 = {
                script = "echo \"xauth list\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              # services.getty.autologinUser = "nixuser";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 1024; # Use 1024MiB memory.
                cores = 3;         # Simulate 3 cores.
                libvirtd.enable = true;
                # docker.enable = true;
                
                podman = {
                    enable = true;
                    # Creates a `docker` alias for podman, to use it as a drop-in replacement
                    # dockerCompat = true;
                };                
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];
              
              boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
              
              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;
                        
              nixpkgs.config.allowUnfree = true;
              nix = {
                # What about github:NixOS/nix#nix-static can it be injected here? What would break?
                # keep-outputs = true
                # keep-derivations = true
                # system-features = benchmark big-parallel kvm nixos-test
                package = pkgs.nixFlakes;
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = { 
                enable = true; 
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;
              
              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10023 ];
                authorizedKeysFiles = [
                  "${toString PedroRegisPOARKeys}"
                  # "${toString RodrigoKeys}"
                ];             
              };
              programs.ssh.forwardX11 = true;

              # environment.loginShellInit = "if test \"$(tty)\" = \"/dev/ttyS0\" && ! pgrep -f xserver \n then startx &\n fi"; 
              # See https://discourse.nixos.org/t/display-scaling-with-nixos-as-qemu-kvm-guest/4466 and https://discourse.nixos.org/t/nixos-as-a-guest-os-in-qemu-kvm-how-to-share-clipboard-displaying-scaling-etc/8124
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              environment.variables = {
                VAGRANT_DEFAULT_PROVIDER = "libvirt";
                # VAGRANT_DEFAULT_PROVIDER = "virtualbox";
              };
            
              time.timeZone = "America/Recife";

            # users.mutableUsers = false;
            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                PedroRegisPOARKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10023; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10023'; \
ssh \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10023
```

```bash
    xorg.libXScrnSaver
    xorg.libXdamage
    xorg.libX11
    xorg.libxcb
    xorg.libXcomposite
    xorg.libXi
    xorg.libXext
    xorg.libXfixes
    xorg.libXcursor
    xorg.libXrender
    xorg.libXrandr
    mesa
    cups
    expat
    ffmpeg
    libdrm
    libxkbcommon
    at_spi2_atk
    at_spi2_core
    dbus
    gdk_pixbuf
    gtk3
    cairo
    pango
    xorg.xauth
    glib
    nspr
    atk
    nss
    gtk2
    alsaLib
    gnome2.GConf
    unzip    
```

> Broken: I just give-up for now and used ssh -X


On the host:
```bash
xauth extract - $DISPLAY > xauth_extract
```

On the guest:
```bash
xauth merge /tmp/shared/xauth_extract
```

```bash
export DISPLAY=nixos/unix:0
```

```bash
journalctl -b 0 -u display-manager
```

```bash
xauth extract - ${DISPLAY##localhost} | sudo -u nixuser xclock $DISPLAY
```

```bash
xdpyinfo -display :0 -queryExtensions | grep 'MIT-SHM'
```

```bash
while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh -X -o StrictHostKeyChecking=no nixuser@localhost -p 10022; \
rm -fv nixos.qcow2
```


##### k8s, X11, build-vm, ssh 

###### minimal

```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [
                  direnv
                  gitFull
                  xorg.xclock
                  file
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;

              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];

              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 5120; # Use 5120MiB memory.
                diskSize = 4096; # Use 4096MiB memory.
                cores = 3;         # Simulate 3 cores.
                #
                docker.enable = true;
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;

              nixpkgs.config.allowUnfree = true;
              nix = {
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };
              programs.ssh.forwardX11 = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              time.timeZone = "America/Recife";

            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022<<'COMMANDS'
timeout 20 xclock
COMMANDS
"$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```



###### k8s, X11, build-vm, ssh, adds vscode

```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

# Because vscode
export NIXPKGS_ALLOW_UNFREE=1

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && { echo 'There is something already using the port:'"$HOST_MAPPED_PORT" && kill $(lsof -i:10022 -t)}

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519


nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  vscode
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;

              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];

              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 5120; # Use 5120MiB memory.
                diskSize = 4096; # Use 4096MiB memory.
                cores = 3;         # Simulate 3 cores.
                #
                docker.enable = true;
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;

              nixpkgs.config.allowUnfree = true;
              nix = {
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };
              programs.ssh.forwardX11 = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              time.timeZone = "America/Recife";

            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-X \
-tt \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
# <<'COMMANDS'
# timeout 20 code
# COMMANDS
# "$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```


```bash
test -d .vscode || mkdir -v .vscode

cat <<'EOF' > .vscode/extensions.json
{
  "recommendations": ["dbaeumer.vscode-eslint@2.2.6", "esbenp.prettier-vscode@9.10.4", "Vue.volar@1.0.24", "bbenoist.Nix@1.0.1",]
}
EOF

# code --extensions-dir .vscode
# npm i

npx json5 .vscode/extensions.json | \
npx json-cli-tool --path=recommendations --output=newline | \
xargs -L 1 code --install-extension
```
Refs.:
- https://stackoverflow.com/a/74440032
- https://code.visualstudio.com/docs/editor/extension-marketplace#_command-line-extension-management
- https://stackoverflow.com/a/52055680


https://discord.com/channels/692426888563523716/713450173094953022/839256975623847949

https://discord.com/channels/692426888563523716/713450173094953022/1050139524266729553

code --list-extensions --show-versions






##### k8s

```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      # https://github.com/pedroregispoar.keys
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kubernetes"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  # Looks like kubernetes needs atleast all this
                  kubectl
                  kubernetes
                  #
                  cni
                  cni-plugins
                  conntrack-tools
                  cri-o
                  cri-tools
                  # docker
                  ebtables
                  ethtool
                  flannel
                  iptables
                  socat
                   (writeScriptBin "fix-k8s-cluster-admin-key" "#! ${pkgs.runtimeShell} -e \n sudo chmod 0660 -v /var/lib/kubernetes/secrets/cluster-admin-key.pem \n sudo chown root:kubernetes -v /var/lib/kubernetes/secrets/cluster-admin-key.pem")
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;

              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];

              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"watch -n 1 kubectl get pods --all-namespaces -o wide\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 5120; # Use 5120MiB memory.
                diskSize = 4096; # Use 4096MiB memory.
                cores = 3;         # Simulate 3 cores.
                #
                docker.enable = true;
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;

              nixpkgs.config.allowUnfree = true;
              nix = {
                extraOptions = "experimental-features = nix-command flakes ca-derivations";
                readOnlyStore = false;
              };

              # Enable the X11 windowing system.
              services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };
              programs.ssh.forwardX11 = true;

              # environment.loginShellInit = "if test \"$(tty)\" = \"/dev/ttyS0\" && ! pgrep -f xserver \n then startx &\n fi";
              # See https://discourse.nixos.org/t/display-scaling-with-nixos-as-qemu-kvm-guest/4466 and https://discourse.nixos.org/t/nixos-as-a-guest-os-in-qemu-kvm-how-to-share-clipboard-displaying-scaling-etc/8124
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              time.timeZone = "America/Recife";

              environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
              environment.etc."containers/registries.conf" = {
                mode = "0644";
                text = "[registries.search] \n registries = [\"docker.io\", \"localhost\"]";
              };

              # Is this ok to kubernetes? Why free -h still show swap stuff but with 0?
              swapDevices = pkgs.lib.mkForce [ ];

              # Is it a must for k8s?
              # Take a look into:
              # https://github.com/NixOS/nixpkgs/blob/9559834db0df7bb274062121cf5696b46e31bc8c/nixos/modules/services/cluster/kubernetes/kubelet.nix#L255-L259
              boot.kernel.sysctl = {
                "net.ipv4.conf.all.rp_filter" = 1;
                "vm.swappiness" = 0;
              };

              services.kubernetes.roles = [ "master" "node" ];
              services.kubernetes.masterAddress = "nixos";
              services.kubernetes = {
                flannel.enable = true;
              };

            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-tt \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022<<'COMMANDS'
sleep 10
FULL_PATH_CLUSTER_ADMIN_KEY=/var/lib/kubernetes/secrets/cluster-admin-key.pem
while ! test -f "$FULL_PATH_CLUSTER_ADMIN_KEY"; do echo Waiting for file "$FULL_PATH_CLUSTER_ADMIN_KEY" $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& echo | sudo -S fix-k8s-cluster-admin-key \
&& watch -n 1 kubectl get pods --all-namespaces -o wide
COMMANDS
# "$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```
Refs.:
- https://stackoverflow.com/a/7122115
- https://stackoverflow.com/a/20521915




```bash
while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-X \
-tt \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022<<'COMMANDS'
watch -n 1 kubectl get pods --all-namespaces -o wide
COMMANDS
```

#### in-line nix build qcow2-compressed

```bash
nix \
build \
--expr \
'
(
with (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4");
let
  #
  # https://hoverbear.org/blog/nix-flake-live-media/
  # https://github.com/NixOS/nixpkgs/blob/39b851468af4156e260901c4fd88f88f29acc58e/nixos/release.nix#L147
  image = (import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/eval-config.nix" {
    system = "x86_64-linux";
    modules = [
      # expression that exposes the configuration as vm image
      ({ config, lib, pkgs, ... }: {
        system.build.qcow2 = import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/make-disk-image.nix" {
          inherit lib config pkgs;
          diskSize = 4096;
          format = "qcow2-compressed";
          # configFile = ./configuration.nix;
        };
      })

      # configure the mountpoint of the root device
      ({
        fileSystems."/".device = "/dev/disk/by-label/nixos";
        boot.loader.grub.device = "/dev/sda";
      })
    ];
  }).config.system.build.qcow2;
in
{
  inherit image;
}
)
'

qemu-img info --output json result/nixos.qcow2
```


```bash
nix shell nixpkgs#qemu \
--command qemu-img info --output json \
$(
nix \
build \
--print-out-paths \
--expr \
'
(
  with (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4");
  let
    #
    # https://hoverbear.org/blog/nix-flake-live-media/
    # https://github.com/NixOS/nixpkgs/blob/39b851468af4156e260901c4fd88f88f29acc58e/nixos/release.nix#L147
    image = (import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/eval-config.nix" {
      system = "x86_64-linux";
      modules = [
        # expression that exposes the configuration as vm image
        ({ config, lib, pkgs, ... }: {
          system.build.qcow2 = import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/make-disk-image.nix" {
            inherit lib config pkgs;
            diskSize = 4096;
            format = "qcow2-compressed";
            # configFile = ./configuration.nix;
          };
        })

        # configure the mountpoint of the root device
        ({
          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.loader.grub.device = "/dev/sda";

          system.stateVersion = "22.11";
        })
      ];
    }).config.system.build.qcow2;
  in
  {
    inherit image;
  }
)
'
)/nixos.qcow2
```


```bash
nix \
run \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"

          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"
          
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ];

        ({virtualisation.memorySize = 2048;})
    }
  ).config.system.build.vm
)
'
```



```bash
nix \
build \
--print-out-paths \
--expr \
'
(
  with (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4");
  let
    #
    # https://hoverbear.org/blog/nix-flake-live-media/
    # https://github.com/NixOS/nixpkgs/blob/39b851468af4156e260901c4fd88f88f29acc58e/nixos/release.nix#L147
    image = (import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/eval-config.nix" {
      system = "x86_64-linux";
      modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

        # expression that exposes the configuration as vm image
        ({ config, lib, pkgs, ... }: {
          system.build.qcow2 = import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/make-disk-image.nix" {
            inherit lib config pkgs;
            diskSize = 4096;
            format = "qcow2-compressed";
            # configFile = ./configuration.nix;
          };
        })

        # configure the mountpoint of the root device
        ({
          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.loader.grub.device = "/dev/sda";
          # Silences some warn
          system.stateVersion = "22.11";
        })
      ];
    }).config.system.build.vm;
  in
  {
    inherit image;
  }
)
'
```

TODO: is this working?
```bash
(
  {
    virtualisation = {
      memorySize = 2048; # Use 2048MiB memory.
      cores = 4;         # Simulate 4 cores.
    }
  }
)
```


```bash
podman \
run \
--device=/dev/kvm \
--device=/dev/fuse \
--log-level=error \
--env STORAGE_DRIVER=vfs \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
--security-opt seccomp=unconfined \
--security-opt label=disable \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
--volume=/proc/:/proc/:rw \
--volume="$(pwd)":/code \
--workdir=/code \
docker.io/nixpkgs/nix-flakes \
bash \
-c \
"nix --option sandbox false build --expr '(builtins.getFlake \"github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf\")'"
```

```bash
# nix flake metadata github:NixOS/nixpkgs/nixos-22.05
FIXED_NIXPKGS='github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c'
RESULT_PATH='result/bin/busybox'


RESULT_SHA256='93c70940186e32f6a36e6a9c63c3ceb5d5ad3f4b6ead6f6078842ad164009e89'
RESULT_SHA512='04491ffe77bd56bc9a9cbb428079ceb75bc65398fcdc9586ad4a3420c962ebfec4a4ccc5c61f6c2e11d0c155c0d6f63bed2336de578289c872aede7e06142371'

nix \
build \
"${FIXED_NIXPKGS}"#pkgsCross.aarch64-multiplatform.pkgsStatic.busybox-sandbox-shell \
--option substitute true \
--option sandbox false

echo "${RESULT_SHA256}"'  '"${RESULT_PATH}" | sha256sum -c
echo "${RESULT_SHA512}"'  '"${RESULT_PATH}" | sha512sum -c

nix \
build \
"${FIXED_NIXPKGS}"#pkgsCross.s390x.pkgsStatic.busybox-sandbox-shell \
--option substitute true \
--option sandbox false

echo "${RESULT_SHA256}"'  '"${RESULT_PATH}" | sha256sum -c
echo "${RESULT_SHA512}"'  '"${RESULT_PATH}" | sha512sum -c

echo 'Using now the correct shas:'
RESULT_SHA256='45de8827ef49b643050aa845a68449e5b5d10404103e61e88008bb1ea2c617bb'
RESULT_SHA512='ef1cff43e13d6940228cf57532cfd4de9f7eabd003fe658bb97bcb3ccae5a8e6ffe4abd70f3abbd57a0d752c2fa70ed2e1ab29282e23aa573f8a8badb7dc8b4a'

echo "${RESULT_SHA256}"'  '"${RESULT_PATH}" | sha256sum -c
echo "${RESULT_SHA512}"'  '"${RESULT_PATH}" | sha512sum -c
```


```bash
jq --version || nix profile install nixpkgs#jq
nix flake metadata github:NixOS/nixpkgs/nixos-22.05 --json | jq --join-output '.url'
```

```bash
# It does not exist in NixOS systems!
# --volume=/etc/localtime:/etc/localtime:ro \
# It is not sure taht it exists 
# --volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
podman \
run \
--device=/dev/kvm \
--device=/dev/fuse \
--log-level=error \
--env=STORAGE_DRIVER='vfs' \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--name=nix-flakes-container \
--privileged=true \
--tty=true \
--rm=false \
--security-opt seccomp=unconfined \
--security-opt label=disable \
--user=0 \
--volume=/proc/:/proc/:rw \
--volume="$(pwd)":/code \
--workdir=/code \
docker.io/nixpkgs/nix-flakes \
bash \
-c \
"
nix \
  --option sandbox false \
  build \
  --expr '
    (
      (
        (
          builtins.getFlake \"github:NixOS/nixpkgs/08950a6e29cf7bddee466592eb790a417550f7f9\"
        ).lib.nixosSystem {
            system = \"x86_64-linux\";
            modules = [ \"\${toString (builtins.getFlake \"github:NixOS/nixpkgs/08950a6e29cf7bddee466592eb790a417550f7f9\")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix\" ];
        }
      ).config.system.build.isoImage
    )
  ' \
&& ls -al result/bin/nixos-22.05.*.iso

sha1sum result/bin/nixos-22.05.*.iso
sha256sum result/bin/nixos-22.05.*.iso
sha512sum result/bin/nixos-22.05.*.iso

EXPECTED_SHA1='28a77b051f168a7614bb4a4a6be48a0536b100d4'
EXPECTED_SHA256='cc2ff666032dcd2c99ffcad29dcafdb50e2e38abe3df00ab47198c67879c8edd'
EXPECTED_SHA512='1fe2b87dae294e26177cad9e66177e70953731aefa68420b66da8f480fb230ea24075470132840898a86f7785292acb721a14d9692fcb935401b88215d14b72d'
ISO_PATTERN_NAME='result/bin/nixos-22.05.*.iso'

echo "${EXPECTED_SHA1}"'  '"${ISO_PATTERN_NAME}" | sha1sum -c
echo "${EXPECTED_SHA256}"'  '"${ISO_PATTERN_NAME}" | sha256sum -c
echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c
"
```



```bash
nix \
shell \
--impure \
nixpkgs#bashInteractive \
nixpkgs#coreutils \
nixpkgs#flutter \
nixpkgs#google-chrome \
nixpkgs#which \
--command \
bash \
-c \
'export CHROME_EXECUTABLE="$(which google-chrome-stable)" \
&& flutter devices \
&& flutter create my_app \
&& cd my_app \
&& timeout 30 flutter run || test $? -eq 124 || echo Error in flutter run'
```
Maybe `nix shell --impure --option sandbox false ...` ?



```bash
COMMIT_SHA=7cc36b8ca8292957ad1371c141c6870de20b856d
NIXPKGS_STRING=github:/NANASHI0X74/nixpkgs/"${COMMIT_SHA}"
# NIXPKGS_STRING=nixpkgs

nix \
shell \
--impure \
"${NIXPKGS_STRING}"#bashInteractive \
"${NIXPKGS_STRING}"#coreutils \
"${NIXPKGS_STRING}"#flutter \
"${NIXPKGS_STRING}"#google-chrome \
"${NIXPKGS_STRING}"#which \
--command \
bash \
-c \
'export CHROME_EXECUTABLE="$(which google-chrome-stable)" \
&& flutter devices \
&& flutter create my_app \
&& cd my_app \
&& timeout 60 flutter run || test $? -eq 124 || echo Error in flutter run'
```


```bash
xhost + \
&& podman \
run \
--device=/dev/kvm \
--device=/dev/fuse \
--log-level=error \
--env STORAGE_DRIVER=vfs \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=true \
--tty=true \
--rm=true \
--security-opt seccomp=unconfined \
--security-opt label=disable \
--user=0 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume=/etc/localtime:/etc/localtime:ro \
--volume=/proc/:/proc/:rw \
--volume="$(pwd)":/code \
--workdir=/code \
docker.io/nixpkgs/nix-flakes \
bash \
-c \
'
# test -d ~/.config/nix || mkdir -p ~/.config/nix
# echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

test -d ~/.config/nixpkgs || mkdir -p ~/.config/nixpkgs
echo "{ allowUnfree = true; android_sdk.accept_license = true; }" >> ~/.config/nixpkgs/config.nix

nix \
shell \
--impure \
--option sandbox false \
nixpkgs#busybox-sandbox-shell \
nixpkgs#coreutils \
nixpkgs#flutter \
nixpkgs#google-chrome \
nixpkgs#which

export CHROME_EXECUTABLE="$(which google-chrome-stable)" \
&& flutter devices \
&& flutter create my_app \
&& cd my_app \
&& timeout 30 flutter run || test $? -eq 124 || echo Error in flutter run

' \
&& xhost -
```




nix \
shell \
--impure \
nixpkgs#clang \
nixpkgs#cmake \
nixpkgs#ninja \
nixpkgs#pkg-config \
nixpkgs#gtk3 \
nixpkgs#gtk3.dev \
nixpkgs#gtk3-x11 \
nixpkgs#gtk3-x11.dev


nix \
shell \
--impure \
nixpkgs#clang \
nixpkgs#cmake \
nixpkgs#flutter \
nixpkgs#ninja \
nixpkgs#pkg-config \
nixpkgs#gtk3.dev \
nixpkgs#util-linux.dev \
nixpkgs#glib.dev


flutter config --enable-linux-desktop

flutter create my_app \
&& cd my_app \
&& flutter build linux


flutter clean

```bash
sudo apt-get update \
&& sudo apt-get install -y \
    libgtk-3-dev
```

```bash
Note, selecting 'libspice-client-gtk-3.0-dev' for regex 'gtk+-3.0'

Note, selecting 'libjavascriptcoregtk-3.0-bin' for regex 'gtk+-3.0'
Note, selecting 'libwebkitgtk-3.0-dev' for regex 'gtk+-3.0'
Note, selecting 'gir1.2-gtk-3.0' for regex 'gtk+-3.0'
Note, selecting 'libjavascriptcoregtk-3.0-dev' for regex 'gtk+-3.0'
Note, selecting 'gir1.2-spiceclientgtk-3.0' for regex 'gtk+-3.0'
Note, selecting 'libgtk-3-0' for regex 'gtk+-3.0'
Note, selecting 'libwebkitgtk-3.0-common' for regex 'gtk+-3.0'
Note, selecting 'wxperl-gtk-3-0-4-uni-gcc-3-4' for regex 'gtk+-3.0'
Note, selecting 'libwebkitgtk-3.0-0' for regex 'gtk+-3.0'
Note, selecting 'gir1.2-spice-client-gtk-3.0' for regex 'gtk+-3.0'
Note, selecting 'libwebkit2gtk-3.0-25' for regex 'gtk+-3.0'
Note, selecting 'libjavascriptcoregtk-3.0-0' for regex 'gtk+-3.0'
Note, selecting 'libspice-client-gtk-3.0-1' for regex 'gtk+-3.0'
Note, selecting 'libspice-client-gtk-3.0-5' for regex 'gtk+-3.0'
Note, selecting 'gir1.2-javascriptcoregtk-3.0' for regex 'gtk+-3.0'
Note, selecting 'libalien-wxwidgets-perl' instead of 'wxperl-gtk-3-0-4-uni-gcc-3-4'
```


##### Testing the cache


```bash
nix store ping --store https://cache.nixos.org
```
Refs.:
- https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-store-ping.html

There could exist other "stores":
```bash
nix store ping --store local
```

```bash
nix store ping --store daemon
```

```bash
nix store ping --store ssh://mac1
```



```bash
nix \
store \
verify \
--store https://cache.nixos.org/ \
"$(nix eval --raw nixpkgs#hello)"
```


```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
--recursive \
"$(nix eval --raw nixpkgs#gtk3.dev)"/lib/pkgconfig/
```

```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
--recursive \
/nix/store/spy13ngvs1fyj82jw2w3nwczmdgcp3ck-firefox-23.0.1
```
Refs.:
- http://sandervanderburg.blogspot.com/2013/09/managing-user-environments-with-nix.html


```bash
curl https://cache.nixos.org/spy13ngvs1fyj82jw2w3nwczmdgcp3ck.narinfo
```


```bash
StorePath: /nix/store/spy13ngvs1fyj82jw2w3nwczmdgcp3ck-firefox-23.0.1
URL: nar/1bn124pan70p8w126swj84bafyn1spb5660l0wvcrpr9v6gy5amg.nar.xz
Compression: xz
FileHash: sha256:1bn124pan70p8w126swj84bafyn1spb5660l0wvcrpr9v6gy5amg
FileSize: 2965932
NarHash: sha256:48c431b99d5d8117a04932caa3416e876a5009f9c82f2cf23161eded196a09f8
NarSize: 6765008
References: 2mbpl01qzsk9kpdsxhi2flkpv0yhfc2q-atk-2.8.0 4g734xfwcv0h550g0cyjrzxyz1ryvgkk-freetype-2.4.11 67d3nrvv939mrjmf3y5pb4x097hcxcp6-glib-2.36.1 7mjplwq1r0agngqj27
Deriver: 1ksc4ijx4sa59lzj42qa23b1pp04wl5a-firefox-23.0.1.drv
System: x86_64-linux
Sig: cache.nixos.org-1:NsZ1Bt7Ikef5Y0hyAVDsf+YbVAIzhidNd5K2JQFgAmz3JNY/oFpCssgyXVp7ItHKfURId9AaxiHF0skDFiYLDg==
```


```bash
nix shell nixpkgs#hydra-check
```


```bash
hydra-check --arch x86_64-linux --channel nixos/release-13.10 hello
```

```bash
hydra-check --arch x86_64-linux --channel nixos/release-14.04 firefox
```



```bash
hydra-check --arch x86_64-linux --channel master firefox
```

Interesting urls:
- https://status.nixos.org
- https://hydra.nixos.org/build/103222205#tabs-details
- https://hydra.nixos.org/eval/1449?filter=gcc&compare=1283&full=#tabs-still-succeed
- https://hydra.nixos.org/job/nixos/trunk-combined/tested

```bash
# HYDRA_BUILD_ID=103222205
HYDRA_BUILD_ID=303510

curl \
-H "Content-Type: application/json" \
https://hydra.nixos.org/build/"${HYDRA_BUILD_ID}"#tabs-details | jq -r '.buildoutputs.out.path'
```

```bash
HYDRA_BUILD_ID=309392

curl \
-H "Content-Type: application/json" \
https://hydra.nixos.org/build/"${HYDRA_BUILD_ID}"#tabs-details | jq -r '.buildoutputs.out.path'
```

```bash
/nix/store/zfga9bvjrs810150kqp6kclyzr5qrscs-firefox-3.6
```

```bash
nix profile install /nix/store/spy13ngvs1fyj82jw2w3nwczmdgcp3ck-firefox-23.0.1
```

```bash
nix profile install /nix/store/11f84ip9jkcdsahvaqzgp43zjafzzliy-firefox-39.0.3
```

```bash
git ls-remote https://github.com/nixos/nixpkgs-channels
```

Refs.:
- https://github.com/NixOS/nixpkgs/issues/54924#issuecomment-473726288
- https://github.com/NixOS/nix/issues/2431#issuecomment-613441385
- https://discourse.nixos.org/t/how-to-check-hydra-build-status-of-pull-requests/8793



##### Digging in ancients nixpkgs versions, 10+ years ago


```bash
git clone -b release-14.12 --single-branch https://github.com/NixOS/nixpkgs.git \
&& cd nixpkgs \
&& nix-instantiate --eval --json --expr 'with import ./. {}; firefox.outPath'
```
Refs.:
- https://stackoverflow.com/a/46173041

Tried it with `nix-instantiate . -A firefox | cut -d'.' -f1-3` and with 
`nix-instantiate ./. -A firefox.outPath | cut -d'.' -f1-3` but finally it gives
to the "outPath" hash `nix-instantiate --eval --expr 'with import ./. {}; firefox.outPath'`

```bash
nix path-info --closure-size --eval-store auto 'nixpkgs#glibc^*'
```

```bash
nix path-info --closure-size --json --eval-store auto /nix/store/11f84ip9jkcdsahvaqzgp43zjafzzliy-firefox-39.0.3 
# | jq 'map(.narSize) | add'
```

```bash
nix path-info --json --closure-size $(nix eval --raw nixpkgs#hello.outPath) | jq .
```

#### Non nixpkgs flakes tests

```bash
nix \
run \
github:edolstra/dwarffs -- --version
```

```bash
nix \
flake \
show \
github:GNU-ES/hello
```

```bash
nix \
shell \
github:GNU-ES/hello \
--command \
hello
```

```bash
nix \
build \
--store "$HOME" \
github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp
```

```bash
nix \
develop \
github:ES-Nix/nix-flakes-shellHook-writeShellScriptBin-defaultPackage/65e9e5a64e3cc9096c78c452b51cc234aa36c24f \
--command \
podman \
run \
--interactive=true \
--tty=true \
alpine:3.14.2 \
sh \
-c 'uname --all && apk add --no-cache git && git init'
```

```bash
nix \
build \
github:ES-Nix/poetry2nix-examples/2cb6663e145bbf8bf270f2f45c869d69c657fef2#poetry2nixOCIImage
```

```bash
nix \
build \
github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp
```

```bash
nix \
develop \
github:ES-Nix/fhs-environment/enter-fhs
```

```bash
nix \
build \
github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso
```

```bash
nix \
build \
github:ES-Nix/nixosTest/2f37db3fe507e725f5e94b42a942cdfef30e5d75#checks.x86_64-linux.test-nixos
```


```bash
nix \
develop \
--refresh \
github:ES-Nix/NixOS-environments/box \
--command \
bash \
-c \
"nixos-box-volume"
```

Huge build:
```bash
nix \
build \
github:PedroRegisPOAR/NixOS-configuration.nix#nixosConfigurations.pedroregispoar.config.system.build.toplevel
```


### Nesting



```bash
nix \
run \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm
```


```bash
command -v podman || sudo apt-get update && sudo apt-get install -y podman

podman \
run \
--log-level=error \
--env STORAGE_DRIVER=vfs \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=false \
--tty=true \
--rm=true \
--security-opt seccomp=unconfined \
--security-opt label=disable \
--user=0 \
--volume=/proc/:/proc/:rw \
--volume="$(pwd)":/code \
--workdir=/code \
docker.io/nixpkgs/nix-flakes \
bash \
-c \
"
# nix flake metadata github:NixOS/nix --json | jq --join-output '.url'

nix \
build \
github:NixOS/nix/1dd7253133c4dfd2e7a16ad6fe505442cef38a5b#nix-static \
--option substitute true \
--option sandbox false 


RESULT_PATH='result/bin/nix'

RESULT_SHA256='17906356fbb4f19bf57d1c539f51725899f98b4944539fa03c8dbe5e001ed70f'
RESULT_SHA512='c18c56a868b54d1c3bcfb7e1c58143b2817a3eabd60497c9cbd635f502c5d5c228a672f403d884a15e8e6e5b5c143fecbfe75c401a3db1746b9c3d7f9306fbe9'

echo \"\${RESULT_SHA256}\"'  '\"\${RESULT_PATH}\" | sha256sum -c \
&& echo \"\${RESULT_SHA512}\"'  '\"\${RESULT_PATH}\" | sha512sum -c \
&& cp -v \"\${RESULT_PATH}\" /code/nix-static
"

#nix \
#run \
#--refresh \
#github:ES-Nix/nix-oci-image/nix-static-minimal#oci-podman-openssh-server
#sudo cp -v /code/nix .

test -d /nix || sudo mkdir -v /nix && sudo chown -Rv "$(id -u)":"$(id -g)" /nix

./nix-static \
--extra-experimental-features 'nix-command flakes' \
run \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#hello

#./nix-static \
#--extra-experimental-features 'nix-command flakes' \
#store \
#gc \
#-v

sudo rm -fr /nix/*
du -hs /nix/

./nix-static \
--extra-experimental-features 'nix-command flakes' \
run \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#hello

sudo rm -fr /nix/*
du -hs /nix/

./nix-static \
--extra-experimental-features 'nix-command flakes' \
run \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#hello


export NIXPKGS_ALLOW_UNFREE=1 \
&& ./nix-static \
      --extra-experimental-features 'nix-command flakes' \
      profile \
      install \
      --impure \
      github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#python3Full

python3 --version


#./nix-static \
#--extra-experimental-features 'nix-command flakes' \
#build \
#github:ES-Nix/poetry2nix-examples/2cb6663e145bbf8bf270f2f45c869d69c657fef2#poetry2nixOCIImage

# Broken, no idea why...
#./nix-static \
#--extra-experimental-features 'nix-command flakes' \
#--option sandbox true \
#build \
#--expr \
#'
#(
#  (
#    (
#      builtins.getFlake "github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c"
#    ).lib.nixosSystem {
#        system = "x86_64-linux";
#        modules = [ "${toString (builtins.getFlake "github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" ];
#    }
#  ).config.system.build.isoImage
#)
#'
#
#EXPECTED_SHA256='b09bf53a018fade68f6dbe200da5a40a5c4f24eb7745356231696be55d412700'
#EXPECTED_SHA512='70b5c7bc32ec4f89872161fbb931e181212cac1c7527dc4ef1e32dfa418a122d3f8e9f4b451ab480a11ed2ba7d7dd3194eb80f0ae1da214bc4f4bf42d0badc09'
#ISO_PATTERN_NAME="$(echo result/iso/nixos-22.05.*-x86_64-linux.iso)"
#
#echo "${EXPECTED_SHA256}"'  '"${ISO_PATTERN_NAME}" | sha256sum -c
#echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c


./nix-static \
--extra-experimental-features 'nix-command flakes' \
run \
github:edolstra/dwarffs -- --version



#echo 'Start kvm stuff...' \
#&& getent group kvm || sudo groupadd kvm \
#&& sudo usermod --append --groups kvm "$USER" \
#&& echo 'End kvm stuff!'
#
#./nix-static \
#--extra-experimental-features 'nix-command flakes' \
#build \
#github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso
```

```bash
nix \
run \
--refresh \
github:ES-Nix/nix-qemu-kvm/dev#ubuntu-qemu-kvm
```

```bash
command -v podman || sudo apt-get update && sudo apt-get install -y podman

podman \
run \
--log-level=error \
--env STORAGE_DRIVER=vfs \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env=PATH=/root/.nix-profile/bin:/usr/bin:/bin \
--interactive=true \
--privileged=false \
--tty=true \
--rm=true \
--security-opt seccomp=unconfined \
--security-opt label=disable \
--user=0 \
--volume=/proc/:/proc/:rw \
--volume="$(pwd)":/code \
--workdir=/code \
docker.io/nixpkgs/nix-flakes \
bash \
-c \
"
# nix flake metadata nix --json | jq --join-output '.url'

nix \
build \
github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c#pkgsStatic.nix \
--option substitute true \
--option sandbox false 


RESULT_PATH='result/bin/nix'

RESULT_SHA256='95bf4be07d0f1a4f8368056c0cabd4cf69121172b79591726fe0cd9eb3eb96bf'
RESULT_SHA512='93f63e5003ba81c11a15f7188bc5930de824f80f8f2e4394506b1ee7ed20391d4de13ac295966dac2e6f723314686273972d50d73b709e78df5a555641ea632a'

echo \"\${RESULT_SHA256}\"'  '\"\${RESULT_PATH}\" | sha256sum -c \
&& echo \"\${RESULT_SHA512}\"'  '\"\${RESULT_PATH}\" | sha512sum -c \
&& cp -v \"\${RESULT_PATH}\" /code/nix-pkgs-static
"
```



```bash
mkdir -pv -m 0770 "${HOME}"/bin

mv -v nix-pkgs-static "${HOME}"/bin/nix

echo 'export PATH="${HOME}"/bin:"${PATH}"' >> ~/."$(ps -ocomm= -q $$)"rc \
&& . ~/."$(ps -ocomm= -q $$)"rc

test -d /nix || sudo mkdir -v /nix && sudo chown -Rv "$(id -u)":"$(id -g)" /nix

nix \
profile \
install \
nixpkgs#pkgsStatic.busybox \
--option experimental-features 'nix-command flakes'

# It is, lets say, not so beautiful 
busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix

nix \
profile \
remove \
"$(nix eval --raw nixpkgs#pkgsStatic.busybox)"

nix flake --version
```

```bash
nix \
build \
github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c#pkgsStatic.nix
```

Really hard build:
```bash
nix \
build \
github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c#pkgsStatic.nix \
--option substitute false
```



```bash
nix \
run \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#hello

sudo rm -fr /nix/*
du -hs /nix/

nix \
run \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#hello


nix \
run \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#xorg.xclock


nix \
profile \
install \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#python3Full

python3 --version

export NIXPKGS_ALLOW_UNFREE=1 \
&& nix \
profile \
install \
--impure \
github:NixOS/nixpkgs/f1c9c23aad972787f00f175651e4cb0d7c7fd5ea#geogebra

#./nix-pkgs-static \
#--extra-experimental-features 'nix-command flakes' \
#build \
#github:ES-Nix/poetry2nix-examples/2cb6663e145bbf8bf270f2f45c869d69c657fef2#poetry2nixOCIImage

nix \
run \
github:edolstra/dwarffs -- --version
```



#### --store "${HOME}"




```bash
mkdir -pv -m 0770 "${HOME}"/bin

echo 'export PATH="${HOME}"/bin:"${PATH}"' >> . ~/."$(ps -ocomm= -q $$)"rc \
&& . ~/."$(ps -ocomm= -q $$)"rc

mv nix-pkgs-static "${HOME}"/bin/nix

ln -sfv "${HOME}"/nix/var/nix/profiles/per-user/"${USER}"/ "${HOME}"/.nix-profile

./nix-pkgs-static \
--extra-experimental-features 'nix-command flakes' \
--store "${HOME}" \
profile \
install \
github:NixOS/nixpkgs/40e2b1ae0535885507ab01d7a58969934cf2713c#hello
```


### Install zsh


#### From `apt-get`

Just to inspect some stuff:
```bash
[ -z "$USER" ] || echo '"$USER" variable is empty or not set'

cat /etc/passwd | grep sh
```

```bash
sudo su -c 'apt-get update && apt-get install -y zsh' \
&& echo \
&& sudo chsh -s /usr/bin/zsh "$USER" \
&& echo \
&& curl -LO https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
&& chmod +x install.sh \
&& yes | ./install.sh \
&& rm install.sh \
&& touch ~/.zshrc \
&& zsh
```
Refs: 
- https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
- https://ohmyz.sh/#install
- https://stackoverflow.com/a/25728814


```bash
env | sort
```

```bash
ps -aux | grep apt
```

cat /etc/passwd | grep sh
From: https://askubuntu.com/a/1206350

stat "$(which chsh)"


https://unix.stackexchange.com/questions/111365/how-to-change-default-shell-to-zsh-chsh-says-invalid-shell


```bash
nix profile install nixpkgs#zsh
cat /etc/shells
command -v zsh | sudo tee -a /etc/shells
cat /etc/shells
chsh -s "$(which zsh)"
sudo reboot
```

```bash
nix profile install nixpkgs#fzf
```

### 


```bash
nix profile install nixpkgs#nixFlakes
```

```bash
nix eval --raw nixpkgs#nixFlakes
```


```bash
nix profile install nixpkgs/8635793fceeb6e4b5cf74e63b2dfde4093d7b9cc#python3
nix profile install nixpkgs/8635793fceeb6e4b5cf74e63b2dfde4093d7b9cc#poetry
```

```bash
nix profile install nixpkgs/ca5d520a0fa87e80c871a105d21dff3e9af3e57d#poetry
nix profile install nixpkgs#poetry

python --version

nix eval --raw nixpkgs/8635793fceeb6e4b5cf74e63b2dfde4093d7b9cc#poetry

nix profile remove python3.8

rm -frv ~/test-poetry/
```

```bash
python --version \
&& poetry --version \
&& mkdir -p ~/test-poetry \
&& cd ~/test-poetry \
&& poetry init --no-interaction \
&& poetry lock \
&& poetry show --tree \
&& poetry add flask==2.0.1 \
&& poetry lock \
&& poetry show --tree
```


## TODOs

- Tests, we need tests! Use `nix flake check`?
- Make the installer be as POSIX as possible, and installable in the [toybox](http://landley.net/toybox/about.html) 
   and his talk [Toybox: Writing a New Command Line From Scratch](https://www.youtube.com/watch?v=SGmtP5Lg_t0). 
   Looks like [nix has one static binary now](https://discourse.nixos.org/t/tweag-nix-dev-update-6/11195), how to 
   throw it in an OCI image?

TODO: 
- https://github.com/NixOS/nixpkgs/issues/37157, followed to https://github.com/nix-community/nix-user-chroot

[Packaging with Nix](https://youtu.be/Ndn5xM1FgrY?t=1882)
TODO: 
- help with it https://github.com/NixOS/nixpkgs/issues/18089
- https://github.com/NixOS/nix/issues/2659



```bash
mkdir -pv ~/my-nixpkgs \
&& nix flake clone github:PedroRegisPOAR/nixpkgs/nixpkgs-unstable --dest my-nixpkgs \
&& cd ~/my-nixpkgs



git rev-list -n 20 21.11 | rg $(git rev-list -n 1 21.11)
git checkout $(git rev-list -n 1 21.11)
git show -s 47cd6702934434dd02bc53a67dbce3e5493e33a2


# https://git-scm.com/docs/pretty-formats
git show -s $(git rev-list -n 1 21.11) --pretty='format:%at' | cat
git show -s 47cd6702934434dd02bc53a67dbce3e5493e33a2 --pretty='format:%at' | cat


git log origin/nixos-21.11 | tail -1


git ls-remote git://github.com/NixOS/nixpkgs.git nixos-21.11 | tail -1 | cut -f 1


SHA256=$(git ls-remote git://github.com/NixOS/nixpkgs.git nixos-21.11 | tail -1 | cut -f 1)

nix flake metadata github:NixOS/nixpkgs/"${SHA256}"


github:NixOS/nixpkgs/47cd6702934434dd02bc53a67dbce3e5493e33a2

nix flake update --override-input nixpkgs github:NixOS/nixpkgs/47cd6702934434dd02bc53a67dbce3e5493e33a2


nix run github:NixOS/nixpkgs/47cd6702934434dd02bc53a67dbce3e5493e33a2#nodejs-12_x -- --version



nix flake metadata github:NixOS/nixpkgs/nixos-21.11 --json | jq --join-output '.revision'


# Did not work! The '-' in front of committerdate does not work.
# git ls-remote git://github.com/NixOS/nixpkgs.git nixos-unstable --sort=-committerdate

LATEST_COMMIT_SHA256_IN_BRANCH=git ls-remote --heads origin nixos-21.11
47cd6702934434dd02bc53a67dbce3e5493e33a2

git ls-remote git://github.com/


# git ls-remote --tags git://github.com/NixOS/nixpkgs.git "refs/tags/21.11^{}" | cut -f 1
# https://stackoverflow.com/questions/64268055/when-listing-remote-tags-in-git-what-does-signify
FIRST_COMMIT_SHA256_IN_BRANCH=$(git ls-remote --tags git://github.com/NixOS/nixpkgs.git "refs/tags/21.11" | cut -f 1)


git log --pretty=oneline nixpkgs-unstable > 1
git log --pretty=oneline nixos-21.11 > 2


git rev-parse "$(diff 1 2 | tail -1 | cut -c 3-42)"^


diff -u <(echo 'a\nb\n') <(echo 'a\nb\nc')
diff -u <(echo 'a\nb\n') <(echo 'a\nb\nc\nd\ne')
comm <(echo 'a\nb\n') <(echo 'a\nb\nc\nd\ne')

diff -y -b --suppress-common-lines <(echo 'a\nb\nx\ny\nz') <(echo 'a\nb\nc\nd\ne\nm\nn\no') | head -1 | cut -d'|' -f2 | tr -d '\t'


diff -u <(git rev-list --first-parent nixos-21.11 | sort) <(git rev-list --first-parent nixpkgs-unstable | sort)

git log --pretty=oneline nixos-21.11 | head -n 20


comm -3 <(git rev-list --first-parent nixos-21.11 | sort) <(git rev-list --first-parent nixpkgs-unstable | sort)


diff -y -b --suppress-common-lines <(git rev-list --first-parent nixos-21.11 | sort) <(git rev-list --first-parent nixpkgs-unstable | sort) | cut -f1 | head -1
diff -y -b --suppress-common-lines <(git rev-list --first-parent nixpkgs-unstable | sort) <(git rev-list --first-parent nixos-21.11 | sort) | cut -f1 | head -1

diff -y -b --suppress-common-lines <(git rev-list --first-parent nixpkgs-unstable) <(git rev-list --first-parent nixos-21.11) | cut -f1 | head -1
diff -y -b --suppress-common-lines <(git rev-list --first-parent nixos-21.11) <(git rev-list --first-parent nixpkgs-unstable) | cut -f1 | head -1


git log --oneline --format=format:"%H" nixpkgs-unstable..nixos-21.11 | tail -n 1
git log --oneline --format=format:"%H" nixpkgs-unstable..nixos-21.11 | head -n 1


function n() {
    git log --reverse --pretty=%H nixos-21.11 | grep -A 1 $(git rev-parse HEAD) | tail -n1 | xargs git checkout
}


nix flake metadata --refresh github:NixOS/nixpkgs/$(git ls-remote git://github.com/NixOS/nixpkgs.git nixos-21.11 | tail -1 | cut -f 1)

git log --oneline --format=format:"%H" nixpkgs-unstable..nixos-21.11 | head -n 10


nix run github:NixOS/nixpkgs/e3e553c5f547f42629739d0491279eeb25e25cb2#nodejs-12_x -- --version
nix run github:NixOS/nixpkgs/7a200487a17af17a0774257533c979a1daba858d#nodejs-12_x -- --version
nix run github:NixOS/nixpkgs/7a6f7df2e4ef9c7563b73838c7f86a1d6dd0755b#nodejs-12_x -- --version

nix run github:NixOS/nixpkgs/e3e553c5f547f42629739d0491279eeb25e25cb2#python3 -- --version
nix run github:NixOS/nixpkgs/7a6f7df2e4ef9c7563b73838c7f86a1d6dd0755b#python3 -- --version

nix run github:NixOS/nixpkgs/e3e553c5f547f42629739d0491279eeb25e25cb2#python37 -- --version
nix run github:NixOS/nixpkgs/7a6f7df2e4ef9c7563b73838c7f86a1d6dd0755b#python37 -- --version

nix run github:NixOS/nixpkgs/e3e553c5f547f42629739d0491279eeb25e25cb2#python38 -- --version
nix run github:NixOS/nixpkgs/7a6f7df2e4ef9c7563b73838c7f86a1d6dd0755b#python38 -- --version

nix run github:NixOS/nixpkgs/e3e553c5f547f42629739d0491279eeb25e25cb2#python39 -- --version
nix run github:NixOS/nixpkgs/7a6f7df2e4ef9c7563b73838c7f86a1d6dd0755b#python39 -- --version


nix run github:NixOS/nixpkgs/release-20.03#python3 -- --version
nix run github:NixOS/nixpkgs/release-20.09#python3 -- --version
nix run github:NixOS/nixpkgs/release-21.05#python3 -- --version
nix run github:NixOS/nixpkgs/release-21.11#python3 -- --version

nix run github:NixOS/nixpkgs/nixos-20.03#python3 -- --version
nix run github:NixOS/nixpkgs/nixos-20.09#python3 -- --version
nix run github:NixOS/nixpkgs/nixos-21.05#python3 -- --version
nix run github:NixOS/nixpkgs/nixos-21.11#python3 -- --version
nix run github:NixOS/nixpkgs/nixpkgs-unstable#python3 -- --version

nix run github:NixOS/nixpkgs/nixos-21.11#pkgsStatic.nix
nix run github:NixOS/nixpkgs/nixos-22.05#pkgsStatic.nix
nix run github:NixOS/nixpkgs/nixpkgs-unstable#pkgsStatic.nix

nix run github:NixOS/nix#nix-static -- flake metadata github:NixOS/nixpkgs/nixos-21.11

nix run github:NixOS/nix#nix-static -- run github:NixOS/nixpkgs/nixos-22.05#python3 -- --version
nix run github:NixOS/nix#nix-static -- show-config --json


nix flake metadata github:NixOS/nixpkgs/nixos-21.11 --json | jq --join-output '.url'
nix flake metadata github:NixOS/nixpkgs/nixos-22.05 --json | jq --join-output '.url'
```



```bash
nix \
run \
--impure \
--expr \
'
  (  
    with legacyPackages.${builtins.currentSystem};
    let
      nixpkgs = (with builtins.getFlake "nixpkgs");
      overlay = final: prev: {
        hello = prev.hello.overrideAttrs (oldAttrs: with final; {
            postInstall = oldAttrs.postInstall + "${prev.hello}/bin/hello Installation complete";
          }
        );
      };
  
      pkgs = import "${ toString (builtins.getFlake "nixpkgs")}" { overlays = [ overlay ]; };
  
    in
      pkgs.hello
  )
'
```


nix \
run \
--impure \
--expr \
'with (import <nixpkgs> {}); let
  overlay = final: prev: {
    openssl = prev.openssl.override {
      static = true;
    };
  };

  pkgs = import <nixpkgs> { overlays = [ overlay ]; };

in
  pkgs.hello'

nix run --impure --expr '(import <nixpkgs> { overlays = [(final: prev: { static = true; })]; }).hello'

```bash
nix \
run \
--impure \
--expr \
'(
  import "${ toString (builtins.getFlake "nixpkgs")}" { overlays = [(final: prev: { static = true; })]; }
).hello'
```

```bash
nix \
run \
--impure \
--expr \
'
(
  import "${ toString (builtins.getFlake "nixpkgs")}" { overlays = [(final: prev: 
    { 
      static = true;
      postInstall = prev.postInstall + "${prev.hello}/bin/hello Installation complete";
    })]; 
    }
).hello
'
```


```bash
# nix flake metadata github:NixOS/nixpkgs/nixos-22.05 --json | jq --join-output '.url'
nix \
run \
--impure \
--expr \
'(
  import "${ toString (builtins.getFlake "nixpkgs")}" { overlays = [(final: prev: { static = true; })]; }
).openssl'
```


nix-instantiate \
--option pure-eval true \
--eval \
--impure \
--expr \
'with (import <nixpkgs> {}); let
  overlay = final: prev: {
    openssl = prev.openssl.override {
      static = true;
    };
  };

  pkgs = import (with builtins.getFlake "nixpkgs";) { overlays = [ overlay ]; };

in
  pkgs.hello'

```bash
nix \
build \
--impure \
--expr \
'(
with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem};
hello
)'
```



```bash
nix \
build \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs";  with legacyPackages.${builtins.currentSystem}; 
pkgsStatic.hello
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
  (hello.override { withStatic = true; })
)'
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.nix.override { 
    storeDir = "/home/ubuntu";
    stateDir = "/home/ubuntu";
    confDir = "/home/ubuntu";
  })
)' \
&& result/bin/nix \
run \
--extra-experimental-features 'nix-command flakes' \
"github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780"#hello
```



```bash
cat > Containerfile << 'EOF'
FROM ubuntu:22.04

RUN apt-get update -y \
&& apt-get install --no-install-recommends --no-install-suggests -y \
     ca-certificates \
     curl \
     file \
 && apt-get -y autoremove \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

RUN addgroup abcgroup --gid 4455  \
 && adduser -q \
     --gecos '"An unprivileged user with an group"' \
     --disabled-password \
     --ingroup abcgroup \
     --uid 3322 \
     abcuser

# The /nix is ignored by nix profile even if it is created
# RUN mkdir /nix && chmod 0777 /nix && chown -v abcuser: /nix

USER abcuser
WORKDIR /home/abcuser
ENV USER="abcuser"
ENV PATH=/home/abcuser/.nix-profile/bin:/home/abcuser/.local/bin:"$PATH"

# Not DRY, I know
RUN mkdir -pv $HOME/.local/bin \
 && export PATH=/home/abcuser/.local/bin:"$PATH" \
 && curl -L https://hydra.nixos.org/build/188965270/download/2/nix > nix \
 && mv nix /home/abcuser/.local/bin \
 && chmod +x /home/abcuser/.local/bin/nix \
 && mkdir -p ~/.config/nix \
 && echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf

EOF


podman \
build \
--file=Containerfile \
--tag=unprivileged-ubuntu22 .
```


```bash
podman \
run \
--privileged=true \
--interactive=true \
--tty=true \
--rm=true \
localhost/unprivileged-ubuntu22:latest \
bash \
-c \
'
nix flake --version 
'
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/b139e44d78c36c69bcbb825b20dbfa51e7738347";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.nix.override {
    storeDir = "/home/abcuser";
    stateDir = "/home/abcuser";
    confDir = "/home/abcuser";
  })
)'
```


```bash
cp ~/.local/bin/nix ~/.local/bin/nix-old
FULL_PATH_TO_NIX="$(echo "${HOME}""/.local/share/nix/root/nix/store/$(echo "$(readlink result)" | cut -d'/' -f4-)"/bin/nix)"

cp $FULL_PATH_TO_NIX ~/.local/bin/

nix \
profile \
install \
"github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780"#hello
```

```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/9a17f325397d137ac4d219ecbd5c7f15154422f4";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.nix.override {
    stateDir = "/home/abcuser/.local/share/nix/root/nix/var";
    storeDir = "/home/abcuser/.local/share/nix/root/nix/store";
  })
)'
```


```bash
test -d "${HOME}"/.local/share/nix/root/nix/var/nix/profiles/per-user/"${USER}"/profile || mkdir -pv "${HOME}"/.local/share/nix/root/nix/var/nix/profiles/per-user/"${USER}"/profile
ln -sfv "${HOME}"/.local/share/nix/root/nix/var/nix/profiles/per-user/"${USER}"/profile "${HOME}"/.nix-profile

file "${HOME}"/.nix-profile | grep '/.nix-profile: symbolic link to /home/'


nix build nixpkgs#hello
# test -d "${HOME}"/.nix-profile || mkdir -pv "${HOME}"/.nix-profile
ln -sfv "${HOME}"/.local/share/nix/root"$(readlink result)"/bin "${HOME}"/.nix-profile/bin
# ln -sfv "${HOME}"/.local/share/nix/root"$(readlink result)"/bin/hello "${HOME}"/.nix-profile/bin/hello

# file "${HOME}"/.nix-profile/bin/hello | grep '/.nix-profile/bin: symbolic link to /home/'
```


https://github.com/YorikSar/nixos-vm-on-macos/tree/24025c73634e580045744c169be1be167b12fe50#broken-sudo

```bash
# WIP
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/9a17f325397d137ac4d219ecbd5c7f15154422f4";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.nix.overrideAttrs
    (old:
      {
        stateDir = "/home/abcuser/.local/share/nix/root/nix/var";
        storeDir = "/home/abcuser/.local/share/nix/root/nix/store";
        makeFlags = (old.makeFlags or []) ++ ["USE_SYSTEMD=no"];
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.nix.override {
    storeDir = "/home/abcuser/.nix/store";
    stateDir = "/home/abcuser/.nix/var";
    confDir = "/home/abcuser/.nix/etc";
  })
)'
```
https://rgoswami.me/posts/local-nix-no-root/#patches


```bash
nix \
build \
--store "${HOME}" \
--impure \
--expr \
'(                                                                                              
  with builtins.getFlake "github:NixOS/nixpkgs/9a17f325397d137ac4d219ecbd5c7f15154422f4"; 
  with legacyPackages.${builtins.currentSystem}; 
  (pkgsStatic.nix.override { 
    storeDir = "/home/ubuntu/nix/store";
    stateDir = "/home/ubuntu/nix/var";
    confDir = "/home/ubuntu";
  })
)'
NAME="$(echo "${HOME}""/nix/store/$(echo "$(readlink result)" | cut -d'/' -f4-)"/bin/nix)"
$NAME run --extra-experimental-features 'nix-command flakes' nixpkgs#hello
```



```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (pkgsStatic.python3.override 
    { 
      reproducibleBuild = true; 
      rebuildBytecode = false;
    }
  )
)'
```


```bash
nix \
build \
--store "${HOME}" \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (nix.override { 
    storeDir = "/home/ubuntu";
    stateDir = "/home/ubuntu";
    confDir = "/home/ubuntu";
  })
)'
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
-- \
  build \
  --store "${HOME}" \
  --impure \
  --expr \
  '(
    with builtins.getFlake "nixpkgs"; 
    with legacyPackages.${builtins.currentSystem}; 
    (pkgsStatic.nix.override { 
      storeDir = "/home/ubuntu";
      stateDir = "/home/ubuntu";
      confDir = "/home/ubuntu";
    })
  )'
```


```bash
nix \
build \
--store "${HOME}" \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (pkgsStatic.nix.override { 
    storeDir = "/home/ubuntu";
    stateDir = "/home/ubuntu";
    confDir = "/home/ubuntu";
  })
)'
```


```bash
      storeDir = "/home/ubuntu/nix/store";
      stateDir = "/home/ubuntu/nix/var";
      confDir = "/home/ubuntu";
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
    pkgsStatic.nix      
)'
```


```bash
nix \
build \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
(SDL2.override { withStatic = true; }).dev)'
```


```bash
nix \
build \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
pkgsStatic.openssl
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
  with pkgsStatic; [ 
      openssl 
      hello 
    ]
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
  (sudo.override { pam = null; withInsults = true; })
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
  pkgsStatic.shadow.su        
)'
```

```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}.pkgsCross.aarch64-multiplatform.pkgsStatic;
  (shadow.override { pam = null; }).su
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
  (shadow.override { pam = null; }).su
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
  (openssl.override { static = true; })
)'
```

TODO:
nixpkgs#coreutils 


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs";
  with legacyPackages.${builtins.currentSystem}; 
  (
    buildFHSUserEnv { name = "fhs"; }
  )
)' \
--command \
fhs
```



```bash
# nix-shell -p "(steam.override { extraPkgs = pkgs: [pkgs.fuse]; nativeOnly = true;}).run"
# https://github.com/NixOS/nixpkgs/issues/32881#issuecomment-371815465

nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (steam.override { extraPkgs = pkgs: [pkgs.fuse]; nativeOnly = true;}).run
)'
```


```bash
nix \
shell \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
(gnused.overrideDerivation (oldAttrs: {
  name = "sed-4.2.2-pre";
  src = fetchurl {
    url = ftp://alpha.gnu.org/gnu/sed/sed-4.2.2-pre.tar.bz2;
    sha256 = "11nq06d131y4wmf3drm0yk502d2xc6n5qy82cg88rb9nqd2lj41k";
  };
  patches = [];
}))
)'
```


```bash
nix \
shell \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
(gnused.overrideAttrs (oldAttrs: {
  preFixup = (oldAttrs.preFixup or "") + "set -x";
}))
)'
```


```bash
nix \
shell \
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
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
  -- \
  shell \
  --store "${HOME}" \
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

NAME="$(echo "${HOME}""$(echo "$(readlink result)" | cut -d'/' -f4-)"/bin/hello)"

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (hello.overrideAttrs (oldAttrs: rec {
        separateDebugInfo = true;
      }
    )
  )
)' \
--command \
bash \
-c \
'file $(readlink -f $(which hello))'
```
From:
- https://youtu.be/6VepnulTfu8?t=477
- 



```bash
nix \
run \
nixpkgs#pkgsStatic.nix \
  -- \
  build \
  github:ES-Nix/nixosTest/2f37db3fe507e725f5e94b42a942cdfef30e5d75#checks.x86_64-linux.test-nixos  
```



```bash
nix build --impure --expr 'with (import ./. {system="x86_64-darwin";}); hello'
```
From:
- https://siraben.dev/2022/02/13/nix-flake-hacks.html

```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (pkgsStatic.python3Minimal.override 
    { 
      reproducibleBuild = true;
      tzdata = tzdata;
    }
  )
)'


FILE_NAME='result/bin/python'
EXPECTED_SHA256='c13ae01f9308daf5ccc27ec523e3b42fcd60cb1378a6c6d02a05d70d2ca3a28e'
EXPECTED_SHA512='1f869a5170972dd07bd350699bf8ac1bec9a071cb23ca2d6196a1d429a376d7b32c87cd51635120ddbbed582796465755cf0e02018b2cd84f5e36eeb611add63'

# sha256sum "${FILE_NAME}"
# sha512sum "${FILE_NAME}"

echo "${EXPECTED_SHA256}"'  '"${FILE_NAME}" | sha256sum -c
echo "${EXPECTED_SHA512}"'  '"${FILE_NAME}" | sha512sum -c

# Only python3Full is able?
# python -c 'from datetime import datetime; from zoneinfo import ZoneInfo; print(datetime.now(ZoneInfo("America/Recife")))'
```


```bash
nix \
shell \
--store "${HOME}" \
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
&& sha256sum result/bin/python
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
  -- \
  shell \
  --store "${HOME}" \
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
'file $(readlink -f $(which python3)) \
&& ldd $(readlink -f $(which python3))'
```

```bash
nix \
shell \
--impure \
--expr \
'(
with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
  [ 
    (python3.overrideAttrs 
      (oldAttrs: rec { 
          static = true;        
        }
      )
    )    
    bashInteractive
    coreutils    
    file
    glibc.bin 
    which
  ]
)' \
--command \
bash \
-c \
'file $(readlink -f $(which python3)) \
&& ldd $(readlink -f $(which python3))'
```

```bash
nix \
shell \
--impure \
--expr \
  '(
      with builtins.getFlake "nixpkgs"; 
      with legacyPackages.${builtins.currentSystem}; 
        (python3Minimal.override 
        (oldAttrs: { 
          tzdata = tzdata;
          rebuildBytecode = false;
          stripTests = true;
          stripIdlelib = true;
          stripConfig = true;
          stripTkinter = true;
          reproducibleBuild = true;
          static = true;

          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ gcc ];
        }
      )
    )
  )'
```


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
    (python3Minimal.overrideAttrs 
      (oldAttrs: { 
          tzdata = tzdata;
          rebuildBytecode = false;
          stripTests = true;
          stripIdlelib = true;
          stripConfig = true;
          stripTkinter = true;
          reproducibleBuild = true;
          static = true;
        
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ gcc ];
        }
      )    
    )
)' \
--command \
bash \
-c \
'file $(readlink -f $(which python3)) \
&& ldd $(readlink -f $(which python3))'
```

```bash
nix \
run \
--store "${HOME}" \
nixpkgs#pkgsStatic.nix \
  -- \
  shell \
  --store "${HOME}" \
  --impure \
  --expr \
  '(
      with builtins.getFlake "nixpkgs"; 
      with legacyPackages.${builtins.currentSystem}; 
        (python3Minimal.override 
        (oldAttrs: { 
          tzdata = tzdata;
          rebuildBytecode = false;
          stripTests = true;
          stripIdlelib = true;
          stripConfig = true;
          stripTkinter = true;
          reproducibleBuild = true;
          static = true;
        
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ gcc ];
        }
      )    
    )
  )' \
--command \
bash \
-c \
'file $(readlink -f $(which python3)) \
&& ldd $(readlink -f $(which python3))'
```

```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (python39Full.override 
    { 
      stripTkinter = false;
    }
  )
)' \
&& timeout 15 result/bin/python -c 'import tkinter as tk; tk.Tk().mainloop()' || test $? -eq 124 || echo 'Error in tkinter'
```


```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (python39Full.override  
    { 
      stripTkinter = true;
    }
  )
)' \
&& timeout 15 result/bin/python -c 'import tkinter as tk; tk.Tk().mainloop()' || test $? -eq 124 || echo 'Error in tkinter'
```

```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
    (python39Full.overrideAttrs 
      (oldAttrs: {                             
          buildInputs = oldAttrs.buildInputs or [] ++ [ gcc ];
        }
      )
    ).override { stripTkinter = true; }
)' \
--command \
bash \
-c \
'
file $(readlink -f $(which python3)) \
&& ldd $(readlink -f $(which python3)) \
&& timeout 15 result/bin/python -c "import tkinter as tk; tk.Tk().mainloop()" || test $? -eq 124 || echo "Error in tkinter"
'
```


```bash
nix \
shell \
nixpkgs#pkgsStatic.python3Minimal \
--command \
python \
-c \
'import zlib; print(zlib.ZLIB_RUNTIME_VERSION)'
```
Refs.:
- https://docs.python.org/3/library/zlib.html



```bash
nix-instantiate \
--option pure-eval true \
--eval \
--impure \
--expr \
'
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
    python3.withPackages (ps: with ps; [ numpy scipy ])
'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/747927516efcb5e31ba03b7ff32f61f6d47e7d87";
  with legacyPackages.x86_64-linux;
  python3.withPackages (pypks: with pypks; [ mmh3 ])
)' \
--command \
python3 -c 'import mmh3; print(mmh3.__version__)'
```

 

```bash
{ nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [ numpy ])
)' \
--command \
python3 -c 'import numpy as np; np.show_config(); print(np.__version__)'
} | curl -F 'f:1=<-' ix.io
```


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.${builtins.currentSystem};
  python3.withPackages (p: with p; [ pandas ])
)' \
--command \
python3 -c 'import pandas as pd; pd.DataFrame(); print(pd.__version__)'
```


```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [ mmh3 ])
)' \
--command \
python3 -c 'import mmh3; print(mmh3.hash128(bytes(123)))'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e"; 
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [ geopandas ])
)' \
--command \
python3 -c 'import geopandas as gpd; print(gpd.__version__)'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [ tensorflow ])
)' \
--command \
python3 -c 'import tensorflow as tf; print(tf.Variable(tf.zeros([4, 3]))); print(tf.__version__)'
```


Does not exist.
```bash
# github:NixOS/nixpkgs/release-21.05
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/022caabb5f2265ad4006c1fa5b1ebe69fb0c3faf";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [opencv2])
)' \
--command \
python3 -c 'import cv2'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [opencv3])
)' \
--command \
python3 -c 'import cv2 as cv3; print(cv3.__version__)'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [opencv4])
)' \
--command \
python3 -c 'import cv2 as cv4; print(cv4.__version__)'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [scikitimage opencv3 numpy])
)' \
--command \
python3 -c 'from skimage.metrics import structural_similarity; import cv2; import numpy as np'
```

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [scikitimage opencv3 numpy jupyter])
)' \
--command \
python3 -c 'from skimage.metrics import structural_similarity; import cv2; import numpy as np'
```

```bash
nix \
build \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [
                                     geopandas
                                     jupyter
                                     jupyterlab
                                     keras
                                     matplotlib
                                     nltk
                                     numpy
                                     opencv4
                                     pandas
                                     plotly
                                     scikitlearn
                                     scikitimage
                                     scipy
                                     sympy
                                     tensorflow
                                   ]
                        )
)'
```


```bash
nix \
build \
--print-out-paths \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  [
    texlive.combined.scheme-medium
    pandoc
    (python3.withPackages (p: with p; [
                                     geopandas
                                     jupyter
                                     jupyterlab
                                     keras
                                     matplotlib
                                     nltk
                                     numpy
                                     opencv4
                                     pandas
                                     plotly
                                     scikitlearn
                                     scipy
                                     sympy
                                     tensorflow
                                    argon2-cffi
                                    behave  
                                    black                               
                                    boto3
                                    coverage
                                    django
                                    django-cors-headers
                                    django-debug-toolbar
                                    django-polymorphic
                                    django-rest-polymorphic
                                    django-storages
                                    djangorestframework
                                    djangorestframework-simplejwt
                                    drf-spectacular
                                    factory_boy
                                    faker
                                    flake8
                                    freezegun
                                    gunicorn
                                    holidays
                                    ipdb         
                                    isort
                                    pandas
                                    pendulum
                                    pillow
                                    psycopg2
                                    pyjwt
                                    pymupdf
                                    requests
                                    tblib
                                    user-agents                                     
                                   ]
                        )
                      )
  ]
)'
```


```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  python3.withPackages (p: with p; [
                                     geopandas
                                     matplotlib
                                     scipy
                                     tensorflow
                                     pandas
                                     jupyter
                                     scikitlearn
                                     nltk
                                     plotly
                                   ]
                        )
)'
```


```bash
nix-store --query --graph --include-outputs $(readlink -f result/bin/python3) | dot -Tpdf > glue.pdf
nix-store --query --graph --include-outputs $(readlink -f result/bin/python3) | wc -l
```



### vmTools.runInLinuxVM


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  vmTools.runInLinuxVM (pkgs.runCommand "boo" {} ''
        "${concatMapStringsSep "\n" (i: "echo baaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa") (range 1 300)}"
      ''
    )
)
'
```



Some really more complex examples:
- https://github.com/NixOS/nixpkgs/issues/177908#issuecomment-1160654806
- https://github.com/NixOS/nixpkgs/issues/190809#issuecomment-1249224694

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "tracee-test";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        machine.succeed("""
          python3 --version
         """)
      '';
    })
)
'
```


    isoImage.contents =
        [ { source = /home/me/somefolder;
            target = "/folderiniso";
          }
        ];



```bash

```


```bash
TEMP_DIR="$(mktemp)"

nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"(python3 --version | grep 3.9.13) || (python3 --version && exit 1 )\")"
      '';
    })
)
' 2> "$TEMP_DIR" || tail -n1 "$TEMP_DIR" | cut -d"'" -f2 | sh - | tail -n30
```

```bash
TEMP_DIR="$(mktemp)"

nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"(python3 --version | grep w.9.13) || (python3 --version && exit 1 )\")"
      '';
    })
)
' 2> "$TEMP_DIR" || tail -n1 "$TEMP_DIR" | cut -d"'" -f2 | sh - | tail -n30
```


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  vmTools.runInLinuxVM 
  (
    nixosTest ({
      name = "nixos-test-empty";
      nodes = {
        machine = { config, pkgs, ... }: {
        };
      };
    
      testScript = "";
    })
  )
)
'
```




Broken.
`qemu-kvm: cannot set up guest memory 'pc.ram': Cannot allocate memory`
it needs more memory, I guess, the outer VM the `runInLinuxVM` may need to have 
as much as RAM as it self needs and the inner `nixosTest` needs too.
```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  vmTools.runInLinuxVM 
  (
    nixosTest ({
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            hello
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"hello\")"
      '';
    })
  )
)
'
```



### vmTools.runInLinuxVM


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
  with lib;
  vmTools.runInLinuxImage (stdenv.mkDerivation {
    name = "deb-compile";
    src = patchelf.src;
    diskImage = vmTools.diskImages.ubuntu1804x86_64;
    diskImageFormat = "qcow2";
    memSize = 512;
    postHook = "dpkg-query --list";
  })
)
'
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/522bf206fd58ecfec1b6886e1acc879cb1b487cb/pkgs/build-support/vm/test.nix#L31-L40





### nixosTest


- https://nix.dev/tutorials/integration-testing-using-virtual-machines
- https://nixos.org/manual/nixos/stable/index.html#sec-nixos-tests
- https://nixos.mayflower.consulting/blog/2019/07/11/leveraging-nixos-tests-in-your-project/
- https://twitter.com/_Ma27_/status/1325881957142700032
- https://www.youtube.com/watch?v=5Z7IckV6gao
- https://gianarb.it/blog/my-workflow-with-nixos


TODO: related, might be tangential, testing nix it self:
https://github.com/NixOS/nix/blob/26c7602c390f8c511f326785b570918b2f468892/tests/flakes/flakes.sh

#### nixosTest minimal

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-empty";
      nodes = {
        machine = { config, pkgs, ... }: {
        };
      };
    
      testScript = "";
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-empty";
      nodes = {
        machine = { config, pkgs, ... }: {
        };
      };
    
      testScript = "";
    })
).driverInteractive
'
```

```bash
nix \
shell \
--ignore-environment \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/b9a0cd40ede905f554399f3f165895dccfd35f3b";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    [
      # busybox-sandbox-shell
      # bashInteractive  
      (nixosTest ({
        name = "nixos-test-empty";
        nodes = {
          machine = { config, pkgs, ... }: {      
          };
        };
        testScript = "";
      })).driverInteractive
    ]
)
' \
--command nixos-test-driver --interactive
```

```bash
start_all(); machine.shell_interact()
```

When it stops (it does not show the prompt):
```bash
nix --version | grep -q 'nix (Nix) 2.12.0'
```

Does not work! It terminates.
```bash
...
--command \
sh \
-c \
'nixos-test-driver --interactive <<<"start_all(); machine.shell_interact()"'
```



```bash
nix \
shell \
--ignore-environment \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/b9a0cd40ede905f554399f3f165895dccfd35f3b";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    [
      # busybox-sandbox-shell
      # bashInteractive  
      (nixosTest ({
        name = "nixos-test-empty";
        nodes = {
          machine = { config, pkgs, ... }: {
            virtualisation.podman.enable = true;  
          };
        };
        testScript = "";
      })).driverInteractive
    ]
)
' \
--command nixos-test-driver --interactive
```


```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-empty";
      nodes = {
        machine = { config, pkgs, ... }: {
          users = {
            mutableUsers = false;
            extraGroups.nixgroup.gid = 5678;
              users.nixuser = {
                home = "/home/nixuser";
                createHome = true;
                homeMode = "0700";
                isSystemUser = true;
                description = "nix user";
                extraGroups = [
                  "networkmanager"
                  "libvirtd"
                  "wheel"
                  "nixgroup"
                  "kvm"
                  "qemu-libvirtd"
                ];
                packages = with pkgs; [
                  # firefox
                ];
                shell = pkgs.bashInteractive;
                uid = 1234;
                group = "nixgroup";
              };            
            
          };
          # services.getty.autologinUser = "nixuser";
          
          environment.systemPackages = [
              bashInteractive
              coreutils
              hello
              figlet
              xorg.xclock
              (writeScriptBin "hackvm" "#! ${pkgs.runtimeShell} -e \n hello | figlet")              
            ];
        };
      };
    
      testScript = "";
    })
).driverInteractive
' \
--command \
bash \
-c \
'nixos-test-driver --interactive'
```

```bash
start_all(); machine.shell_interact()
```

```bash
hackvm
```


```bash
cat $(which nixos-test-driver)
```



```bash
cat > postgrest.nix << 'EOF'
let

  # Pin nixpkgs, see pinning tutorial for more details
  nixpkgs = fetchTarball "https://github.com/NixOS/nixpkgs/archive/0f8f64b54ed07966b83db2f20c888d5e035012ef.tar.gz";
  pkgs = import nixpkgs {};

  # Single source of truth for all tutorial constants
  database      = "postgres";
  schema        = "api";
  table         = "todos";
  username      = "authenticator";
  password      = "mysecretpassword";
  webRole       = "web_anon";
  postgrestPort = 3000;

  # NixOS module shared between server and client
  sharedModule = {
    # Since it's common for CI not to have $DISPLAY available, we have to explicitly tell the tests "please don't expect any screen available"
    virtualisation.graphics = false;
  };

in pkgs.nixosTest ({
  # NixOS tests are run inside a virtual machine, and here we specify system of the machine.
  system = "x86_64-linux";

  nodes = {
    server = { config, pkgs, ... }: {
      imports = [ sharedModule ];
      users = {
        mutableUsers = false;
        users = {
          # For ease of debugging the VM as the `root` user
          root.password = "";

          # Create a system user that matches the database user so that we
          # can use peer authentication.  The tutorial defines a password,
          # but it's not necessary.
          "${username}".isSystemUser = true;
        };
      };
    };
  };

  # Disable linting for simpler debugging of the testScript
  skipLint = true;

  testScript = ''
    server.succeed("set -e; nix --version | grep 1.2.3")
  '';
})
EOF

nix-build postgrest.nix
```

```bash
$(nix-build -A driverInteractive postgrest.nix)/bin/nixos-test-driver
```

```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-empty";
      nodes = {
        machine = { config, pkgs, ... }: {
        };
      };
    
      testScript = "";
    })
).driverInteractive
' \
--command \
sh \
<<'COMMANDS'
nixos-test-driver --interactive <<<"import subprocess; subprocess.call(['sh', '-c', 'cat /etc/passwd'])"
nixos-test-driver --interactive <<<"import os; print(os.listdir('/proc/' + str(os.getpid()) + '/ns'))"
COMMANDS
```


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"python3 --version\")"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(
          \"\"\"
            python3 --version
          \"\"\"
        )"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            pkgsStatic.python3Minimal
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(
          \"\"\"
            ! ldd python3
          \"\"\"
        )"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            hello
          ];
          
        };
      };
    
      testScript = ''
        "machine.succeed(
          \"\"\"
            ls -al /proc/$$/ns | wc -l 
          \"\"\"
        )"
      '';
    })
)
'
```


Broken:
```bash
cat <<'EOF' | xargs -0 -I{} nix build --expr {} --no-link
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"python3 --version\")"
      '';
    })
)
'
EOF
```


machine.wait_for_unit("multi-user.target")


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          virtualisation.podman = {
            enable = true;
            # Creates a `docker` alias for podman, to use it as a drop-in replacement
            #dockerCompat = true;
          };
        };
      };
    
      testScript = ''
        "machine.wait_for_unit(\"multi-user.target\"); machine.succeed(\"podman images\"); machine.succeed(\"systemctl is-active podman.socket\"); machine.fail(\"systemctl is-active podman\")"
      '';
    })
)
'
```


```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
# github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07"; 
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    nixosTest ({
      name = "nixos-test-kubernetes";
      nodes = {
        machine = { config, pkgs, ... }: {
          services.kubernetes = {
           roles = ["master" "node"];
           kubelet.extraOpts = "--fail-swap-on=false";
           masterAddress = "localhost";
          };
        };
      };
    
      testScript = ''
        "machine.succeed(\"systemctl is-active certmgr\")"
      '';
    })
)
'
```



```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
# github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07"; 
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    nixosTest ({
      doCheck = false;
      name = "nixos-test-kubernetes";
      nodes = {
        machine = { config, pkgs, ... }: {
          services.kubernetes = {
           roles = ["master" "node"];
           kubelet.extraOpts = "--fail-swap-on=false";
           masterAddress = "localhost";
          };
        };
      };
    
      testScript = ''
        "machine.succeed(\"systemctl is-active certmgr\")"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/022caabb5f2265ad4006c1fa5b1ebe69fb0c3faf"; 
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    nixosTest ({
      skipLint = true;
      name = "nixos-test-kubernetes";
      nodes = {
        machine = { config, pkgs, ... }: {
          services.kubernetes = {
           roles = ["master" "node"];
           kubelet.extraOpts = "--fail-swap-on=false";
           masterAddress = "localhost";
          };
        };
      };
    
      testScript = ''
        "machine.succeed(\"systemctl is-active kubelet\")"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    import ("${pkgs}/nixos/tests/make-test-python.nix") ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"python3 --version\")"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    import ("${path}/nixos/tests/make-test-python.nix") ({
      name = "nixos-test-python3-examples";
      nodes = {
        machine = { config, pkgs, ... }: {
          environment.systemPackages = [
            python3
          ];
        };
      };
    
      testScript = ''
"@polling_condition(description=\"check that foo is running\")
def foo_running():
    machine.succeed(\"python3 --version\")"
      '';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    import ("${path}/nixos/tests/make-test-python.nix") ({
      name = "nixos-test-python3-examples";
      # https://github.com/NixOS/nixpkgs/issues/172325
      # https://github.com/NixOS/nixpkgs/pull/174441/files#diff-53201fd9a776413fa35cb167cab111999bafe5580f579c80eaa850678a7b4599R406
      extraPythonPackages = p: [ p.numpy ];
      nodes = { };

      testScript = ''"import numpy as np; assert str(np.zeros(4) == \"array([0., 0., 0., 0.])\") "'';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    import ("${path}/nixos/tests/make-test-python.nix") ({
      skipLint = true;
      name = "nixos-test-python3-examples";
      # https://github.com/NixOS/nixpkgs/issues/172325
      # https://github.com/NixOS/nixpkgs/pull/174441/files#diff-53201fd9a776413fa35cb167cab111999bafe5580f579c80eaa850678a7b4599R406
      extraPythonPackages = p: with p; [ requests types-requests ];
      nodes = { };

      testScript = ''"import requests as r; print(r.__version__)"'';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    import ("${path}/nixos/tests/make-test-python.nix") ({
      skipLint = true;
      name = "nixos-test-python3-examples";
      # https://github.com/NixOS/nixpkgs/issues/172325
      # https://github.com/NixOS/nixpkgs/pull/174441/files#diff-53201fd9a776413fa35cb167cab111999bafe5580f579c80eaa850678a7b4599R406
      extraPythonPackages = p: with p; [ pandas ];
      nodes = { };

      testScript = ''"
import pandas as pd # type: ignore
print(pd.__version__)"'';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    import ("${path}/nixos/tests/make-test-python.nix") ({
      skipLint = true;
      name = "nixos-test-python3-examples";
      # https://github.com/NixOS/nixpkgs/issues/172325
      # https://github.com/NixOS/nixpkgs/pull/174441/files#diff-53201fd9a776413fa35cb167cab111999bafe5580f579c80eaa850678a7b4599R406
      extraPythonPackages = p: with p; [ geopandas ];
      nodes = { };

      testScript = ''"
import geopandas as gpd # type: ignore
print(gpd.__version__)"'';
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    import ("${path}/nixos/tests/make-test-python.nix") ({
      skipLint = true;
      name = "nixos-test-python3-examples";
      # https://github.com/NixOS/nixpkgs/issues/172325
      # https://github.com/NixOS/nixpkgs/pull/174441/files#diff-53201fd9a776413fa35cb167cab111999bafe5580f579c80eaa850678a7b4599R406
      extraPythonPackages = p: with p; [ tensorflow ];
      nodes = { };

      testScript = ''"
import tensorflow as tf # type: ignore
print(tf.Variable(tf.zeros([4, 3]))); print(tf.__version__)"'';
    })
)
'
```


#### nixosTest, enableOCR = true



##### nixosTest, enableOCR = true, xclock

```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
    with legacyPackages.${builtins.currentSystem};
    with lib;
      import ("${path}/nixos/tests/make-test-python.nix") ({
        name = "xclock";
        nodes.machine = { config, pkgs, ... }: {
          imports = [
            "${path}/nixos/tests/common/x11.nix"
          ];
          services.xserver.enable = true;
          environment.systemPackages = [ pkgs.xorg.xclock ];
        };

        enableOCR = true;

        testScript =
        ''
        "
@polling_condition
def xclock_running():
    machine.succeed(\"pgrep -x xclock\")

machine.wait_for_unit(\"graphical.target\")
machine.wait_for_x()
machine.execute(\"xclock >&2 &\")
machine.wait_for_window(\"xclock\")
machine.screenshot(\"screen\")
machine.send_key(\"alt-f4\")
machine.wait_until_fails(\"pgrep -x xclock\")
      "
      '';
      }
    )
  )
'
```


##### nixosTest, enableOCR = true, domination

```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
    with legacyPackages.${builtins.currentSystem};
    with lib;
      import ("${path}/nixos/tests/make-test-python.nix") ({
        name = "domination";
        nodes.machine = { config, pkgs, ... }: {
          imports = [
            "${path}/nixos/tests/common/x11.nix"
          ];
          services.xserver.enable = true;
          environment.systemPackages = [ pkgs.domination ];
        };
        enableOCR = true;
  
        testScript =
        ''
        "
machine.wait_for_x()
machine.execute(\"domination >&2 &\")
machine.wait_for_window(\"Menu\")
machine.wait_for_text(r\"(New Game|Start Server|Load Game|Help Manual|Join Game|About|Play Online)\")
machine.screenshot(\"screen\")
machine.send_key(\"ctrl-q\")
machine.wait_until_fails(\"pgrep -x domination\")
      "
      '';
      }
    )
  )
'
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/8db9c4ed3f50ef208f8ce4b4048b4574dcfeb5e3/nixos/tests/domination.nix

If you want to play the game:
```bash
nix run github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9#domination
```



##### nixosTest, enableOCR = true, vscodium



```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
    with legacyPackages.${builtins.currentSystem};
    with lib;
let
  tests = {
    wayland = { pkgs, ... }: {
      imports = [ "${path}/nixos/tests/common/wayland-cage.nix" ];

      services.cage.program = "${pkgs.vscodium}/bin/codium";

      environment.variables.NIXOS_OZONE_WL = "1";
      environment.variables.DISPLAY = "do not use";

      fonts.fonts = with pkgs; [ dejavu_fonts ];
    };
    xorg = { pkgs, ... }: {
      imports = [ "${path}/nixos/tests/common/user-account.nix" "${path}/nixos/tests/common/x11.nix" ];

      virtualisation.memorySize = 2047;
      services.xserver.enable = true;
      services.xserver.displayManager.sessionCommands = "${pkgs.vscodium}/bin/codium";
      test-support.displayManager.auto.user = "alice";
    };
  };

  mkTest = name: machine:
    import ("${path}/nixos/tests/make-test-python.nix") ({ pkgs, ... }: {
      inherit name;

      nodes = { "${name}" = machine; };

      enableOCR = true;

      # testScriptWithTypes:55: error: Item "function" of
      # "Union[Callable[[Callable[..., Any]], ContextManager[Any]], ContextManager[Any]]"
      # has no attribute "__enter__"
      #     with codium_running:
      #          ^
      skipTypeCheck = true;

      testScript = ''
      "
@polling_condition
def codium_running():
    machine.succeed(\"pgrep -x codium\")
start_all()
machine.wait_for_unit(\"graphical.target\")
machine.wait_until_succeeds(\"pgrep -x codium\")
with codium_running:
    # Wait until vscodium is visible. \"File\" is in the menu bar.
    machine.wait_for_text(\"Get Started\")
    machine.screenshot(\"start_screen\")
    test_string = \"testfile\"
    # Create a new file
    machine.send_key(\"ctrl-n\")
    machine.wait_for_text(\"Untitled\")
    machine.screenshot(\"empty_editor\")
    # Type a string
    machine.send_chars(test_string)
    machine.wait_for_text(test_string)
    machine.screenshot(\"editor\")
    # Save the file
    machine.send_key(\"ctrl-s\")
    machine.wait_for_text(\"(Save|Desktop|alice|Size)\")
    machine.screenshot(\"save_window\")
    machine.send_key(\"ret\")
    # (the default filename is the first line of the file)
    machine.wait_for_file(f\"/home/alice/{test_string}\")
# machine.send_key(\"ctrl-q\")
# machine.wait_until_fails(\"pgrep -x codium\")
      "
      '';
    });

in
builtins.mapAttrs (k: v: mkTest k v { }) tests
  )
'
```




#### test-selenium-firefox


```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
    with legacyPackages.${builtins.currentSystem};
    with lib;
      import ("${path}/nixos/tests/make-test-python.nix") ({
        name = "t-selenium-firefox";
        nodes.machine = { config, pkgs, ... }: {
          imports = [
            "${path}/nixos/tests/common/x11.nix"
          ];
          services.xserver.enable = true;
          environment.systemPackages = 
            let
              python = pkgs.python3.withPackages (ps: [ ps.selenium ]);
              pythonTest = pkgs.writeScriptBin "test-selenium-firefox" ''
"#!${python}/bin/python3
from selenium import webdriver
webdriver.Firefox()
"'';
            in with pkgs; [
              pythonTest
              geckodriver
              firefox
            ];
        };
        enableOCR = true;
        # Disable linting for simpler debugging of the testScript
        skipLint = true;
        skipTypeCheck = true;
        testScript =
        ''
        "
start_all()
machine.wait_for_unit(\"graphical.target\")
machine.wait_for_x()
machine.execute(\"test-selenium-firefox\")
machine.wait_for_text(r\"(Mozilla Firefox|New Tab|Search or enter address)\")
machine.screenshot(\"screen\")
      "
      '';
      }
    )
  )
'
```


#### test-selenium-firefox, python3 -m http.server

```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0609d6c0571e7e4e7169a1a2030319950262bf9";
    with legacyPackages.${builtins.currentSystem};
    with lib;
      import ("${path}/nixos/tests/make-test-python.nix") ({
        name = "t-selenium-firefox";
        nodes.machine = { config, pkgs, ... }: {
          imports = [
            "${path}/nixos/tests/common/x11.nix"
          ];
          services.xserver.enable = true;
          environment.systemPackages = 
            let
              python = pkgs.python3.withPackages (ps: [ ps.selenium ]);
              pythonTest = pkgs.writeScriptBin "test-selenium-firefox" ''
"#!${python}/bin/python3
from selenium import webdriver
webdriver.Firefox().get(\"localhost:6789\")
"'';
            in with pkgs; [
              pythonTest
              geckodriver
              firefox
              python3
            ];
        };
        enableOCR = true;
        # Disable linting for simpler debugging of the testScript
        skipLint = true;
        skipTypeCheck = true;
        testScript =
        ''
        "
start_all()
machine.wait_for_unit(\"graphical.target\")
machine.wait_for_x()
machine.execute(\"python3 -m http.server 6789 >&2 &\")
machine.execute(\"sleep 3\")
machine.execute(\"test-selenium-firefox\")
machine.wait_for_text(r\"(Mozilla Firefox|Directory listing for)\")
machine.screenshot(\"screen\")
      "
      '';
      }
    )
  )
'
```


#### nixosTest, sudo permissions



```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-sudo";
      nodes = {
        machine = { config, pkgs, ... }: {
          security.sudo.enable = true;
        };
      };
    
      testScript = "machine.succeed(\"stat /run/wrappers/bin/sudo\")";
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-sudo";
      nodes = {
        machine = { config, pkgs, ... }: {
          security.sudo.enable = true;
        };
      };
    
      testScript = "result = int(machine.succeed(\"stat -c %a /run/wrappers/bin/sudo\")); assert 4511 == result, f\"The permission should be: {result}\"";
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-sudo";
      nodes = {
        machine = { config, pkgs, ... }: {
          security.sudo.enable = true;
        };
      };
    
      testScript = "result = machine.succeed(\"echo $PATH\"); assert 4511 == result, f\"The permission should be: {result}\"";
    })
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-unshare";
      nodes = {
        machine = { config, pkgs, ... }: {
        };
      };
    
      testScript = "expected = len(\"Success\"); result = len(str(machine.succeed(\"unshare --user --pid echo -n Success\"))); assert expected == result, f\"The permission should be: {expected} but is {result} \"";  
    })
)
'
```



#### hydra

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-hydra";
      nodes = {
        machine = { config, pkgs, ... }: {
  nix.package = pkgs.nixUnstable;
  nix.trustedUsers = [ "hydra" ];
  nix.binaryCaches = [ "http://cache.example.org" "https://cache.nixos.org" ];

  nix.buildMachines = [
    { hostName = "localhost"; sshKey = "/var/run/keys/hydra_rsa"; system = "x86_64-linux,i686-linux"; maxJobs = 4; supportedFeatures = [ "builtin" "big-parallel" "kvm" ]; }
  ];

  services.nginx.enable = true;
  services.nginx.recommendedGzipSettings = true;
  services.nginx.recommendedOptimisation = true;
  services.nginx.recommendedProxySettings = true;
  services.nginx.virtualHosts = {
    "cache.example.org".locations."/".root = "/var/lib/nix-cache";
    "hydra.example.org".locations."/".proxyPass = "http://127.0.0.1:60080";
  };

  services.hydra.enable = true;
  services.hydra.hydraURL = "http://hydra.example.org";
  services.hydra.notificationSender = "hydra@example.org";
  services.hydra.port = 60080;
  services.hydra.useSubstitutes = true;
  # Look for nix-store --generate-binary-cache-key in the nix-store manpage
  # for more information on how to generate a keypair for your cache.
  services.hydra.extraConfig = "
    store_uri = file:///var/lib/nix-cache?secret-key=/run/keys/cache.example.org-1/sk
    binary_cache_public_uri http://cache.example.org
  ";
  users.users.hydra.extraGroups = [ "keys" ];
  users.users.hydra-queue-runner.extraGroups = [ "keys" ];

  services.postgresql.enable = true;
        };
      };
    
      testScript = "machine.wait_for_unit(\"multi-user.target\"); expected = len(\"Success\"); result = machine.succeed(\"nc -v -4 localhost 60080 -w 1 -z\"); assert expected == result, f\"The permission should be: {expected} but is {result} \"";  
    })
)
'
```
Refs.:
- https://gist.github.com/LnL7/fcd5c0bf772f2165a1ac40be6617d2f4
- https://gist.github.com/joepie91/c26f01a787af87a96f967219234a8723
- https://nixos.wiki/wiki/Hydra
- https://search.nixos.org/options?channel=22.05&show=services.hydra.enable&from=0&size=50&sort=relevance&type=packages&query=hydra


```bash
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  let
    uidCustom = 1122;
    # NixOS module?
    sharedModule = {
      # Since it is common for CI not to have $DISPLAY available
      virtualisation.graphics = false;
      
      users.users.alice = {
        uid = 1122;
        isNormalUser = true;
      };      
    };
  in nixosTest ({
    nodes = {
      machine = { config, pkgs, ... }: {
        imports = [ sharedModule ];
      };
    };
  
    # Disable linting for simpler debugging of the testScript
    skipLint = true;
  
    testScript = { nodes, ... }:
    let
      sudo = lib.concatStringsSep " " [
        "XDG_RUNTIME_DIR=/run/user/${toString uidCustom}"
        "DOCKER_HOST=unix:///run/user/${toString uidCustom}/docker.sock"
        "sudo" "--preserve-env=XDG_RUNTIME_DIR,DOCKER_HOST" "-u" "alice"
      ];
    in "
machine.wait_for_unit(\"multi-user.target\"); 
machine.succeed(\"loginctl enable-linger alice\"); 
machine.wait_until_succeeds(\"${sudo} unshare -Upf --map-root-user -- sudo -u nobody echo hello\")
    ";
  })
)
'
```

driverInteractive

testScript = "result = machine.succeed(\"unshare -Upf --map-root-user -- sudo -u nobody echo hello\"); assert 4511 == result, f\"The permission should be: {result}\"";




PATH="/run/current-system/sw/bin:$PATH"

test "$(file $(which sudo))" '==' '/run/wrappers/bin/sudo: setuid executable, regular file, no read permission'


#### 


```bash
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    nixosTest ({
      name = "nixos-test-empty";
      nodes = {
        machine = { config, pkgs, ... }: {
          virtualisation.graphics = false;
          nixpkgs.config.allowUnfree = true;
          nix = {
            package = pkgs.nixFlakes;
            extraOptions = "experimental-features = nix-command flakes";
            settings.sandbox = true;
            # From:
            # https://github.com/sherubthakur/dotfiles/blob/be96fe7c74df706a8b1b925ca4e7748cab703697/system/configuration.nix#L44
            # pointing to: https://github.com/NixOS/nixpkgs/issues/124215
            # settings.extra-sandbox-paths= [ "/bin/sh=${pkgs.bash}/bin/sh"];
            readOnlyStore = true;
          };
   
          users = {
            mutableUsers = false;
            users = {
              # For ease of debugging the VM as the `root` user
              root = {
                password = "";
                shell = pkgs.bashInteractive;
              };

              abcde = {
                password = "";
                createHome = true;
                # Create a system user that matches the database user so that we
                # can use peer authentication.  The tutorial defines a password,
                # but it is not necessary.                
                # isSystemUser = true;
                isNormalUser = true;
                description = "Some user";
                extraGroups = [
                            "wheel"
                            "kvm"
                ];
                packages = [ hello ];
                shell = pkgs.bashInteractive;
                # uid = 12321;    
              };              
            };
          };         
        };
      };
      testScript = "";
    })
).driverInteractive
'
```

```bash
start_all(); server.shell_interact();
```


###### Minimal


8zZtsUMmd5U

```bash
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  let
    username = "wiii";
    # NixOS module?
    sharedModule = {
      # Since it is common for CI not to have $DISPLAY available
      virtualisation.graphics = false;
    };
  in nixosTest ({
    nodes = {
      machine = { config, pkgs, ... }: {
        imports = [ sharedModule ];
      };
    };
  
    # Disable linting for simpler debugging of the testScript
    skipLint = true;
  
    testScript = "start_all()";
  })
).driverInteractive
'
```



```bash
nix \
run \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
  let
    username = "wiii";
    # NixOS module?
    sharedModule = {
      # Since it is common for CI not to have $DISPLAY available
      virtualisation.graphics = false;
    };
    
    myUsersModule = {
      users = {
        mutableUsers = false;
        users = {
          # For ease of debugging the VM as the `root` user
          root = {
            password = "";
            shell = pkgs.bashInteractive;
          };
        
          abcde = {
            password = "";
            createHome = true;
            # Create a system user that matches the database user so that we
            # can use peer authentication.  The tutorial defines a password,
            # but it is not necessary.                
            # isSystemUser = true;
            isNormalUser = true;
            description = "Some user";
            extraGroups = [
                        "wheel"
                        "kvm"
            ];
            packages = [ hello ];
            shell = pkgs.bashInteractive;
            # uid = 12321;    
          };              
        };
      };
      
      services.openssh = {
        # allowSFTP = true;
        # kbdInteractiveAuthentication = false;
        enable = true;

        # Não funciona em ambientes sem $DISPLAY, em CI por exemplo
        forwardX11 = false;

        # TODO: hardening
        passwordAuthentication = false;

        # Do NOT use it in PRODUCTION as yes if possible!
        permitRootLogin = "yes";

        authorizedKeysFiles = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPOK55vtFrqxd5idNzCd2nhr5K3ocoyw1JKWSM1E7f9i"
        ];
      };
    };
  in nixosTest ({
    nodes = {
      machine = { config, pkgs, ... }: {
        imports = [ sharedModule myUsersModule ];
      };
    };
  
    # Disable linting for simpler debugging of the testScript
    skipLint = true;
  
    testScript = "start_all()";
  })
).driverInteractive
'
```


#### k8s test

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/022caabb5f2265ad4006c1fa5b1ebe69fb0c3faf"; 
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    nixosTest ({
      skipLint = true;
      name = "nixos-test-kubernetes";
      nodes = {
        machine = { config, pkgs, ... }: {
          boot.isContainer = false;
          virtualisation = {
            memorySize = 1024 * 3;
            diskSize = 1024 * 3;
            cores = 4;
            msize = 104857600;
          };        
          services.kubernetes = {
           roles = ["master" "node"];
           # If you use swap:
           # kubelet.extraOpts = "--fail-swap-on=false";
           masterAddress = "localhost";
          };
          
          # Is this ok to kubernetes?
          # Why free -h still show swap stuff but with 0?
          swapDevices = pkgs.lib.mkForce [ ];
          boot.kernelParams = [
            "swapaccount=0"
            "systemd.unified_cgroup_hierarchy=0"
            "group_enable=memory"
            "cgroup_enable=cpuset"
            "cgroup_memory=1"
            "cgroup_enable=memory"
          ];
        };
      };

      testScript = ''
        "
machine.start()

# let the system boot up
machine.wait_for_unit(\"multi-user.target\")

machine.succeed(\"systemctl is-active cfssl.service\")
machine.succeed(\"systemctl is-active containerd.service\")
machine.succeed(\"systemctl is-active flannel.service\")
machine.succeed(\"systemctl is-active kube-apiserver.service\")
machine.succeed(\"systemctl is-active kube-controller-manager.service\")
machine.succeed(\"systemctl is-active kube-proxy.service\")
machine.succeed(\"systemctl is-active kube-scheduler.service\")
machine.succeed(\"systemctl is-active kubelet.service\")
machine.succeed(\"systemctl is-active etcd.service\")
machine.succeed(\"systemctl is-active kubernetes.target\")

machine.succeed(\"systemctl is-active certmgr.service\")
        "
      '';
    })
)
'
```

machine.succeed(\"systemctl is-active kubelet\")
machine.succeed(\"systemctl is-active cfssl\")


machine.succeed(\"systemctl is-active certmgr.service\")
machine.succeed(\"systemctl is-active kube-addon-manager.service\")

machine.succeed(\"systemctl is-active cfssl.service\")
machine.succeed(\"systemctl is-active containerd.service\")
machine.succeed(\"systemctl is-active flannel.service\")
machine.succeed(\"systemctl is-active kube-addon-manager.service\")
machine.succeed(\"systemctl is-active kube-apiserver.service\")
machine.succeed(\"systemctl is-active kube-controller-manager.service\")
machine.succeed(\"systemctl is-active kube-proxy.service\")
machine.succeed(\"systemctl is-active kube-scheduler.service\")
machine.succeed(\"systemctl is-active kubelet.service\")
machine.succeed(\"systemctl is-active etcd.service\")
machine.succeed(\"systemctl is-active kubernetes.target\")

#### nixosTest + pkgsCross


```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
# github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/65c15b0a26593a77e65e4212d8d9f58d83844f07"; 
  with legacyPackages.${builtins.currentSystem}; 
  with lib;
    nixosTest ({
      name = "nixos-test-kubernetes";
      nodes = {
        machine = { config, pkgs, ... }: {
          boot.binfmt.emulatedSystems = [ "aarch64-android" ];
          environment.systemPackages = [
            pkgsCross.aarch64-android.pkgsStatic.hello
          ];
        };
      };
    
      testScript = ''
        "machine.succeed(\"hello | grep Hello\")"
      '';
    })
)
'
```


### dockerTools examples


```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "hello";
      tag = "0.0.1";
      config = {
        Cmd = [
          "${pkgs.pkgsStatic.hello}/bin/hello"
        ];
      };
    }
  )
'

"$(readlink -f result)" | podman load

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/hello:0.0.1
```


```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.buildImage {
      name = "hello";
      tag = "0.0.1";
      config = {
        Cmd = [
          "${pkgs.pkgsStatic.hello}/bin/hello"
        ];
      };
    }
  )
'

podman load < result

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/hello:0.0.1
```


```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "xorg.xclock";
      tag = "0.0.1";
      config = {
        Cmd = [
          "${pkgs.xorg.xclock}/bin/xclock"
        ];
      };
    }
  )
'


"$(readlink -f result)" | podman load

nix run nixpkgs#xorg.xhost -- +
podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--user=1234 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/xorg.xclock:0.0.1
nix run nixpkgs#xorg.xhost -- -
```


```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "python3full";
      tag = "0.0.1";
      config = {
        Entrypoint = [
          "${pkgs.python3Full}/bin/python3" "-c" "from tkinter import Tk; window = Tk(); window.mainloop()"
        ];
      };
    }
  )
'

"$(readlink -f result)" | podman load

nix run nixpkgs#xorg.xhost -- +
podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--user=1234 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/python3full:0.0.1
nix run nixpkgs#xorg.xhost -- -
```


Broken:
```bash
export NIXPKGS_ALLOW_UNFREE=1; nix \
build \
--impure \
--expr \
'
  (
    with (builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57");
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "sublime4";
      tag = "0.0.1";
      config = {
        Cmd = [
          "${pkgs.sublime4}/bin/subl"
        ];
      };
    }
  )
'


"$(readlink -f result)" | podman load

nix run nixpkgs#xorg.xhost -- +
podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--user=1234 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/sublime4:0.0.1
nix run nixpkgs#xorg.xhost -- -
```

Broken, it opens, but some things still missing:
```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "pycharm-community";
      tag = "0.0.1";
      config = {
        copyToRoot = [
          jdk
        ];
        Cmd = [
          "${pkgs.jetbrains.pycharm-community}/bin/pycharm-community"
        ];
        Env = [
          "PATH=${jdk}/bin:${pkgs.jetbrains.pycharm-community}/bin:${pkgs.bashInteractive}/bin"
          "FONTCONFIG_FILE=${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
          "FONTCONFIG_PATH=${pkgs.fontconfig.out}/etc/fonts/"
          # TODO
          # https://access.redhat.com/solutions/409033
          # https://github.com/nix-community/home-manager/issues/703#issuecomment-489470035
          # https://bbs.archlinux.org/viewtopic.php?pid=1805678#p1805678
          "LC_ALL=C"
          "LOCALE_ARCHIVE=${pkgs.glibcLocales}/lib/locale/locale-archive"
        ];
      };
    }
  )
'


"$(readlink -f result)" | podman load

nix run nixpkgs#xorg.xhost -- +
podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--user=1234 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/pycharm-community:0.0.1
nix run nixpkgs#xorg.xhost -- -
```



```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "pycharm-community";
      tag = "0.0.1";
      config = {
        Cmd = [
          "${pkgs.jetbrains.pycharm-community}/bin/pycharm-community"
        ];
      };
    }
  )
'


podman load < result

podman \
run \
--device=/dev/fuse \
--device=/dev/kvm \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
--user=1234 \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
localhost/pycharm-community:0.0.1
```



### dockerTools.pullImage


```bash
nix repl '<nixpkgs>' <<<'builtins.functionArgs dockerTools.pullImage'
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
    pkgs.dockerTools.buildImage {
      name = "alpine";
      tag = "0.0.1";
      fromImage = pkgs.dockerTools.pullImage {
        name = "library/alpine";
        imageName = "alpine";
        sha256 = "y+zY1sUyRkSQbPCYbGJ0cdmornKzZLpJfzqsO3oyVTI=";
        # podman inspect docker.io/library/alpine:3.16.2 | jq ".[].Digest"
        imageDigest = "sha256:65a2763f593ae85fab3b5406dc9e80f744ec5b449f269b699b5efd37a07ad32e";
      };
      
      config = {
        Cmd = [ "/bin/sh" ];
        WorkingDir = "/data";
        Volumes = {
          "/data" = {};
        };
      };
    }
  )
'

podman load < result

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/alpine:0.0.1
```
Refs.:
- https://discourse.nixos.org/t/how-to-create-a-docker-image-based-on-another-image-with-dockertools/16144/2
- https://github.com/NixOS/nixpkgs/blob/4f0c549cece9626534ee4ab6f064604e62a8b21a/pkgs/build-support/docker/examples.nix#L90-L97



```bash
# podman pull alpine:3.17.1
# podman inspect docker.io/library/alpine:3.17.1 | jq ".[].Digest"


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
    pkgs.dockerTools.buildImage {
      name = "alpine";
      tag = "3.17.1";
      fromImage = pkgs.dockerTools.pullImage {
        name = "library/alpine";
        imageName = "alpine";
        sha256 = "sha256-kmbL9Zc68Y1mq97NdBWpOM+VPYSy/jcXjGOYUu/Imsk=";
        # podman inspect docker.io/library/alpine:3.16.2 | jq ".[].Digest"
        imageDigest = "sha256:f271e74b17ced29b915d351685fd4644785c6d1559dd1f2d4189a5e851ef753a";
      };

      config = {
        Cmd = [ "/bin/sh" ];
        WorkingDir = "/data";
        Volumes = {
          "/data" = {};
        };
      };
    }
  )
'

podman load < result

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/alpine:3.17.1
```

```bash
podman pull ubuntu:22.04 
podman inspect docker.io/library/ubuntu:22.04 | jq ".[].Digest"
# sha256:9a0bdde4188b896a372804be2384015e90e3f84906b750c1a53539b585fbbe7f

podman pull docker.io/library/fedora:37
podman inspect docker.io/library/fedora:37 | jq ".[].Digest"
# sha256:3487c98481d1bba7e769cf7bcecd6343c2d383fdd6bed34ec541b6b23ef07664

podman pull docker.io/nixos/nix:latest
podman inspect docker.io/nixos/nix:latest | jq ".[].Digest"
# sha256:af1b4e1eb819bf17374141fc4c3b72fe56e05f09e91b99062b66160a86c5d155
```

#### dockerTools.buildImage for aarch64-linux, hello example with podman

```bash
nix \
build \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
    with legacyPackages."aarch64-linux";

    dockerTools.buildImage {
      name = "hello";
      tag = "0.0.1";
      config = {
        Cmd = [
          "${pkgs.pkgsStatic.hello}/bin/hello"
        ];
      };
    }
  )
'


podman load < result

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/hello:0.0.1
```

Details:
```bash
podman info --format json | jq '.[].arch  | select( . != null )'
```

```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/8f73de28e63988da02426ebb17209e3ae07f103b";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.buildImage {
      name = "nix";
      tag = "0.0.1";

      copyToRoot = [
        pkgsStatic.nix
        coreutils
        bashInteractive
      ];
      config = {
        Entrypoint = [ "${pkgsStatic.nix}/bin/nix" "--option" "experimental-features" "nix-command flakes" ];
        # Entrypoint = [ "${bashInteractive}/bin/bash" ];
        Env = [
          "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          "USER=root"
        ];
      };
    }
  )
'

podman load < result


podman inspect localhost/nix:0.0.1 | jq -r '.[].Architecture' | grep -q arm64

# podman info --format json | jq '.[].imageCopyTmpDir  | select( . != null )'
# It may be broken because of architecture, ARM or AMD
podman \
run \
--interactive=true \
--mount=type=tmpfs,tmpfs-size=6000M,destination=/tmp \
--tty=true \
--rm=true \
localhost/nix:0.0.1 \
profile \
install \
nixpkgs#hello
```

```bash
# podman load < result
# If streamLayeredImage
"$(readlink -f result)" | podman load

podman images

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/nix:latest
```

TODO:
- https://discourse.nixos.org/t/how-to-run-chown-for-docker-image-built-with-streamlayeredimage-or-buildlayeredimage/11977/3


#### dockerTools, pkgsStatic.nix, pkgsStatic.busybox-sandbox-shell, podman

```bash
# nix flake metadata nixpkgs --json | jq --join-output '.url'
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/b139e44d78c36c69bcbb825b20dbfa51e7738347";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.buildImage {
      name = "snix";
      tag = "2.13.0pre20221223_14f7dae";

      copyToRoot = [
        # cacert
        pkgsStatic.nix
        # coreutils
        # bashInteractive
      ];
      config = {
        # Cmd = [ "${pkgsStatic.nix}/bin/nix" "--option" "experimental-features" "nix-command flakes" ];
        # Entrypoint = [ "${pkgsStatic.nix}/bin/nix" "--option" "experimental-features" "nix-command flakes" ];
        # Entrypoint = [ "${bashInteractive}/bin/bash" ];
        Entrypoint = [ "${pkgsStatic.busybox-sandbox-shell}/bin/sh" ];
        Env = [
          "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          "NIX_SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
          "NIX_CONFIG=extra-experimental-features = nix-command flakes"
        ];
      };
    }
  )
'

podman load < result


SHARED_DIRECTORY_NAME=code
# To clean all state
# chown $(id -u):$(id -g) -R "$SHARED_DIRETORY_NAME"
# rm -fr "$SHARED_DIRETORY_NAME" 
test -d "$SHARED_DIRECTORY_NAME" || mkdir -pv "$SHARED_DIRECTORY_NAME"/tmp

# It pays of its ugliness
test -f "$SHARED_DIRECTORY_NAME"/.config/nix/nix.conf \
|| mkdir -pv "$SHARED_DIRECTORY_NAME"/.config/nix && echo 'experimental-features = nix-command flakes' > "$SHARED_DIRECTORY_NAME"/.config/nix/nix.conf

echo

nix run nixpkgs#xorg.xhost -- + 

# --volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
podman \
run \
--annotation=run.oci.keep_original_groups=1 \
--device=/dev/fuse:rw \
--device=/dev/kvm:rw \
--env="DISPLAY=${DISPLAY:-:0.0}" \
--env="HOME=${HOME:-:/home/someuser}" \
--env="PATH=/bin:$HOME/.nix-profile/bin" \
--env="TMPDIR=${HOME}" \
--env="USER=${USER:-:someuser}" \
--group-add=keep-groups \
--hostname=container-nix \
--interactive=true \
--name=conteiner-unprivileged-nix \
--privileged=true \
--tty=true \
--userns=keep-id \
--rm=true \
--volume="$(pwd)"/"$SHARED_DIRECTORY_NAME":"$HOME":U \
--workdir="$HOME" \
localhost/snix:2.13.0pre20221223_14f7dae \
-c \
"nix --option experimental-features 'nix-command flakes' run nixpkgs#python310Packages.isort"
```
Refs.:
- [What's new in Nix 2.8.0 - 2.12.0?](https://youtu.be/ypFLcMCSzNA?t=495)
- [Jérôme Petazzoni - Creating Optimized Images for Docker and Kubernetes | #FiqueEmCasaConf](https://www.youtube.com/watch?v=UbXv-T4IUXk)
- [NYLUG Presents: Sneaking in Nix - Building Production Containers with Nix](https://www.youtube.com/watch?v=pfIDYQ36X0k )
- [Nix + Docker, a match made in heaven](https://www.youtube.com/watch?v=WP_oAmV6C2U)
- [Nixery - A Nix-backed container registry (NixCon 2019)](https://www.youtube.com/watch?v=pOI9H4oeXqA)

```bash
nix shell nixpkgs#bashInteractive nixpkgs#coreutils
```

```bash
nix profile install nixpkgs#hello
```


```bash
nix --option experimental-features 'nix-command flakes' build nixpkgs#pkgsCross.aarch64-multiplatform-musl.pkgsStatic.python310Packages.rsa build nixpkgs#pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
nix --option experimental-features 'nix-command flakes' build nixpkgs#pkgsCross.aarch64-multiplatform-musl.pkgsStatic.python310Packages.rsa
```

```bash
podman \
exec \
--env="USER_ID_TO_CHOWN=$(id -u)" \
--env="GROUP_ID_TO_CHOWN=$(id -g)" \
--interactive=true \
--tty=true \
--user=0 \
conteiner-unprivileged-nix \
bash \
-c \
'env; mkdir -p "$HOME"/.local/share/nix/root/nix && chmod 1777 /tmp && chown "$USER_ID_TO_CHOWN":"$USER_ID_TO_CHOWN" "$HOME"/.local/share/nix/root/nix /tmp'
```


#### Bare NixOS



```bash
cat > flake.nix << 'EOF'
{
  description = "Bare NixOS";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, nixpkgs, nixos-generators, ...}: {
    packages.x86_64-linux = {
      container = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
                    # Provide an initial copy of the NixOS channel so that the user
                    # doesn't need to run "nix-channel --update" first.
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                    
                    # "${modulesPath}/installer/cd-dvd/iso-image.nix"
                    # error: derivation '/nix/store/2j6939vz4slg58a55jfvp5r3hka3h21l-closure-info.drv' requires non-existent output 'bin' from input derivation '/nix/store/zd4r1jh7nmvkhlm6z6xi0z2w0bfkzfap-libidn2-2.3.2.drv'
                    # "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
                    # "${nixpkgs}/nixos/modules/profiles/base.nix"
                    # "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
                    # "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                    # "${nixpkgs}/nixos/modules/installer/tools/tools.nix"

                    ({ pkgs, ... }: {
                      users.users.nixuser = {                    
                        home = "/home/nixuser";
                        createHome = true;
                        homeMode = "0700";

                        # isNormalUser = true;
                        isSystemUser = true;
                        description = "nix user";
                        extraGroups = [
                          "networkmanager"
                          "libvirtd"
                          "wheel"
                          "nixgroup"
                          "docker"
                          "kvm"
                          "qemu-libvirtd"
                        ];
                        packages = with pkgs; [
                          # firefox
                        ];
                        shell = pkgs.bashInteractive;
                        # uid = 12321;    
                      };
                      users.users.nixuser.group = "nixgroup";
                      users.groups.nixuser = { };

                      #
                      # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/7
                      users.users."root".initialPassword = "r00t";
                      #
                      # To crete a new one:
                      # mkpasswd -m sha-512
                      # https://unix.stackexchange.com/a/187337
                      # users.users."root".hashedPassword = "$6$gCCW9SQfMdwAmmAJ$fQDoVPYZerCi10z2wpjyk4ZxWrVrZkVcoPOTjFTZ5BJw9I9qsOAUCUPAouPsEMG.5Kk1rvFSwUB.NeUuPt/SC/";

                      services.getty.autologinUser = "root";

                      virtualisation.podman = {
                        enable = true;
                        # Create a `docker` alias for podman, to use it as a drop-in replacement
                        #dockerCompat = true;
                      };

                      nix = {
                        # keep-outputs = true
                        # keep-derivations = true
                        # system-features = benchmark big-parallel kvm nixos-test
                        package = pkgs.nixFlakes;
                        extraOptions = ''
                          experimental-features = nix-command flakes
                        '';
                        readOnlyStore = true;
                      };
                      
                      environment.systemPackages = with pkgs; [
                        hello
                        figlet
                        podman
                        sudo
                        xorg.xclock
                      ];

                      DISPLAY=:0
                    })
        ];
        format = "docker";
      };
    };
  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/2da64a81275b68fdad38af669afeda43d401e94b

git init \
&& git add .

nix build .#container


# TODO: you need some kernel flags and may be more stuff to be able to run containers
#nix \
#profile \
#install \
#--refresh \
#github:ES-Nix/podman-rootless/from-nixpkgs#podman

cat $(readlink -f result)/tarball/nixos-system-x86_64-linux.tar.xz | podman import --os "NixOS" - nixos-image:latest

podman \
run \
--interactive=true \
--privileged=true \
--rm=true \
--tty=true \
localhost/nixos-image:latest \
/init
```





```bash
cat > flake.nix << 'EOF'
{
  description = "Bare NixOS";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = {self, nixpkgs, nixos-generators, ...}: {
    packages.x86_64-linux = {
      container = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
                    # Provide an initial copy of the NixOS channel so that the user
                    # doesn't need to run "nix-channel --update" first.
                    "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

                    # "${modulesPath}/installer/cd-dvd/iso-image.nix"
                    # error: derivation '/nix/store/2j6939vz4slg58a55jfvp5r3hka3h21l-closure-info.drv' requires non-existent output 'bin' from input derivation '/nix/store/zd4r1jh7nmvkhlm6z6xi0z2w0bfkzfap-libidn2-2.3.2.drv'
                    # "${nixpkgs}/nixos/modules/profiles/all-hardware.nix"
                    # "${nixpkgs}/nixos/modules/profiles/base.nix"
                    # "${nixpkgs}/nixos/modules/profiles/installation-device.nix"
                    # "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"
                    # "${nixpkgs}/nixos/modules/installer/tools/tools.nix"

                    ({ pkgs, ... }: {
                      users.extraGroups.nixgroup.gid = 5678;

                      users.users.nixuser = {                    
                        home = "/home/nixuser";
                        createHome = true;
                        homeMode = "0700";

                        # isNormalUser = true;
                        isSystemUser = true;
                        description = "nix user";
                        extraGroups = [
                          "networkmanager"
                          "libvirtd"
                          "wheel"
                          "nixgroup"
                          "docker"
                          "kvm"
                          "qemu-libvirtd"
                        ];
                        packages = with pkgs; [
                          # firefox
                        ];
                        shell = pkgs.bashInteractive;
                        uid = 1234;
                        initialPassword = "1";
                        group = "nixgroup";
                      };

                      users.extraUsers.nixuser.subUidRanges = [
                          {
                            count = 1;
                            startUid = 1000;
                          }
                          {
                            count = 65534;
                            startUid = 1000001;
                          }
                        ];

                      users.extraUsers.nixuser.subGidRanges = [
                          {
                            count = 1;
                            startGid = 1000;
                          }
                          {
                            count = 65534;
                            startGid = 1000001;
                          }
                        ];
                      #
                      # https://discourse.nixos.org/t/how-to-disable-root-user-account-in-configuration-nix/13235/7
                      users.users."root".initialPassword = "r00t";
                      #
                      # To crete a new one:
                      # mkpasswd -m sha-512
                      # https://unix.stackexchange.com/a/187337
                      # users.users."root".hashedPassword = "$6$gCCW9SQfMdwAmmAJ$fQDoVPYZerCi10z2wpjyk4ZxWrVrZkVcoPOTjFTZ5BJw9I9qsOAUCUPAouPsEMG.5Kk1rvFSwUB.NeUuPt/SC/";

                      services.getty.autologinUser = "nixuser";
                      # Enable networking
                      networking = {
                        hostName = "nixos";
                        useDHCP = false;
                        networkmanager.enable = true;
                        nameservers = [ "1.1.1.1" "8.8.8.8" ];
                      };

                      boot.loader.systemd-boot.enable = true;
                      boot.binfmt.emulatedSystems = ["aarch64-linux"];

                      # Enable the X11 windowing system.
                      services.xserver.enable = true;

                      # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
                      boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
                      boot.kernelParams = [
                        "console=tty0"
                        "console=ttyS0,115200n8"
                        # Set sensible kernel parameters
                        # https://nixos.wiki/wiki/Bootloader
                        # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
                        "boot.shell_on_fail"
                        "panic=30"
                        "boot.panic_on_fail" # reboot the machine upon fatal boot issues
                      ];

                      # https://discourse.nixos.org/t/linuxpackages-5-10-nvidia-x11-attribute-extend-missing-at-nix-kernel-nix31/11934/6
                      # boot.kernelPackages = pkgs.lib.recurseIntoAttrs (pkgs.linuxPackagesFor pkgs.linux_6_0);

                      systemd.services.nix-daemon.enable = true;
                      virtualisation.podman = {
                        enable = true;
                        # Create a `docker` alias for podman, to use it as a drop-in replacement
                        #dockerCompat = true;
                      };

                      virtualisation = {
                        libvirtd = {
                          enable = true;
                          # Used for UEFI boot
                          # https://myme.no/posts/2021-11-25-nixos-home-assistant.html
                          qemu.ovmf.enable = true;
                        };
                      };

                      nix = {
                        # keep-outputs = true
                        # keep-derivations = true
                        # system-features = benchmark big-parallel kvm nixos-test
                        package = pkgs.nixFlakes;
                        extraOptions = ''
                          experimental-features = nix-command flakes
                        '';
                        readOnlyStore = true;
                      };

                      environment.systemPackages = with pkgs; [
                        cacert
                        #hello
                        pkgsCross.aarch64-multiplatform.pkgsStatic.hello
                        figlet
                        podman
                        sudo
                        python3
                        xorg.xclock
                        file
                        gnugrep
                        vagrant
                      ];

                      environment.variables = {
                        NIX_SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                        SSL_CERT_FILE="${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
                        DISPLAY = ":0";
                        VAGRANT_DEFAULT_PROVIDER = "libvirt";
                      };
                    })
        ];
        format = "docker";
      };
    };
  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/97b8d9459f7922ce0e666113a1e8e6071424ae16

git init \
&& git add .

nix build .#container


# TODO: you need some kernel flags and may be more stuff to be able to run containers
#nix \
#profile \
#install \
#--refresh \
#github:ES-Nix/podman-rootless/from-nixpkgs#podman

cat $(readlink -f result)/tarball/nixos-system-x86_64-linux.tar.xz | podman import --os "NixOS" - nixos-image:latest


nix run nixpkgs#xorg.xhost -- +
podman \
run \
--env="DISPLAY=${DISPLAY:-:0}" \
--hostname="nixos" \
--interactive=true \
--name=nixos-container \
--privileged=true \
--publish="8888:8888" \
--rm=true \
--tty=true \
--volume=/tmp/.X11-unix:/tmp/.X11-unix:ro \
--volume="$(pwd)":/tmp/code:rw \
localhost/nixos-image:latest \
/init
```



```bash
su -l nixuser

podman run -it --rm alpine

nix build nixpkgs#vlc
```


```bash
python3 -m http.server 8888
```


```bash
test $(curl -s -w '%{http_code}\n' localhost:8888 -o /dev/null) -eq 200 || echo 'Error'
```


```bash
nix profile remove "$(nix eval --raw github:ES-Nix/podman-rootless/from-nixpkgs#podman)"
```


#### From apk
 
```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
alpine \
sh \
-c \
"
echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' | tee -a /etc/apk/repositories
echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' | tee -a /etc/apk/repositories
echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' | tee -a /etc/apk/repositories

apk upgrade \
&& apk update \
&& apk add nix \
&& nix --extra-experimental-features 'nix-command flakes' run nixpkgs#neofetch
"
```
Refs.:
- https://pkgs.alpinelinux.org/package/edge/testing/x86/nix
- https://wiki.alpinelinux.org/wiki/Repositories
- https://wiki.alpinelinux.org/wiki/Repositories#Edge
- https://asciinema.org/a/424725
- https://git.alpinelinux.org/aports/tree/testing/nix?h=master
- [Add a script to install nix on non-systemd systems.](https://github.com/NixOS/nix/pull/3788)
- [How to install multi-user Nix on Alpine?](https://discourse.nixos.org/t/how-to-install-multi-user-nix-on-alpine/13909)
- https://github.com/qbittorrent/qBittorrent/issues/5837#issuecomment-254978743


So based on: https://git.alpinelinux.org/aports/tree/testing/nix/fix-docs-build.patch

TODO: test the `nix-doc` thing.
```bash
podman \
run \
--interactive=true \
--tty=true \
--rm=true \
alpine \
sh \
-c \
"
echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' | tee -a /etc/apk/repositories
echo 'http://dl-cdn.alpinelinux.org/alpine/edge/main' | tee -a /etc/apk/repositories
echo 'http://dl-cdn.alpinelinux.org/alpine/edge/community' | tee -a /etc/apk/repositories

apk upgrade \
&& apk update \
&& apk add nix nix-doc \
&& nix --extra-experimental-features 'nix-command flakes' run nixpkgs#neofetch
"
```

#### From apt-get

Yes, it is possible, or it should be.

> Note: it may be really older than what would be "the latest".
> As of Ubuntu 22.04, the nix frozen by the Debian maintainers is
> 2.6 while the latest as of today is 2.13.3.

```bash
sudo apt-get -qq update \
&& sudo apt-get install -y nix-bin \
&& sudo chown -R "$(id -u)":"$(id -g)" /nix

nix \
profile \
install \
nixpkgs#busybox \
--option \
experimental-features 'nix-command flakes'


busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix


echo 'PATH="$HOME"/.nix-profile/bin:"$PATH"' >> ~/."$(busybox basename $SHELL)"rc && . ~/."$( busybox basename $SHELL)"rc

nix \
profile \
remove \
"$(nix eval --raw nixpkgs#busybox)"

nix store gc --verbose
systemctl status nix-daemon
nix flake --version
```
https://stackoverflow.com/questions/3294072/get-last-dirname-filename-in-a-file-path-argument-in-bash#comment101491296_10274182


#### The daemon version



```bash
NIX_RELEASE_VERSION=2.10.2 \
&& curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --daemon \
&& echo "Exiting the current shell session!" \
&& exit 0
```


```bash
nix \
profile \
install \
nixpkgs#busybox \
--option \
experimental-features 'nix-command flakes'


busybox test -d ~/.config/nix || busybox mkdir -p -m 0755 ~/.config/nix \
&& busybox grep 'nixos' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'system-features = benchmark big-parallel kvm nixos-test' >> ~/.config/nix/nix.conf \
&& busybox grep 'flakes' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'experimental-features = nix-command flakes' >> ~/.config/nix/nix.conf \
&& busybox grep 'trace' ~/.config/nix/nix.conf 1> /dev/null 2> /dev/null || busybox echo 'show-trace = true' >> ~/.config/nix/nix.conf \
&& busybox test -d ~/.config/nixpkgs || busybox mkdir -p -m 0755 ~/.config/nixpkgs \
&& busybox grep 'allowUnfree' ~/.config/nixpkgs/config.nix 1> /dev/null 2> /dev/null || busybox echo '{ allowUnfree = true; android_sdk.accept_license = true; }' >> ~/.config/nixpkgs/config.nix


echo 'PATH="$HOME"/.nix-profile/bin:"$PATH"' >> ~/."$(busybox basename $SHELL)"rc && . ~/."$( busybox basename $SHELL)"rc

nix \
profile \
remove \
"$(nix eval --raw nixpkgs#busybox)"

nix store gc --verbose
systemctl status nix-daemon
nix flake --version
```


http://ix.io/4mKM
http://ix.io/4mKN
http://ix.io/4mKO
echo '{ allowUnfree = true; android_sdk.accept_license = true; }' > config.nix

```bash
home-manager generations
```

```bash
home-manager --impure switch
```

Refs.:
- https://github.com/containers/podman/issues/1182#issuecomment-769931235
- https://github.com/ES-Nix/home-manager/blob/main/README.md



##### Running examples 

```bash
nix \
run \
nixpkgs#hello
```


```bash
nix \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/4b4f4bf2845c6e2cc21cd30f2e297908c67d8611"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/4b4f4bf2845c6e2cc21cd30f2e297908c67d8611")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    { 
                      # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                      isoImage.squashfsCompression = "gzip -Xcompression-level 1";
                    }
                  ];
    }
  ).config.system.build.isoImage
)
'

# EXPECTED_SHA512='c24d5b36de84ebd88df2946bd65259d81cbfcb7da30690ecaeacb86e0c1028d4601e1f6165ea0775791c18161eee241092705cd350f0e935c715f2508c915741'
EXPECTED_SHA512='5a761bd0f539a6ef53a002f73ee598e728565d7ac2f60a5947862d8795d233e3cf6bbf3c55f70a361f55e4b30e499238799d2ddb379e10a063d469d93276e3d8'
ISO_PATTERN_NAME='result/iso/nixos-21.11.20210618.4b4f4bf-x86_64-linux.iso'
# sha512sum "${ISO_PATTERN_NAME}"
echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c
```


```bash
# nix flake metadata github:NixOS/nixpkgs/release-22.05
nix \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    { 
                      # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                      isoImage.squashfsCompression = "gzip -Xcompression-level 1";
                    }
                    
                    ({
                      # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
                      boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
                      boot.kernelParams = [
                        "console=tty0"
                        "console=ttyS0,115200n8"
                        # Set sensible kernel parameters
                        # https://nixos.wiki/wiki/Bootloader
                        # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
                        "boot.shell_on_fail"
                        "panic=30"
                        "boot.panic_on_fail" # reboot the machine upon fatal boot issues
                      ];
                    })
                  ];
    }
  ).config.system.build.isoImage
)
'

EXPECTED_SHA512='d3a2162159fe326f602d91a134db36a744b1fc605bfc44c1300a1af39a7a0753beda9a00ddad7b8ab623fe5269e95f0643990258ec1d5a125fc402a53524a9c2'
ISO_PATTERN_NAME='result/iso/nixos-22.05.20221016.bf82ac1-x86_64-linux.iso'
# sha512sum "${ISO_PATTERN_NAME}"
echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c
```

installation-cd-graphical-calamares-plasma5
installation-cd-graphical-calamares-gnome

```bash
rm -fv nixos.qcow2 nixos.img                       
qemu-img create nixos.img 12G

qemu-kvm \
-boot order=d \
-hda nixos.img \
-cdrom nixos-22.05.20221016.bf82ac1-x86_64-linux.iso \
-m 2G \
-enable-kvm \
-cpu host \
-smp $(nproc) \
-nographic
```


```bash
nix \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed"
    ).lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ 
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    { 
                      # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                      isoImage.squashfsCompression = "gzip -Xcompression-level 1"; 
                    }
                    
                    ({
                      # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
                      boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
                      boot.kernelParams = [
                        "console=tty0"
                        "console=ttyAMA0,115200n8" # https://nixos.wiki/wiki/NixOS_on_ARM
                        # Set sensible kernel parameters
                        # https://nixos.wiki/wiki/Bootloader
                        # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
                        "boot.shell_on_fail"
                        "panic=30"
                        "boot.panic_on_fail" # reboot the machine upon fatal boot issues
                      ];
                    })
                  ];
    }
  ).config.system.build.isoImage
)
'
```


```bash
rm -fv nixos.qcow2 nixos.img
qemu-img create nixos.img 12G

qemu-system-aarch64 \
-boot order=d \
-bios $(nix-build '<nixpkgs>' -A pkgs.OVMF.fd --no-out-link)/FV/OVMF.fd  \
-hda nixos.img \
-cdrom result/iso/*.iso \
-m 2G \
-smp 4 \
-machine virt \
-nographic \
-cpu cortex-a57
```



        nixos-lib = import (nixpkgs + "/nixos/lib") {};


      checks = {
          test-nixos = nixos-lib.runTest {
            imports = [ ./test.nix ];

            hostPkgs = pkgsAllowUnfree;  # the Nixpkgs package set used outside the VMs
          };
        };


{ pkgs, ... }: {
  # It is an MUST that there is a name!
  # error: The option `name' is used but not defined.
  name = "Fooo";
  nodes = { master = { pkgs, ... }: { }; };

  testScript = ''
    start_all()
    master.succeed("ls -al")
  '';
}


With ssh:

```bash
nix \
build \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages."aarch64-linux";
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed"
    ).lib.nixosSystem {
        system = "aarch64-linux";
        modules = [ 
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    { 
                      # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                      isoImage.squashfsCompression = "gzip -Xcompression-level 1"; 
                    }
                    
                    ({
                        # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
                        boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
                        boot.kernelParams = [
                            "console=tty0"
                            "console=ttyAMA0,115200n8" # https://nixos.wiki/wiki/NixOS_on_ARM
                            # Set sensible kernel parameters
                            # https://nixos.wiki/wiki/Bootloader
                            # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
                            "boot.shell_on_fail"
                            "panic=30"
                            "boot.panic_on_fail" # reboot the machine upon fatal boot issues
                        ];
                        boot.tmpOnTmpfs = false;
                        # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
                        boot.tmpOnTmpfsSize = "100%";
                        
                        # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
                        users.extraGroups.nixgroup.gid = 999;
                        
                        users.users.nixuser = {
                        isSystemUser = true;
                        password = "";
                        createHome = true;
                        home = "/home/nixuser";
                        homeMode = "0700";
                        description = "The VM tester user";
                        group = "nixgroup";
                        extraGroups = [
                                      "docker"
                                      "kvm"
                                      "libvirtd"
                                      "wheel"
                        ];
                        packages = [
                          direnv
                          gitFull
                          xorg.xclock
                          file
                          # pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
                          firefox
                          (python3.buildEnv.override
                            {
                              extraLibs = with python3Packages; [ scikitimage opencv2 numpy ];
                            }
                          )
                        ];
                        shell = bashInteractive;
                        uid = 1234;
                        autoSubUidGidRange = true;
                        
                        openssh.authorizedKeys.keyFiles = [
                        nixuserKeys
                        ];
                        
                        openssh.authorizedKeys.keys = [
                        "${nixuserKeys}"
                        ];
                        };
                        
                        systemd.services.creates-if-not-exist = {
                        script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                        wantedBy = [ "multi-user.target" ];
                        };
                        
                        # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
                        systemd.services.populate-history = {
                        script = "echo \"ls -al /nix/store\" >> /home/nixuser/.bash_history";
                        wantedBy = [ "multi-user.target" ];
                        };
                        
                        virtualisation = {
                        # following configuration is added only when building VM with build-vm
                        # memorySize = 3072; # Use MiB memory.
                        # diskSize = 4096; # Use MiB memory.
                        # cores = 3;         # Simulate 3 cores.
                        #
                        docker.enable = true;
                        };
                        security.polkit.enable = true;
                        
                        # https://nixos.wiki/wiki/Libvirt
                        boot.extraModprobeConfig = "options kvm_intel nested=1";
                        boot.kernelModules = [
                        "kvm-intel"
                        "vfio-pci"
                        ];
                        
                        hardware.opengl.enable = true;
                        hardware.opengl.driSupport = true;
                        
                        nixpkgs.config.allowUnfree = true;
                        nix = {
                        package = pkgsStatic.nix;
                        # package = pkgsCross.aarch64-multiplatform-musl.pkgsStatic.nix;
                        extraOptions = "experimental-features = nix-command flakes repl-flake";
                        readOnlyStore = false;
                        };
                        
                        # Enable the X11 windowing system.
                        services.xserver = {
                        enable = true;
                        displayManager.gdm.enable = true;
                        displayManager.startx.enable = true;
                        logFile = "/var/log/X.0.log";
                        desktopManager.xterm.enable = true;
                        # displayManager.gdm.autoLogin.enable = true;
                        # displayManager.gdm.autoLogin.user = "nixuser";
                        };
                        services.spice-vdagentd.enable = true;
                        
                        # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
                        services.openssh = {
                            allowSFTP = true;
                            kbdInteractiveAuthentication = false;
                            enable = true;
                            forwardX11 = true;
                            passwordAuthentication = false;
                            permitRootLogin = "yes";
                            ports = [ 10022 ];
                            authorizedKeysFiles = [
                              "${toString nixuserKeys}"
                            ];
                        };
                        programs.ssh.forwardX11 = true;
                        services.qemuGuest.enable = true;
                        
                        services.sshd.enable = true;
                        
                        programs.dconf.enable = true;
                        
                        time.timeZone = "America/Recife";
                        
                        environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
                        environment.etc."containers/registries.conf" = {
                            mode = "0644";
                            text = "[registries.search] \n registries = [\"docker.io\", \"localhost\"]";
                        };
                        
                        # Is this ok to kubernetes? Why free -h still show swap stuff but with 0?
                        swapDevices = pkgs.lib.mkForce [ ];
                        
                        system.stateVersion = "22.11";
                        
                        users.users.root = {
                          password = "root";
                          initialPassword = "root";
                          openssh.authorizedKeys.keyFiles = [
                            nixuserKeys
                          ];
                        };
                    })
                  ];
    }
  ).config.system.build.isoImage
)
'
```




```bash
# nix flake metadata github:NixOS/nixpkgs/release-22.05
nix \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed")}/nixos/modules//profiles/all-hardware.nix"
                    { 
                      # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                      isoImage.squashfsCompression = "gzip -Xcompression-level 1";
                    }
                    
                    ({
                      # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
                      boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
                      boot.kernelParams = [
                        "console=tty0"
                        "console=ttyS0,115200n8"
                        # Set sensible kernel parameters
                        # https://nixos.wiki/wiki/Bootloader
                        # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
                        "boot.shell_on_fail"
                        "panic=30"
                        "boot.panic_on_fail" # reboot the machine upon fatal boot issues
                      ];
                    })
                  ];
    }
  ).config.system.build.isoImage
)
'

EXPECTED_SHA512='d3a2162159fe326f602d91a134db36a744b1fc605bfc44c1300a1af39a7a0753beda9a00ddad7b8ab623fe5269e95f0643990258ec1d5a125fc402a53524a9c2'
ISO_PATTERN_NAME='result/iso/nixos-22.05.20221016.bf82ac1-x86_64-linux.iso'
sha512sum "${ISO_PATTERN_NAME}"
echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c
```



```bash
nix \
build \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages."x86_64-linux";
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ 
                    "${toString (builtins.getFlake "github:NixOS/nixpkgs/bf82ac1f931c11a551abef3cf022d2faeab500ed")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                    { 
                      # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                      isoImage.squashfsCompression = "gzip -Xcompression-level 1"; 
                    }
                    
                    ({
                        # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
                        boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
                        boot.kernelParams = [
                            "console=tty0"
                            "console=ttyS0,115200n8" # https://nixos.wiki/wiki/NixOS_on_ARM
                            # Set sensible kernel parameters
                            # https://nixos.wiki/wiki/Bootloader
                            # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
                            "boot.shell_on_fail"
                            "panic=30"
                            "boot.panic_on_fail" # reboot the machine upon fatal boot issues
                        ];
                        boot.tmpOnTmpfs = false;
                        # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
                        boot.tmpOnTmpfsSize = "100%";
                        
                        # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
                        users.extraGroups.nixgroup.gid = 999;
                        
                        users.users.nixuser = {
                        isSystemUser = true;
                        password = "";
                        createHome = true;
                        home = "/home/nixuser";
                        homeMode = "0700";
                        description = "The VM tester user";
                        group = "nixgroup";
                        extraGroups = [
                                      "docker"
                                      "kvm"
                                      "libvirtd"
                                      "wheel"
                        ];
                        packages = [
                          direnv
                          gitFull
                          xorg.xclock
                          file
                          # pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
                          firefox
                          (python3.buildEnv.override
                            {
                              extraLibs = with python3Packages; [ scikitimage opencv2 numpy ];
                            }
                          )
                        ];
                        shell = bashInteractive;
                        uid = 1234;
                        autoSubUidGidRange = true;
                        
                        openssh.authorizedKeys.keyFiles = [
                        nixuserKeys
                        ];
                        
                        openssh.authorizedKeys.keys = [
                        "${nixuserKeys}"
                        ];
                        };
                        
                        systemd.services.creates-if-not-exist = {
                        script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                        wantedBy = [ "multi-user.target" ];
                        };
                        
                        # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
                        systemd.services.populate-history = {
                        script = "echo \"ls -al /nix/store\" >> /home/nixuser/.bash_history";
                        wantedBy = [ "multi-user.target" ];
                        };
                        
                        virtualisation = {
                        # following configuration is added only when building VM with build-vm
                        # memorySize = 3072; # Use MiB memory.
                        # diskSize = 4096; # Use MiB memory.
                        # cores = 3;         # Simulate 3 cores.
                        #
                        docker.enable = true;
                        };
                        security.polkit.enable = true;
                        
                        # https://nixos.wiki/wiki/Libvirt
                        boot.extraModprobeConfig = "options kvm_intel nested=1";
                        boot.kernelModules = [
                        "kvm-intel"
                        "vfio-pci"
                        ];
                        
                        hardware.opengl.enable = true;
                        hardware.opengl.driSupport = true;
                        
                        nixpkgs.config.allowUnfree = true;
                        nix = {
                        package = pkgsStatic.nix;
                        # package = pkgsCross.aarch64-multiplatform-musl.pkgsStatic.nix;
                        extraOptions = "experimental-features = nix-command flakes repl-flake";
                        readOnlyStore = false;
                        };
                        
                        # Enable the X11 windowing system.
                        services.xserver = {
                        enable = true;
                        displayManager.gdm.enable = true;
                        displayManager.startx.enable = true;
                        logFile = "/var/log/X.0.log";
                        desktopManager.xterm.enable = true;
                        # displayManager.gdm.autoLogin.enable = true;
                        # displayManager.gdm.autoLogin.user = "nixuser";
                        };
                        services.spice-vdagentd.enable = true;
                        
                        # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
                        services.openssh = {
                            allowSFTP = true;
                            kbdInteractiveAuthentication = false;
                            enable = true;
                            forwardX11 = true;
                            passwordAuthentication = false;
                            permitRootLogin = "yes";
                            ports = [ 10022 ];
                            authorizedKeysFiles = [
                              "${toString nixuserKeys}"
                            ];
                        };
                        programs.ssh.forwardX11 = true;
                        services.qemuGuest.enable = true;
                        
                        services.sshd.enable = true;
                        
                        programs.dconf.enable = true;
                        
                        time.timeZone = "America/Recife";
                        
                        environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
                        environment.etc."containers/registries.conf" = {
                            mode = "0644";
                            text = "[registries.search] \n registries = [\"docker.io\", \"localhost\"]";
                        };
                        
                        # Is this ok to kubernetes? Why free -h still show swap stuff but with 0?
                        swapDevices = pkgs.lib.mkForce [ ];
                        
                        system.stateVersion = "22.11";
                        
                        users.users.root = {
                          password = "root";
                          initialPassword = "root";
                          openssh.authorizedKeys.keyFiles = [
                            nixuserKeys
                          ];
                        };
                    })
                  ];
    }
  ).config.system.build.isoImage
)
'
```

####


```bash
nix \
build \
--expr \
'
(
with (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4");
let
  #
  # https://hoverbear.org/blog/nix-flake-live-media/
  # https://github.com/NixOS/nixpkgs/blob/39b851468af4156e260901c4fd88f88f29acc58e/nixos/release.nix#L147
  image = (import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/eval-config.nix" {
    system = "x86_64-linux";
    modules = [
      # expression that exposes the configuration as vm image
      ({ config, lib, pkgs, ... }: {
        system.build.qcow2 = import "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/lib/make-disk-image.nix" {
          inherit lib config pkgs;
          diskSize = 2500;
          format = "qcow2-compressed";
          # configFile = ./configuration.nix;
        };
      })
      
        # configure the mountpoint of the root device
        ({
          fileSystems."/".device = "/dev/disk/by-label/nixos";
          boot.loader.grub.device = "/dev/sda";
        })
    ];
  }).config.system.build.qcow2;
in
{
  inherit image;
}
)
'
```

### nixos.config.systemd.units."nix-daemon.service"


```bash
nix \
build \
--impure \
--expr \
'
let
  nixos = import <nixpkgs/nixos> { }; 
in nixos.config.systemd.units."nix-daemon.service"
'
```
Refs.:
- https://discourse.nixos.org/t/how-to-use-modules-on-other-linux-distributions/7406/2


```bash
nix \
build \
--expr \
'
let
  nixos = (builtins.getFlake "github:NixOS/nixpkgs/ea692c2ad1afd6384e171eabef4f0887d2b882d3").lib.nixosSystem { 
            system = "x86_64-linux"; 
            modules = [ 
                        "${toString (builtins.getFlake "github:NixOS/nixpkgs/ea692c2ad1afd6384e171eabef4f0887d2b882d3")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" 
                      ]; 
          };  
in nixos.config.systemd.units."nix-daemon.service"
'
```

```bash
cat result/nix-daemon.service | grep PATH | cut -d '=' -f3 | tr -d '"' | tr ':' '\n'
```


```bash
nix \
build \
--impure \
--expr \
'
let 
  nixpkgs = builtins.getFlake "github:NixOS/nixpkgs/ea692c2ad1afd6384e171eabef4f0887d2b882d3";
in
  with nixpkgs; 
  with legacyPackages.${builtins.currentSystem}; 
    let
      nixos = (nixpkgs).lib.nixosSystem { 
                system = "x86_64-linux"; 
                modules = [ 
                            "${toString (builtins.getFlake "github:NixOS/nixpkgs/ea692c2ad1afd6384e171eabef4f0887d2b882d3")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix" 
                              {
                                security.wrappers = {
                                    doas =
                                        { setuid = true;
                                          owner = "root";
                                          group = "root";
                                          source = "${doas}/bin/doas";
                                        };
                                };
                              }
                         ];
              };  
    in nixos.config.security.wrappers.doas
'
```



### --daemon



### SoN2022 

TODO:
- [Armijn Hemel - The History of NixOS (SoN2022 - Public Lecture Series)](https://www.youtube.com/watch?v=t6goF1dM3ag)
- [Eelco Dolstra - The Evolution of Nix (SoN2022 - public lecture series)](https://www.youtube.com/watch?v=h8hWX_aGGDc)


### sandbox

Do watch:
- [Eelco Dolstra - The Evolution of Nix (SoN2022 - public lecture series)](https://www.youtube.com/embed/h8hWX_aGGDc?start=766&end=816&version=3), start=766&end=816
- [Jörg 'Mic92' Thalheim - About Nix sandboxes and breakpoints (NixCon 2018)](https://www.youtube.com/watch?v=ULqoCjANK-I)
- [Build outside of the (sand)box (NixCon 2019)](https://www.youtube.com/watch?v=iWAowLWNra8)
- [Nix on Darwin – History, challenges, and where it's going by Dan Peebles (NixCon 2017)](https://www.youtube.com/watch?v=73mnPBLL_20)

```bash
# nix-shell -p "(steam.override { extraPkgs = pkgs: [pkgs.fuse]; nativeOnly = true;}).run"
# https://github.com/NixOS/nixpkgs/issues/32881#issuecomment-371815465

nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  (steam.override { extraPkgs = pkgs: [pkgs.fuse]; nativeOnly = true;}).run
)'
```

```bash
nix-shell -E '{pkgs ? import <nixpkgs> {} }: (pkgs.buildFHSUserEnv { name = "testfhsu"; targetPkgs = _: [];}).env'
```

```bash
nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/441dc5d512153039f19ef198e662e4f3dbb9fd65";  
  with legacyPackages.${builtins.currentSystem};
    (buildFHSUserEnv { name = "testfhsu"; targetPkgs = _: [ hello su ];})
)
' \
--command \
testfhsu \
-c \
'hello && su'

nix \
shell \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/441dc5d512153039f19ef198e662e4f3dbb9fd65";  
  with legacyPackages.${builtins.currentSystem};
    (buildFHSUserEnvBubblewrap { name = "testfhsu"; targetPkgs = _: [ hello su ];})
)
' \
--command \
testfhsu \
-c \
'hello && su'
```


```bash
export NIXPKGS_ALLOW_UNFREE=1; \
nix \
run \
--impure \
github:NixOS/nixpkgs/03d52eed55151e330de5f0cc4fde434a7227ff43#steam-run \
-- \
sh \
-c \
'getcap /'
```

```bash
export NIXPKGS_ALLOW_UNFREE=1; nix build --impure github:NixOS/nixpkgs/03d52eed55151e330de5f0cc4fde434a7227ff43#steam
```
https://github.com/NixOS/nixpkgs/issues/33106

```bash
nix run github:NixOS/nixpkgs/03d52eed55151e330de5f0cc4fde434a7227ff43#chromium -- --version
```

```bash
nix shell github:NixOS/nixpkgs/441dc5d512153039f19ef198e662e4f3dbb9fd65#bubblewrap --command sh -c 'bwrap --dev-bind / / sudo id'
```

```bash
export NIXPKGS_ALLOW_UNFREE=1; nix run --impure github:NixOS/nixpkgs/441dc5d512153039f19ef198e662e4f3dbb9fd65#steam-run -- id
export NIXPKGS_ALLOW_UNFREE=1; nix run --impure github:NixOS/nixpkgs/441dc5d512153039f19ef198e662e4f3dbb9fd65#steam-run -- sudo
```
https://github.com/NixOS/nixpkgs/issues/69338


unshare -Upf --map-root-user -- sudo -u nobody echo hello


nix shell --store ./ nixpkgs#bash nixpkgs#coreutils nixpkgs#util-linux --command bash -c 'unshare --user --pid echo YES' 


```bash
nix \
build \
--impure \
--expr \
'
(                                                                                                     
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    runCommand "_" 
        { 
           nativeBuildInputs = [ coreutils ];
        } 
      "mkdir $out; ls -al /; echo; ls -al /build; pwd"
)
'
```


```bash
nix \
log \
--impure \
--expr \
'
(                                                                                                     
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    runCommand "_" 
        { 
           nativeBuildInputs = [ coreutils ];
        } 
      "mkdir $out; ls -al /; echo; ls -al /build; pwd"
)
' | cat
```


#####  


```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    runCommand "my-test" {} "echo a > /tmp/a; ls -al /tmp; sleep 1; mkdir $out"
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
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
  with lib;
    runCommand "my-test" {} "echo a > /tmp/a; ls -al /tmp; sleep 1; mkdir $out"
)
' | cat
```
Refs.:
- https://stackoverflow.com/a/67607698



```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/md5sum /bin/sh; mkdir $out";
      dontInstall = true;
    }
)
'

nix \
log \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/md5sum /bin/sh; mkdir $out";
      dontInstall = true;
    }
)
' | cat
```

https://discourse.nixos.org/t/nixpkgs-that-need-no-sandbox/19173/8

```bash
nix shell -i 'github:NixOS/nixpkgs/6c6409e965a6c883677be7b9d87a95fab6c3472e#'pkgsStatic.busybox-sandbox-shell --command sh -c 'ls'
```

```bash
nix build 'github:NixOS/nixpkgs/6c6409e965a6c883677be7b9d87a95fab6c3472e#'pkgsStatic.busybox-sandbox-shell
echo eaf3601b19f2f22e5911f5678f1667d5d80fe5e7a4a2cc986b716bcfd20cc51d'  'result/bin/sh | sha256sum -c
```

```bash
sha256sum $(nix show-config --json | jq -r '."sandbox-paths".value[0]' | cut -c9-)
```

```bash
nix \
build \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/sha256sum /bin/sh; mkdir $out";
      dontInstall = true;
    }
)
'

nix \
log \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/sha256sum /bin/sh; mkdir $out";
      dontInstall = true;
    }
)
' | cat
```


ls -al /proc/$$/ns; mkdir $out

nix show-config | grep trust


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ coreutils ];
      buildPhase = "test $(ls -al /build | wc -l) -eq 4; mkdir $out";
      dontInstall = true;
    }
)
'
```



```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ coreutils ];
      buildPhase = "test $(ls -A /tmp | wc -c) -eq 0; mkdir $out";
      dontInstall = true;
    }
)
'
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ coreutils ];
      buildPhase = "test $(ls -al /nix | wc -l) -eq 4; mkdir $out";
      dontInstall = true;
    }
)
'
```

```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ coreutils ];
      buildPhase = "test $(ls -al /nix/store | wc -l) -eq 52; mkdir $out";
      dontInstall = true;
    }
)
'
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ mount ];
      buildPhase = "test $(mount | wc -l) -eq 111; mkdir $out";
      dontInstall = true;
    }
)
'
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr '
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ mount ];
      buildPhase = "test $(mount | wc -l) -eq 109; mkdir $out";
      dontInstall = true;
    }
)
'
```


https://stackoverflow.com/questions/9422461/check-if-directory-mounted-with-bash#comment30386851_9422947

```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ coreutils ];
      buildPhase = "ls -al /tmp; mkdir $out";
      dontInstall = true;
    }
)
'


nix \
log \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      buildInputs = [ coreutils ];
      buildPhase = "ls -al /tmp; mkdir $out";
      dontInstall = true;
    }
)
' | cat
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/sha256sum /bin/sh; mkdir $out";
      dontInstall = true;
    }
)
'


nix \
log \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/sha256sum /bin/sh; mkdir $out";
      dontInstall = true;
    }
)
' | cat
```


```bash
nix \
build \
--option sandbox false \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ curl ];
      buildPhase = "\"${curl}\"/bin/curl google.com; mkdir $out";
      dontInstall = true;
    }
)
'


nix \
log \
--option sandbox false \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ curl ];
      buildPhase = "\"${curl}\"/bin/curl google.com; mkdir $out";
      dontInstall = true;
    }
)
' | cat
```


In an NixOS even with `--option sandbox false` and `sandbox = relaxed` from `nix show-config | grep sandbox`:
```bash
error: builder for '/nix/store/1cw0sf4r1q1ina51vzzvg5r87jcbfxv7-demo.drv' failed with exit code 6;
       last 5 log lines:
       > patching sources
       > configuring
       > no configure script, doing nothing
       > building
       > curl: (6) Could not resolve host: google.com
       For full logs, run 'nix log /nix/store/1cw0sf4r1q1ina51vzzvg5r87jcbfxv7-demo.drv'.
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "\"${coreutils}\"/bin/ls -al /proc/$$/ns; mkdir $out;";
      dontInstall = true;
    }
)
'
```



```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ curl ];
      buildPhase = "\"${curl}\"/bin/curl google.com; mkdir $out;";
      dontInstall = true;
    }
)
'
```


```bash
error: builder for '/nix/store/8dcl8h7zhfcg73m5zyalfbnsp9y5sjgn-demo.drv' failed with exit code 6;
       last 5 log lines:
       > patching sources
       > configuring
       > no configure script, doing nothing
       > building
       > curl: (6) Could not resolve host: google.com
       For full logs, run 'nix log /nix/store/8dcl8h7zhfcg73m5zyalfbnsp9y5sjgn-demo.drv'.
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true;
      nativeBuildDependencies = [ coreutils ];
      buildPhase = "echo 3b73f7c47af2e34b84d6063aa2b212eecff1fbfbf12bd5caae8031d0d63512fd /bin/sh | sha256sum -c && mkdir $out";
      dontInstall = true;
    }
)
'
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demoo";
      dontUnpack = true;
      buildInputs = [ cowsay ];
      buildPhase = "type -a cowsay; mkdir $out;";
      dontInstall = true;
    }
)
'
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox-expected-fail";
      dontUnpack = true;
      buildPhase = "ls -al && mkdir $out;";
      dontInstall = true;
    }
)
'
```

```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox-expected-fail";
      dontUnpack = true;
      buildPhase = "ls -al && mkdir $out;";
      dontInstall = true;
    }
)
'
```



```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox";
      dontUnpack = true;
      buildInputs = [ which ];
      buildPhase = "gcc --version && which gcc && mkdir $out;";
      dontInstall = true;
    }
)
'
```


```bash
sudo apt-get update -y && sudo apt-get install -y cowsay
```


```bash
nix \
build \
--option sandbox false \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox";
      dontUnpack = true;
      buildPhase = "mkdir $out; cowsay $(echo abcz | sha256sum -) > $out/log.txt";
      dontInstall = true;
    }
)
'
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox";
      dontUnpack = true;
      buildInputs = [ cowsay ];
      buildPhase = "mkdir $out; cowsay $(echo abcz | sha256sum -) > $out/log.txt";
      dontInstall = true;
    }
)
'
```



```bash
alpine312:~$ nix run github:NixOS/nixpkgs/963d27a0767422be9b8686a8493dcade6acee992#nix-info -- --markdown
/nix/store/v3j5z9z9hnjyg5xbxbxmwshdkii7wqg0-nix-info/bin/nix-info: line 69: nix-instantiate: command not found
 - system: `0`
 - host os: `Linux 5.4.192-0-virt, Alpine Linux, noversion, nobuild`
 - multi-user?: `no`
 - sandbox: `yes`
/nix/store/v3j5z9z9hnjyg5xbxbxmwshdkii7wqg0-nix-info/bin/nix-info: line 167: nix-env: command not found
 - version: `0`
find: ‘/nix/var/nix/profiles/per-user’: No such file or directory
```


```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox";
      dontUnpack = true;
      buildInputs = [ coreutils gnugrep ];
      buildPhase = "echo $(stat -c %U:%G /nix/store) | grep nobody:nixbld && mkdir $out";
      dontInstall = true;
    }
)
'
```

```bash
nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox";
      dontUnpack = true;
      buildInputs = [ coreutils gnugrep ];
      buildPhase = "grep /nix/store /etc/mtab && mkdir $out";
      dontInstall = true;
    }
)
'
```

TODO: Test this in an nixosTest and in an runInLinuxVM
- https://stackoverflow.com/questions/9422461/check-if-directory-mounted-with-bash#comment30386851_9422947
- https://stackoverflow.com/a/47214691
- https://discourse.nixos.org/t/using-fuse-inside-nix-derivation/8534/2
- https://github.com/NixOS/nixpkgs/issues/101038

```bash
nix \
develop \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "test-sandbox";
      dontUnpack = true;
      buildInputs = [ bashInteractive coreutils gnugrep ];
      buildPhase = "echo $(stat -c %U:%G /nix/store) | grep root:nixbld && mkdir -p $out";
      dontInstall = true;
    }
)
' \
--command \
bash \
-c \
'
source $stdenv/setup \
&& cd "$(mktemp -d)" \
&& pwd 
# mkdir -pv "$(pwd)/"tmp/out
# export out="$(pwd)/"tmp/out
set +e 
# set -x
genericBuild
'
```

TODO: https://unix.stackexchange.com/a/208844


https://github.com/NixOS/nixpkgs/blob/0305391fb65b5bdaa8af3c48275ec0df1cdcc34e/pkgs/tools/nix/info/info.sh#L127
https://github.com/NixOS/nixpkgs/blob/0305391fb65b5bdaa8af3c48275ec0df1cdcc34e/pkgs/tools/nix/info/sandbox.nix

TODO: /dev/kvm
https://github.com/NixOS/nixpkgs/blob/16236dd7e33ba4579ccd3ca8349396b2f9c960fe/nixos/modules/services/misc/nix-daemon.nix#L522
[LinuxCon Portland 2009 - Roundtable - Q&A 1](https://www.youtube.com/embed/K3FsmpXeqHc?start=100&end=112&version=3), start=100&end=112

TODO: HUGE, https://github.com/NixOS/nix/issues?page=2&q=is%3Aissue+is%3Aopen+sandbox

TODO: about the $TMPDIR, https://discourse.nixos.org/t/tmpdir-with-nix-build-and-sandbox/11761

##### __noChroot = true;

I am against that, unless there is not a better way known.

- https://github.com/NixOS/nixpkgs/blob/3fe1cbb848ea90827158bbd814c2189ff8043539/pkgs/development/tools/purescript/spago/default.nix#L39
- https://zimbatm.com/notes/nix-packaging-the-heretic-way
- https://discourse.nixos.org/t/is-there-a-way-to-mark-a-package-as-un-sandboxable/4174/2
- https://stackoverflow.com/questions/65683206/how-do-i-include-my-source-code-in-nix-docker-tools-image

> If the `sandbox` option is set to relaxed, then fixed-output derivations
> and derivations that have the `__noChroot` attribute set to
> true do not run in sandboxes.
https://nixos.org/manual/nix/unstable/command-ref/conf-file.html?highlight=extra-



##### breakpointHook


```bash
cd some_empty_folder # Important to avoid errors during unpack phase
export out=~/tmpdev/bc-build/out
source $stdenv/setup # loads the environment variable (`PATH`...) of the derivation to ensure we are not using the system variables
set +e # To ensure the shell does not quit on errors/Ctrl+C ($stdenv/setup runs `set -e`)
set -x # Optional, if you want to display all commands that are run
genericBuild
```


```bash
nix profile install github:Mic92/cntr

nix \
build \
--option sandbox true \
--impure \
--expr \
'
(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    stdenv.mkDerivation {
      name = "demo";
      dontUnpack = true; 
      nativeBuildInputs = [ breakpointHook ];
      buildInputs = [ bashInteractive coreutils ];
      buildPhase = "dfgdths; mkdir $out";
      dontInstall = true;
    }
)
'
```



```bash
source $stdenv/setup \
&& phases="buildPhase" genericBuild
```

```bash
sudo \
$(which cntr) \
attach \
-t \
command \
cntr-/nix/store/f33nrsw93gwpw2yw238qdb8isrdaa8qs-demo \
<<'COMMANDS'
source $stdenv/setup \
&& phases="buildPhase" genericBuild
COMMANDS
```
https://discourse.nixos.org/t/debug-a-failed-derivation-with-breakpointhook-and-cntr/8669/4



#### builtins.break, --debugger


- [What's new in Nix 2.8.0 - 2.12.0?](https://www.youtube.com/embed/ypFLcMCSzNA?start=293&end=401&version=3),start=293&end=401
- https://github.com/NixOS/nix/issues/6649

```bash
cat << 'EOF' > default.nix
{ c = 6; d = 48; e = { f = 58; };}
EOF
```


```bash
nix eval --file default.nix --debugger
```

```bash
cat << 'EOF' > default.nix
{ c = 6; d = builtins.break 48; e = { f = 58; };}
EOF
```


```bash
nix \
eval \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    (hello.overrideAttrs
      (oldAttrs: {
          preFixup = (oldAttrs.preFixup or "") + "${builtins.break toString 1}";
        }
      )
    )
)' \
--ignore-try \
--debugger
```


```bash
nix \
eval \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/cd90e773eae83ba7733d2377b6cdf84d45558780";
  with legacyPackages.${builtins.currentSystem};
    (hello.overrideAttrs
      (oldAttrs: {
          posFixup = (oldAttrs.posFixup or "") + "${builtins.break toString 1}";
        }
      )
    )
)' \
--ignore-try \
--debugger
```

TODO: take a look into these `nix repl` stuff that lilyball did
https://discourse.nixos.org/t/in-overlays-when-to-use-self-vs-super/2968/9


## NixOS modules


https://nixos.wiki/wiki/NixOS_modules
https://nixos.mayflower.consulting/blog/2018/09/11/custom-images/
https://hoverbear.org/blog/nix-flake-live-media/
[Rickard Nilsson - Nix(OS) modules everywhere! (NixCon 2018)](https://www.youtube.com/watch?v=I_KCd46B8Mw)
[Nix Friday - NixOS modules](https://www.youtube.com/watch?v=5doOHe8mnMU)



## Caching and Nix


[Domen Kožar, Robert Hensing - Cachix - binary cache(s) for everyone (NixCon 2018)](https://www.youtube.com/watch?v=py26iM26Qg4)

https://scrive.github.io/nix-workshop/06-infrastructure/01-caching-nix.html

```bash
nix run nixpkgs#nix-serve
```
https://unix.stackexchange.com/a/204757

```bash
curl http://localhost:5000/nix-cache-info
```



```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022,hostfwd=tcp::5000-:5000'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519

export NIXPKGS_ALLOW_UNFREE=1

nix \
run \
--impure \
--expr \
'
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.${builtins.currentSystem};
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        # system = "aarch64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyS0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

            # https://nixos.wiki/wiki/NixOS:nixos-rebuild_build-vm
            users.extraGroups.nixgroup.gid = 999;

            users.users.nixuser = {
              isSystemUser = true;
              password = "";
              createHome = true;
              home = "/home/nixuser";
              homeMode = "0700";
              description = "The VM tester user";
              group = "nixgroup";
              extraGroups = [
                              "docker"
                              "kvm"
                              "libvirtd"
                              "wheel"
              ];
              packages = [
                  direnv
                  gitFull
                  xorg.xclock
                  file
                  # pkgsCross.aarch64-multiplatform-musl.pkgsStatic.hello
                  nix-serve
                  pkgsStatic.hello
                  bpytop
                  # firefox
                  # vscode
                  (python3.buildEnv.override
                    {
                      extraLibs = with python3Packages; [ numpy ];
                    }
                  )
              ];
              shell = bashInteractive;
              uid = '"$(id -u)"';
              autoSubUidGidRange = true;

              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];

              openssh.authorizedKeys.keys = [
                "${nixuserKeys}"
              ];
            };

              systemd.services.fix-sudo-permision = {
                script = "chown 0:0 -v ${sudo}/libexec/sudo/sudoers.so";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.adds-change-workdir = {
                script = "echo cd /tmp/shared >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              systemd.services.creates-if-not-exist = {
                script = "echo touch /home/nixuser/.Xauthority >> /home/nixuser/.profile";
                wantedBy = [ "multi-user.target" ];
              };

              # https://unix.stackexchange.com/questions/619671/declaring-a-sym-link-in-a-users-home-directory#comment1159159_619703
              systemd.services.populate-history = {
                script = "echo \"ls -al /nix/store\" >> /home/nixuser/.bash_history";
                wantedBy = [ "multi-user.target" ];
              };

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 3072; # Use MiB memory.
                diskSize = 4096; # Use MiB memory.
                cores = 3;         # Simulate 3 cores.
                #
                docker.enable = true;
              };
              security.polkit.enable = true;

              # https://nixos.wiki/wiki/Libvirt
              boot.extraModprobeConfig = "options kvm_intel nested=1";
              boot.kernelModules = [
                "kvm-intel"
                "vfio-pci"
              ];

              hardware.opengl.enable = true;
              hardware.opengl.driSupport = true;

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = pkgsStatic.nix;
                # package = pkgsCross.aarch64-multiplatform-musl.pkgsStatic.nix;
                extraOptions = "experimental-features = nix-command flakes repl-flake";
                readOnlyStore = false;
              };
              boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

              # Enable the X11 windowing system.
              services.xserver = {
                enable = true;
                displayManager.gdm.enable = true;
                displayManager.startx.enable = true;
                logFile = "/var/log/X.0.log";
                desktopManager.xterm.enable = true;
                # displayManager.gdm.autoLogin.enable = true;
                # displayManager.gdm.autoLogin.user = "nixuser";
              };
              services.spice-vdagentd.enable = true;

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = true;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };
              programs.ssh.forwardX11 = true;
              services.qemuGuest.enable = true;

              services.sshd.enable = true;

              programs.dconf.enable = true;

              time.timeZone = "America/Recife";

              environment.variables.KUBECONFIG = "/etc/kubernetes/cluster-admin.kubeconfig";
              environment.etc."containers/registries.conf" = {
                mode = "0644";
                text = "[registries.search] \n registries = [\"docker.io\", \"localhost\"]";
              };

              # Is this ok to kubernetes? Why free -h still show swap stuff but with 0?
              swapDevices = pkgs.lib.mkForce [ ];
            networking.firewall.allowedTCPPorts = [ 5000 ];

            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' < /dev/null &

while ! nc -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
#<<COMMANDS
#id
#COMMANDS
#"$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```

```bash
curl http://localhost:5000/nix-cache-info
```

```bash
# nix-env -iA nixpkgs.firefox --option extra-binary-caches http://avalon:8080/
nix \
--option extra-binary-caches http://localhost:5000/ \
profile \
install \
github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#pkgsStatic.hello
```


```bash
# nix-env -iA nixpkgs.firefox --option extra-binary-caches http://avalon:8080/
nix \
--option extra-binary-caches http://localhost:5000/ \
profile \
install \
github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4#pkgsStatic.python
```


https://nixos.org/manual/nix/stable/package-management/binary-cache-substituter.html


## mkYarnPackage


### vscode

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  [
    (let
      name = "vscode";
      version = "1.74.0";
     in
      mkYarnPackage {
        inherit name version;
        src = builtins.fetchTarball {
          url = "https://github.com/Microsoft/vscode/archive/${version}.tar.gz" ;
          sha256 = "0b42c2xa2cpmhxmazpcwgxay2n4jmv74rwxqizh38cg8390jpvp2";
        };
      }
    )
  ]
)'
```

### hedgedoc

Take a look in how huge this file is:
https://github.com/hedgedoc/hedgedoc/blob/7be4ef6e70a7f4d60636945e8b7dce8ad9904a57/yarn.lock

> 19456 lines (17587 sloc)

```bash
nix \
shell \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/d2cfe468f81b5380a24a4de4f66c57d94ee9ca0e";
  with legacyPackages.x86_64-linux;
  [
    (let
      name = "hedgedoc";
      version = "1.9.6";
     in
      mkYarnPackage {
        inherit name version;
        src = builtins.fetchTarball {
          url = "https://github.com/hedgedoc/hedgedoc/archive/${version}.tar.gz" ;
          sha256 = "120zcsfv8ifn7nrcw8kvhgmggaqjrxcm8kp4f4am5z051sglsama";
        };
      }
    )
  ]
)'
```
TODO: how to do an DAG of an `yarn.lock`? It must be possible to do that with nix cli?!



### hello-in-nuxt


```bash
mkdir hello-in-nuxt \
&& cd hello-in-nuxt

cat << 'EOF' > package.json
{
  "name": "nuxt-hello",
  "version": "0.0.1",
  "scripts": {
    "dev": "nuxt",
    "build": "nuxt build",
    "generate": "nuxt generate",
    "start": "nuxt start"
  }
}
EOF

mkdir pages \
&& cat << 'EOF' > index.vue
<template>
  <h1>Hello nf1zknik5jvg5mci3g world!</h1>
</template>
EOF

cat << 'EOF' >> .nuxtrc
telemetry.consent=0
telemetry.enabled=false
EOF

nix \
shell \
nixpkgs#yarn \
nixpkgs#nodejs \
--command \
bash \
-c \
'yarn --lock && yarn add nuxt && yarn --lock && yarn run generate'
```
Refs.:
- https://nuxtjs.org/docs/get-started/installation/

Cleaning:
```bash
rm -fr .nuxt .output dist node_modules; yarn install && yarn run generate --offline
# --offline --verbose --check-files --non-interactive
```


```bash
nix \
build \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f";
  with legacyPackages.x86_64-linux;
  [
    (let
      name = "nuxt-hello";
      version = "0.0.0";
     in
      mkYarnPackage {
        inherit name version;
        src = builtins.path { path = "${./.}"; name = "nuxt-hello-src"; };
      }
    )
  ]
)'

file result/tarballs/nuxt-hello.tgz
# result/tarballs/nuxt-hello.tgz: gzip compressed data, from Unix, original size modulo 2^32 5632
```


#### MWE: yarn, nuxt, mkYarnPackage + postBuild + distPhase

```bash
mkdir hello-in-nuxt \
&& cd hello-in-nuxt

#cat << 'EOF' > package.json
#{
#  "name": "nuxt-hello",
#  "version": "0.0.1",
#  "license": "MIT",
#  "private": true,
#  "scripts": {
#    "dev": "nuxt",
#    "build": "nuxt build",
#    "generate": "nuxt generate",
#    "start": "nuxt start"
#  }
#}
#EOF

mkdir pages \
&& cat << 'EOF' > index.vue
<template>
  <h1>Hello nf1zknik5jvg5mci3g world!</h1>
</template>
EOF

cat << 'EOF' >> .nuxtrc
telemetry.consent=0
telemetry.enabled=false
EOF

# If we have the yarn.lock we can skip and save some time.
#nix \
#shell \
#github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f#yarn \
#github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f#nodejs \
#--command \
#bash \
#-c \
#'yarn --lock && yarn add nuxt && yarn --lock'

test -f yarn.lock || wget -O yarn.lock http://ix.io/4inx

# After the first time that is ran yarn add nuxt it is done.
# https://stackoverflow.com/a/61725333
cat << 'EOF' > package.json
{
  "name": "nuxt-hello",
  "version": "0.0.1",
  "license": "MIT",
  "private": true,
  "scripts": {
    "dev": "nuxt",
    "build": "nuxt build",
    "generate": "nuxt generate",
    "start": "nuxt start"
  },
  "dependencies": {
    "nuxt": "^3.0.0"
  }
}
EOF


nix \
build \
-L \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f";
  with legacyPackages.x86_64-linux;
  [
    (let
      name = "nuxt-hello";
      version = "0.0.0";
     in
      mkYarnPackage {
        inherit name version;
        src = builtins.path { path = "${./.}"; name = "nuxt-hello-src"; };
        postBuild = "ls -al && export HOME=\"$(mktemp -d)\" && export TMPDIR=$HOME/tmp && mkdir -pv $TMPDIR && yarn generate --offline";
        distPhase = "mkdir -pv dist"; # "ls -al && export HOME=\"$(mktemp -d)\" && export TMPDIR=$HOME/tmp && mkdir -pv $TMPDIR && yarn generate --offline";
      }
    )
  ]
)'

grep -q 'Welcome to Nuxt' result/libexec/nuxt-hello/deps/nuxt-hello/.output/public/index.html

#--command \
#bash \
#-c \
#'
#source $stdenv/setup # loads the environment variable (`PATH`...) of the derivation to ensure we are not using the system variables
#cd "$(mktemp -d)" # Important to avoid errors during unpack phase
#set +e # To ensure the shell does not quit on errors/Ctrl+C ($stdenv/setup runs `set -e`)
## set -x # Optional, if you want to display all commands that are run
#genericBuild
#'
```

TODO: try to help https://discourse.nixos.org/t/packaging-an-electron-app/20933


```bash
nix \
develop \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f";
  with legacyPackages.x86_64-linux;
  [
    (let
      name = "nuxt-hello";
      version = "0.0.0";
     in
      mkYarnPackage {
        inherit name version;
        src = builtins.path { path = "${./.}"; name = "nuxt-hello-src"; };
      }
    )
  ]
)' \
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
Refs.:
- https://nixos.wiki/wiki/Packaging/Python


```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f";
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
        buildInputs = with python3Packages; [ typing-extensions redis mmh3 ];
      }
    )
  ]
)' \
--command \
python \
-c \
'from pottery import ReleaseUnlockedLock'
```



```bash
nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/0e857e0089d78dee29818dc92722a72f1dea506f";
  with legacyPackages.x86_64-linux;
  [
    (
      python3Packages.buildPythonPackage rec {
          pname = "blspy";
          version = "1.0.1";
        
          format = "wheel";
          src = fetchFromGitHub {
          owner = "Chia-Network";
          repo = "bls-signatures";
          rev = "97e7b63bee645a8b53c53197dd3ad7238908ea5a";
          # sha256 = "${lib.fakeSha256}";
          sha256 = "sha256-MSUlIHHj5c0rlxypNdmngPVlF7jaDw05hyTAll5N0mI=";
          };
        
          buildInputs = [ stdenv.cc.cc.lib ];
        
          propagatedBuildInputs = [ python3Packages.setuptools ];
        
          nativeBuildInputs = [ pkgs.autoPatchelfHook ];  
        
          meta = with lib; {
            description = "BLS Signatures implementation";
            homepage = "https://github.com/Chia-Network/bls-signatures";
            license = licenses.asl20;
            maintainers = with maintainers; [ breakds ];
          };
        }
    )
  ]
)
'
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
  overlay = (self: super:
    let
      myOverride = {
        packageOverrides = self: super: {
          inotify_simple = super.buildPythonPackage rec {
            pname = "inotify_simple";
            version = "1.1.7";
            doCheck = false;
            src = super.fetchPypi {
              inherit pname version;
              sha256 = "1jvivp84cyp4x4rsw4g6bzbzqka7gaqhk4k4jqifyxnqqmbdgvcq";
            };
          };
        };
      };
    in {
      # Add an override for each required python version. 
      # There’s currently no way to add a package that’s automatically picked up by 
      # all python versions, besides editing python-packages.nix
      python2 = super.python2.override myOverride;
      python3 = super.python3.override myOverride;
      python35 = super.python35.override myOverride;
    }
  );

  pkgs = import (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") { overlays = [ overlay ]; };
in
  with pkgs; [
    pythonPackages.inotify_simple
    python3Packages.inotify_simple
    python35Packages.inotify_simple
  ]
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
'
(  
   let
     overlay = (self: super: {
       python = super.python.override {
         packageOverrides = python-self: python-super: {
           twisted = python-super.twisted.overrideAttrs (oldAttrs: {
             src = super.fetchPypi {
               pname = "twisted";
               version = "19.10.0";
               sha256 = "7394ba7f272ae722a74f3d969dcf599bc4ef093bc392038748a490f1724a515d";
               extension = "tar.bz2";
             };
           });
         };
       };
     });
      
      # Let"s put together a package set to use later
      myPythonPackages = ps: with ps; [
        twisted
        # and other modules you"d like to add
      ];      
   in
     (
       import 
       (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") 
       { overlays = [ overlay ]; }
     ).python3.withPackages myPythonPackages
  )
' \
--command \
python3 \
-c \
'import twisted'
```


```bash
nix \
shell \
--impure \
--expr \
'
  (  
    let
     overlay = (self: super: {
       python = super.python.override {
         packageOverrides = python-self: python-super: {
           twisted = python-super.twisted.overrideAttrs (oldAttrs: {
             src = super.fetchPypi {
               pname = "twisted";
               version = "19.10.0";
               # sha256 = "7394ba7f272ae722a74f3d969dcf599bc4ef093bc392038748a490f1724a515d";
               sha256 = "${self.lib.fakeSha256}";
               extension = "tar.bz2";
             };
           });
         };
       };
     });
      
      # Let"s put together a package set to use later
      myPythonPackages = ps: with ps; [
        twisted
        # and other modules you"d like to add
      ];      
    in
      (
        import 
        (builtins.getFlake "github:NixOS/nixpkgs/09e8ac77744dd036e58ab2284e6f5c03a6d6ed41") 
        { overlays = [ overlay ]; }
      ).python3.withPackages myPythonPackages
  )
' \
--command \
python3 \
-c \
'import twisted; print(twisted.__version__)'
```



```bash
nix \
develop \
-i \
--impure \
nixpkgs#python3Packages.isort \
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

Advanced Refs.:
- https://discourse.nixos.org/t/explaining-nix-to-a-npm-user/12836/3
- https://discourse.nixos.org/t/how-to-import-a-derivation-with-import/15375/3


```bash
{ lib, stdenv, fixup_yarn_lock, callPackage, yarn, nodejs-slim }:

stdenv.mkDerivation {
  pname = "foo";
  version = "1.0.0";

  src = lib.cleanSource ./.;

  yarnOfflineCache = (callPackage ./yarn.nix {}).offline_cache;
  # or fetchYarnDeps

  nativeBuildInputs = [
    fixup_yarn_lock yarn nodejs-slim
  ];

  configurePhase = ''
    export HOME=$NIX_BUILD_TOP
    yarn config --offline set yarn-offline-mirror $yarnOfflineCache
    fixup_yarn_lock yarn.lock
    yarn install --offline --frozen-lockfile --ignore-scripts --no-progress --non-interactive
    patchShebangs node_modules/
  '';

  buildPhase = ''
    ...
  '';

  installPhase = ''
    ...
    # if the node_modules dir is needed at runtime, move it to $out/libexec here
  '';
}
```
Ref.:
- https://discourse.nixos.org/t/mkyarnpackage-lockfile-has-incorrect-entry/21586/3


Broken, it is a generic example.
```bash
nix \
build \
--impure \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
    stdenv.mkDerivation {
      name = "the-name-of-the-derivation";
      src = fetchGit {
                      url = "git+ssh://git@github.com/organization-name/repository-name";
                      rev = "9f4590cd57f45d939d65aca8e6507f5aa28aeb87";
                      ref = "gh-pages";
                    };
      buildPhase = "mkdir -pv $out/site; cp -R . $out/site";
      dontInstall = true;
    }
  )
'
```


### Find that common/wierd bin/lib with some "name"

Maybe the best place to begin:
https://search.nixos.org/packages


> Note: it is possible to inspect the remote official binary cache 
> and use that to figure out stuff.

This may be fast:
```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
--recursive \
"$(nix eval --raw nixpkgs#gnumake)"
```

/nix/store/69ixn6by9fa9gqmydk6zwszxd019p2dy-firefox-34.0.5
This one may take while in the first time, because it downloads 
from the cache and if some part is not in the "local store cache" it will be built:
TODO: `.override` the `meta`
```bash
nix run nixpkgs#gnumake -- --version
```


```bash
ls -A "$(nix build --print-out-paths --no-link nixpkgs#libressl| head -n1)/bin"
```

```bash
ls -A "$(nix build --print-out-paths nixpkgs#binutils.out)/bin"
```

```bash
# Old nix
# ls -A "$(nix-build '<nixpkgs>' -A pkgs.OVMF.fd --no-out-link)/FV/OVMF.fd"
ls -A "$(nix build --print-out-paths --no-link nixpkgs#OVMF.fd)/FV/OVMF.fd"
```

```bash
ls -A "$(nix build --print-out-paths --no-link nixpkgs#pkgsCross.aarch64-multiplatform-musl.OVMF.fd)/AAVMF" 
```

> `findmnt`, which is itself part of the util-linux
> Refs.: https://stackoverflow.com/a/46025626

```bash
nix \
shell \
--ignore-environment \
nixpkgs#util-linux \
nixpkgs#busybox-sandbox-shell \
nixpkgs#gnugrep \
nixpkgs#which \
--command \
sh \
-c \
'file "$(which findmnt)"'
```


```bash
nix \
shell \
--ignore-environment \
nixpkgs#binutils \
nixpkgs#busybox-sandbox-shell \
nixpkgs#gnugrep \
nixpkgs#which \
--command \
sh \
-c \
'objdump -p "$(which readelf)" | grep NEEDED'
```

Other weird one:
```bash
ls -A "$(nix build --print-out-paths nixpkgs#cdrtools)/bin"
```

Outputs:
```bash
btcflash  cdda2mp3  cdda2ogg  cdda2wav  cdrecord  devdump  isodebug  isodump  isoinfo  isovfy  mkhybrid  mkisofs  readcd  rscsi  scgcheck  scgskeleton
```

```bash
ls -A "$(nix build --print-out-paths nixpkgs#rustc.llvmPackages.clang.cc.lib)/lib"
```


```bash
ls -A "$(nix build --print-out-paths nixpkgs#unixtools.xxd)/bin"
```

```bash
# The man page is wrong, it points to procps-ng
ls -A "$(nix build --print-out-paths nixpkgs#procps)/bin"
```

```bash
ls -A "$(nix build --print-out-paths nixpkgs#nixVersions.nix_2_10)/bin"
```


TODO: document it
iana-etc


##### Using the nix repl

TODO: make some examples
- https://stackoverflow.com/questions/71753915/how-can-i-search-in-nixpkgs-for-a-package-expression
- https://stackoverflow.com/questions/56118564/asking-nix-for-metadata-about-the-given-package?noredirect=1&lq=1

```bash
nix repl --expr 'import <nixpkgs> {}' <<<'(builtins.getFlake "github:edolstra/dwarffs").rev'
```

```bash
nix repl --expr 'import <nixpkgs> {}' <<<'builtins.attrNames gcc'
```

```bash
nix repl --expr 'import <nixpkgs> {}' <<<'lib.attrNames yarn.override.__functionArgs'
```

```bash
nix repl --expr 'import <nixpkgs> {}' <<<'builtins.attrNames python3Packages' | tr ' ' '\n' | wc -l
```


```bash
nix repl --expr 'import <nixpkgs> {}' <<<'builtins.attrNames nodePackages_latest' | tr ' ' '\n' | wc -l
```



```bash
nix repl --expr 'import <nixpkgs> {}' <<<'builtins.attrNames aspellDicts' | tr ' ' '\n' | wc -l
```


```bash
nix repl --expr 'import <nixpkgs> {}' <<<'builtins.attrNames hunspellDicts' | tr ' ' '\n' | wc -l
```


1.
```bash
# You may need to install jq
nix flake metadata nix --json | jq -r '.url'
```

2.1
```bash
nix repl --expr 'import <nixpkgs> {}'
```

2.2
```bash
:lf github:NixOS/nix/f58c30111261a3ad50a6cb462cb2df7c49aa82e4
```

```bash
nix flake show nix
```

Really long build:
```bash
nix \
build \
--print-build-logs \
--no-link \
nix#hydraJobs.installerTests.ubuntu-22-04.x86_64-linux.install-force-no-daemon
```


```bash
nix \
show-derivation \
nix#hydraJobs.installerTests.ubuntu-22-04.x86_64-linux.install-force-no-daemon
```
Refs.:
- https://hydra.nixos.org/job/nix/maintenance-2.12/installerTests.fedora-36.x86_64-linux.install-force-daemon

```bash
nix \
show-derivation \
nix#hydraJobs.installerTests.ubuntu-22-04.x86_64-linux.install-force-no-daemon | jq -r '.[].env.buildCommand'
```


##### Dummies certificates, acme, snakeoil

TODO:
http://blog.tpleyer.de/posts/2020-01-17-nix-show-derivation-is-your-friend.html
https://github.com/NixOS/nixpkgs/issues/34422#issuecomment-381349690


> Note: if you have not seen some bash-fu/nix-fu like that it is almost magic.
```bash
ls -al "$(nix eval nixpkgs#path)"/nixos/tests/common/acme/server/acme.test.{cert,key}.pem
```
Refs.:
- https://discourse.nixos.org/t/where-can-i-get-snakeoil-certificates/14628/4

> Note that here it is used `'<nixpkgs/nixos>'`
```bash
nix repl --expr 'import <nixpkgs/nixos> {}' <<<'builtins.attrNames config.security.acme' | tr ' ' '\n'
```
Refs.:
- https://jorel.dev/NixOS4Noobs/options.html#method-3-using-the-nix-repl


#### The nix-locate

It is really cool. It is able to find almost any output by name and/or ending path.

MWE:
```bash
nix-locate -w 'bin/hello' 
```

> Note: there is another way, just download it ready to use!
It took more than 6Gigas of RAM to build its cache on my machine in the first time it was used. 

Other example:
```bash
nix-locate -w 'lib/libyuv.a' 
```
Refs.:
- [Connor Brewster - The Road to Nix at Replit (SoN2022 - public lecture series)](https://www.youtube.com/embed/jhH2LWGUHhY?start=1290&end=1335&version=3), start=1290&end=1335
- [The Nix Hour #8](https://www.youtube.com/embed/cfCqauM9ztM?start=2685&end=2757&version=3), start=2685&end=2757


##### A really hard to find package: pythonManylinuxPackages and its manylinux variants


```bash
ls -A "$(nix build --print-out-paths nixpkgs#pythonManylinuxPackages.manylinux1Package)/lib"
```


```bash
cat \
$(
nix \
build \
--impure \
--print-out-paths \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "hello";
          paths = [ hello ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/hello --add-flags \"-t\" ";
        }
  )
'
)/bin/hello
```
Refs.:
- https://gist.github.com/CMCDragonkai/9b65cbb1989913555c203f4fa9c23374
- https://stackoverflow.com/a/49940561



```bash
cat \
$(
nix \
build \
--impure \
--print-out-paths \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "hello";
          paths = [ hello ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/hello --set PATH ${lib.makeBinPath [ figlet ]}";
        }
  )
')/bin/hello
```


```bash
cat $(
nix \
build \
--impure \
--print-out-paths \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = [ python3Full ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${lib.makeLibraryPath (with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ])}";
        }
  )
'
)/bin/python3
```
Refs.:
- https://gist.github.com/CMCDragonkai/9b65cbb1989913555c203f4fa9c23374
- https://www.youtube.com/watch?v=jhH2LWGUHhY&t=1497s
- https://stackoverflow.com/a/49940561


TODO: improve this
```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

    dockerTools.streamLayeredImage {
      name = "python3manylinux";
      tag = "0.0.1";
      config = {
        copyToRoot = [
          # 
        ];
        Cmd = [
          # 
        ];
        Entrypoint = [
          "${bashInteractive}/bin/bash"
          # "${pkgs.python3Full}/bin/python3" "-c" "from tkinter import Tk; window = Tk(); window.mainloop()"
        ];
        Env = [
          "PATH=${bashInteractive}/bin:${ (symlinkJoin {
            name = "python3";
            paths = [ python3Full ];
            buildInputs = [ makeWrapper ];
            postBuild = "wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${lib.makeLibraryPath (with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ])}";
          })}/bin"
          # TODO
          # https://access.redhat.com/solutions/409033
          # https://github.com/nix-community/home-manager/issues/703#issuecomment-489470035
          # https://bbs.archlinux.org/viewtopic.php?pid=1805678#p1805678
          # "LC_ALL=C"
          # "LOCALE_ARCHIVE=${glibcLocales}/lib/locale/locale-archive"
        ];
      };
    }
  )
'

"$(readlink -f result)" | podman load

podman \
run \
--interactive=true \
--tty=true \
--rm=true \
localhost/python3manylinux:0.0.1 \
-c \
"python -c 'import this'"
```


```bash
ls -al $(nix build --impure --print-out-paths --expr '
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = [ python3Full ];
        }
  )
')/lib
```

##### manylinux1Package manylinux2010Package manylinux2014Package

```bash
ls -A $(nix build --impure --print-out-paths --expr '
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "pythonManylinuxLibs";
          paths = with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ];
        }
  )
')/lib | cut -d'>' -f2 | sort
```

###### python3Full manylinux1Package manylinux2010Package manylinux2014Package

```bash
ls -A $(nix build --impure --print-out-paths --expr '
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = with pythonManylinuxPackages; [ python3Full manylinux1Package manylinux2010Package manylinux2014Package ];
        }
  )
')/lib | wc -l | grep 27
```


```bash
ls -A $(nix build --impure --print-out-paths --expr '
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = with pythonManylinuxPackages; [ 
                                                  python3Minimal
                                                  manylinux1Package 
                                                  manylinux2010Package 
                                                  manylinux2014Package 
                                                ];
        }
  )
')/lib | wc -l
```

```bash
result/bin/python3 -c \
'
from ctypes import CDLL
libc = CDLL("libc.so.6")
libc.printf
'
```


##### LD_LIBRARY_PATH python3Full manylinux1Package manylinux2010Package manylinux2014Package

```bash
nix \
shell \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = [ python3Full ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${lib.makeLibraryPath (with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ])}";
        }
  )
' \
--command python3 -c \
'
from ctypes import CDLL

libs = (
"libcrypt.so.1",
"libc.so.6",
"libdl.so.2",
"libgcc_s.so.1",
"libglib-2.0.so.0",
"libGL.so.1",
"libgobject-2.0.so.0",
"libgthread-2.0.so.0",
"libICE.so.6",
"libm.so.6",
"libncursesw.so.5",
"libnsl.so.1",
"libpanelw.so.5",
"libpthread.so.0",
"libresolv.so.2",
"librt.so.1",
"libSM.so.6",
"libstdc++.so.6",
"libutil.so.1",
"libX11.so.6",
"libXext.so.6",
"libXrender.so.1",
)

{lib:[item for item in dir(CDLL(lib)) if not item.startswith("__")] for lib in libs}
all([lib == getattr(CDLL(lib), "_name") for lib in libs])
'
```

TODO: 
libc = CDLL("libc.so.6")
libc.printf

TODO: 
```bash
from subprocess import Popen, PIPE

def f(args):
    out = Popen(
        args="nm " + args, 
        shell=True, 
        stdout=PIPE
    ).communicate()[0].decode("utf-8")
    
    attrs = [
        i.split(" ")[-1].replace("\r", "") 
        for i in out.split("\n") if " T " in i
    ]
    return attrs
attrs = f("libc.so.6")
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
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = [ python3Full ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${lib.makeLibraryPath (with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ])}";
        }
  )
'
) | dot -Tps > python3.ps
```



```bash
nix \
shell \
--ignore-environment \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = [ (python3.withPackages (p: with p; [ pip ])) ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${lib.makeLibraryPath (with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ])}";
        }
  )
' \
--command \
python3 \
-c \
"import os; print(os.environ['LD_LIBRARY_PATH']); os.system('echo $LD_LIBRARY_PATH')"
```


```bash
nix \
shell \
--ignore-environment \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
        symlinkJoin {
          name = "python3";
          paths = [ (python3.withPackages (p: with p; [ pip ])) ];
          buildInputs = [ makeWrapper ];
          postBuild = "wrapProgram $out/bin/python3 --set LD_LIBRARY_PATH ${lib.makeLibraryPath (with pythonManylinuxPackages; [ manylinux1Package manylinux2010Package manylinux2014Package ])}";
        }
  )
' \
--command \
python3 \
-c \
"from pprint import pprint; from pip._internal.models.target_python import TargetPython; pprint(len(TargetPython().get_tags()))"

```
Refs.:
- https://stackoverflow.com/a/73830154
- https://stackoverflow.com/a/68450405
- https://stackoverflow.com/questions/50248524/module-pip-has-no-attribute-pep425tags#comment126655541_53384575
- https://github.com/tensorflow/tensorflow/issues/9722
- https://peps.python.org/pep-0425/
- https://pypi.org/project/auditwheel/#limitations
- https://peps.python.org/pep-0571/#platform-detection-for-installers
- https://peps.python.org/pep-0599/#platform-detection-for-installers


### How to undo a nix build


```bash
nix build --print-out-paths nixpkgs#hello
```

```bash
unlink result
sudo nix-store --delete --ignore-liveness $(nix build --print-out-paths --no-link nixpkgs#hello)
```
Refs.:
- https://unix.stackexchange.com/questions/381853/how-to-remove-single-package-from-cache-nix-store#comment981500_382018
- https://elatov.github.io/2022/01/building-a-nix-package/#redoing-a-build
- https://discourse.nixos.org/t/how-to-undo-nix-build/5433/5

TODO: why `sudo`? How to do the same without `sudo`?




###

TODO:
https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-run.html#apps
--bash-prompt value

Set the bash-prompt setting.

--bash-prompt-prefix value

Set the bash-prompt-prefix setting.

--bash-prompt-suffix value

Set the bash-prompt-suffix setting.


#### 


```bash
sudo groupadd docker; \
sudo usermod --append --groups docker "$USER" \
&& sudo reboot
```

```bash
nix \
profile \
install \
nixpkgs#docker \
&& sudo cp "$(nix eval --raw nixpkgs#docker)"/etc/systemd/system/{docker.service,docker.socket} /etc/systemd/system/ \
&& sudo systemctl enable --now docker
```
Refs.: 
- https://github.com/NixOS/nixpkgs/issues/70407
- https://github.com/moby/moby/tree/e9ab1d425638af916b84d6e0f7f87ef6fa6e6ca9/contrib/init/systemd
- https://stackoverflow.com/a/48973911


```bash
docker \
run \
--rm \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'apk add --no-cache curl'
```

```bash
docker \
run \
--interactive=true \
--tty=true \
--rm=true \
--user='0' \
--volume="$(pwd)":/code:rw \
--workdir=/code \
docker.io/library/alpine:3.14.2 \
sh \
-c \
'touch abc123.txt'
```

#####


```bash
sudo apt-get update \
&& sudo apt-get install -y uidmap


nix \
profile \
install \
nixpkgs#podman \
&& mkdir -pv ~/.config/systemd/user \
&& cp -v "$(nix eval --raw nixpkgs#podman)"/share/systemd/user/{podman-auto-update.service,podman-auto-update.timer,podman-kube@.service,podman-restart.service,podman.service,podman.socket} ~/.config/systemd/user \
&& systemctl --user daemon-reload \
&& systemctl --user enable --now podman.socket


mkdir -p ~/.config/containers
cat << 'EOF' >> ~/.config/containers/policy.json
{
    "default": [
        {
            "type": "insecureAcceptAnything"
        }
    ],
    "transports":
        {
            "docker-daemon":
                {
                    "": [{"type":"insecureAcceptAnything"}]
                }
        }
}
EOF

mkdir -p ~/.config/containers
cat << 'EOF' >> ~/.config/containers/registries.conf
[registries.search]
registries = ['docker.io']
[registries.block]
registries = []
EOF
```


#### podman rootfull

```bash
sudo groupadd podman; \
sudo usermod --append --groups podman "$USER" \
&& sudo reboot
```

```bash
nix \
profile \
install \
nixpkgs#podman \
&& sudo cp "$(nix eval --raw nixpkgs#podman)"/share/systemd/user/{podman-auto-update.service,podman-auto-update.timer,podman-kube@.service,podman-restart.service,podman.service,podman.socket} /etc/systemd/system/ \
&& sudo systemctl enable --now podman
```

```bash
podman \
run \
--rm \
docker.io/library/alpine:3.16.2 \
sh \
-c \
'apk add --no-cache curl'
```


## The nix patters

A collection of supposed useful patters


```nix
stdenv.mkDerivation (finalAttrs: {
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/285b3ff0660640575186a4086e1f8dc0df2874b5/pkgs/tools/cd-dvd/ventoy-bin/default.nix#L52

```nix
  + optionalString (!withGtk3 && !withQt5) ''
    rm "$VENTOY_PATH"/VentoyGUI.*
  '' +
  ''
    runHook postInstall
  '';
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/285b3ff0660640575186a4086e1f8dc0df2874b5/pkgs/tools/cd-dvd/ventoy-bin/default.nix#L178-L184


```nix
        makeWrapper "$VENTOY_PATH/$bin" "$out/bin/$wrapper" \
                    --prefix PATH : "${lib.makeBinPath finalAttrs.buildInputs}" \
                    --chdir "$VENTOY_PATH"
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/285b3ff0660640575186a4086e1f8dc0df2874b5/pkgs/tools/cd-dvd/ventoy-bin/default.nix#L157-L159


TODO: change it in many ways
```bash
nix \
build \
--impure \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/93e0ac196106dce51878469c9a763c6233af5c57";
    with legacyPackages.${builtins.currentSystem};

      let
        imageEnv = pkgs.buildEnv {
          name = "k3s-pause-image-env";
          paths = with pkgs; [ tini (hiPrio coreutils) busybox ];
        };
        pauseImage = pkgs.dockerTools.streamLayeredImage {
          name = "test.local/pause";
          tag = "local";
          contents = imageEnv;
          config.Entrypoint = [ "/bin/tini" "--" "/bin/sleep" "inf" ];
        };
      in
        pauseImage
  )
'

podman load < result

#podman \
#run \
#--interactive=true \
#--tty=true \
#--rm=true \
#localhost/hello:0.0.1
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/3928cfa27d9925f9fbd1d211cf2549f723546a81/nixos/tests/k3s/single-node.nix




TODO:
https://github.com/NixOS/nixpkgs/pull/182445#issuecomment-1200277429

