# get-nix

Is an unofficial wrapper of the nix installer, unstable for now!

https://nixos.org/guides/install-nix.html

https://nix.dev/tutorials/install-nix

## Single user


https://nixos.org/manual/nix/stable/#sect-single-user-installation


```bash
test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix \
&& BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=136a0ad03df69baa0a810282591f4c962d1c626f \
&& NIX_RELEASE_VERSION='2.10.1' \
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

nix flake metadata nixpkgs # For development version use nix flake metadata .#
nix flake metadata github:nixos/nixpkgs
nix flake metadata github:nixos/nixpkgs/nixpkgs-unstable
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
```

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

```bash
echo $(nix-store --query --graph $(nix-store --query $(nix eval --raw nixpkgs#hello.drvPath))) | dot -Tps > graph.ps \
&& sha256sum graph.ps
```

```bash
FILE_NAME='graph.ps'

nix-store \
  --store https://cache.nixos.org/ \
  --query \
  --references $(nix eval --raw github:NixOS/nixpkgs/18de53ca965bd0678aaf09e5ce0daae05c58355a#gcc) \
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

echo $(nix-store --query --graph $(nix eval --raw github:NixOS/nix#nix-static))
```bash
echo $(nix-store --query --graph $(nix eval --raw github:NixOS/nix#nix-static)) | dot -Tpdf > nix-static.pdf
echo $(nix-store --query --graph $(nix eval --raw github:NixOS/nix#nix-static.drvPath)) | dot -Tpdf > nix-static-drvPath.pdf
```

```bash
nix path-info --derivation nixpkgs#hello
nix eval --raw nixpkgs#hello.drvPath
nix eval --raw nixpkgs#lib.version
nix eval nixpkgs#lib.fakeSha256

echo $(nix-store --query --graph $(nix eval --raw nixpkgs#hello.drvPath)) | dot -Tpdf > hello.pdf
```


```bash
nix show-derivation nixpkgs#hello
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

#### Install nix statically built



```bash
test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix
```

```bash
SHA256=136a0ad03df69baa0a810282591f4c962d1c626f \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"${SHA256}"/nix-static.sh | sh \
&& . ~/.profile \
&& nix flake --version \
&& nix flake metadata nixpkgs \
&& nix store gc --verbose
```




```bash
mkdir -pv $HOME/.nix-profile
mkdir -pv $HOME/nix/var/nix/profiles/per-user/vagrant/profile
ln -sfv $HOME/.nix-profile $HOME/nix/var/nix/profiles/per-user/vagrant/profile
```


```bash
test -d /nix || sudo mkdir -m 0755 /nix \
&& sudo -k chown "$USER": /nix


mkdir -pv /nix/var/nix/profiles/per-user/vagrant/profile
ln -fsv /nix/var/nix/profiles/per-user/vagrant/profile $HOME/.nix-profile


curl -L https://hydra.nixos.org/build/183832936/download/1/nix > nix \
&& chmod +x nix \
&& ./nix --store / --extra-experimental-features 'nix-command flakes' run nixpkgs#python3 -- --version 

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
Matthew shows how using statically linked Nix in a 5MB binary, one can use Nix without root. With an one-liner shell, you can use Nix to install any software on a Linux machine.
[Static Nix: a command-line swiss army knife](https://matthewbauer.us/blog/static-nix.html)


TODO: [Packaging with Nix](https://www.youtube.com/embed/Ndn5xM1FgrY?start=329&end=439&version=3), start=329&end=439

[Nix Portable: Nix - Static, Permissionless, Install-free, Pre-configured](https://discourse.nixos.org/t/nix-portable-nix-static-permissionless-install-free-pre-configured/11719)


> Oh yeah, chroot stores won’t work on macOS. Neither will proot. Having a flat-file binary cache in the shared dir and copying to/from that will be your only option there.
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


TODO: `umask` 
https://github.com/NixOS/nix/issues/2377#issuecomment-633165541
https://ivanix.wordpress.com/tag/umask/

TODO:
- https://github.com/NixOS/nixpkgs/pull/56281#issuecomment-484242510 and https://github.com/lethalman/nix-user-chroot/pull/13#issuecomment-462200418
- https://github.com/NixOS/nix/blob/d9cfd853e52d0173f86a1648246360faa96c516c/flake.nix#L87

### Install direnv and nix-direnv using nix + flakes

```bash
SHA256=136a0ad03df69baa0a810282591f4c962d1c626f \
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
SHA256=136a0ad03df69baa0a810282591f4c962d1c626f \
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

#### Minimal build

```bash
nix build --expr '{}' --no-link
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
nix \
shell \
--impure \
--expr \
'(with builtins.getFlake "nixpkgs"; 
with legacyPackages.${builtins.currentSystem}; 
[ hello cowsay ]
)' 

# hello | cowsay
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

```bash
nix \
build \
--expr \
'
(
  (
    (
      builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf"
    ).lib.nixosSystem {
        system = "x86_64-linux";
        modules = [            
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf")}/nixos/modules/virtualisation/build-vm.nix" 
          
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/b283b64580d1872333a99af2b4cef91bb84580cf")}/nixos/modules/installer/cd-dvd/channel.nix" 
        ];
    }
  ).config.system.build.vm
)
' \
&& result/bin/run-nixos-vm
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

# Broken, no ideia why...
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

```bash
sudo su -c 'apt-get update && apt-get install -y zsh' \
&& echo \
&& cat /etc/passwd | grep sh \
&& chsh -s /usr/bin/zsh \
&& cat /etc/passwd | grep sh \
&& echo \
&& curl -LO https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh \
&& chmod +x install.sh \
&& yes | ./install.sh \
&& rm install.sh \
&& zsh
```
From: https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH
From: https://ohmyz.sh/#install


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
'(
  with builtins.getFlake "nixpkgs"; 
  with legacyPackages.${builtins.currentSystem}; 
  let               
    overlay = final: prev: {
      hello = prev.hello.overrideAttrs (oldAttrs: with final; {
          postInstall = oldAttrs.postInstall + "${prev.hello}/bin/hello Installation complete";
        }
      );
    };

  pkgs = import (with builtins.getFlake "nixpkgs";); { overlays = [ overlay ]; };

  in
    pkgs.hello
)'
```


nix run --impure --expr 'with (import <nixpkgs> {}); let               
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

# Only python3Full is abble?
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
nix-instantiate \
--option pure-eval true \
--eval \
--impure \
--expr \
'with builtins.getFlake "nixpkgs"; with legacyPackages.${builtins.currentSystem}; python3.withPackages (ps: with ps; [ numpy scipy ])'

nix build --impure --expr '(import <nixpkgs> { overlays = [(final: prev: { static = true; })]; }).openssl'
nix run --impure --expr '(import <nixpkgs> { overlays = [(final: prev: { aclSupport = false; })]; }).coreutils'

nix build --impure --expr '(import <nixpkgs> {                                                                      
  overlays = [
    (self: super: {
      firefox-unwrapped = super.firefox-unwrapped.overrideAttrs (oldAttrs: {
        makeFlags = oldAttrs.makeFlags ++ [ "BUILD_OFFICIAL=1" ];
      });
    })
  ];
}).firefox-unwrapped'
```



####

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

# If there is one line with only '-e ' removes it.
# Nix 2.4 installer let it alone in the ~/.profile.
busybox sed -i 's/^-e $//' ~/.profile

nix \
profile \
remove \
"$(nix eval --raw nixpkgs#busybox)"

nix store gc --verbose
```


```bash
nix \
run \
nixpkgs#hello
```

