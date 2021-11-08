# get-nix

Is an unofficial wrapper of the nix installer, unstable for now!

https://nixos.org/guides/install-nix.html

https://nix.dev/tutorials/install-nix

## Single user


https://nixos.org/manual/nix/stable/#sect-single-user-installation


```bash
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=eccef9a426fd8d7fa4c7e4a8c1191ba1cd00a4f7 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& export TMPDIR=/tmp \
&& export OLD_NIX_PATH="$(readlink -f $(which nix))" \
&& echo $OLD_NIX_PATH \
&& nix-shell \
    --arg pkgs 'import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/refs/tags/20.09.tar.gz") {}' \
    --keep OLD_NIX_PATH \
    --packages nixFlakes \
    --run 'nix-env --uninstall $OLD_NIX_PATH && nix-collect-garbage --delete-old && nix profile install github:NixOS/nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes' \
&& sudo rm -frv /nix/store/*-nix-2.3.* \
&& unset OLD_NIX_PATH \
&& nix-collect-garbage --delete-old --verbose \
&& nix store gc --verbose \
&& nix flake --version
```

Maybe, if you use `zsh`, you need `. ~/.zshrc` to get the zsh shell working again.

You may need to install curl (sad, i know, but it might be the last time):
```bash
sudo apt-get update
sudo apt-get install -y curl
```

*Warning:* installed in this way (in a profile) nix + flakes is not ideal because it is possible to break
`nix` it self if you run `nix profile remove '.*'`.


### Testing your installation

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


Some times usefull:
```bash
rm -rfv "$HOME"/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.cache/nix}
sudo rm -fr /nix
```

When you get a error like this (only after many huge builds, but depends how much memory you have)
`error: committing transaction: database or disk is full (in '/nix/var/nix/db/db.sqlite')`

For check memory:
```bash
du --dereference --human-readable --summarize /nix
```

Short flags version:
```bash
du -L -h -s /nix
```

```bash
jq --version || nix profile install nixpkgs#jq
nix path-info --json --all | jq 'map(.narSize) | add'
```

```bash
"$(dirname "$(dirname "$(readlink -f "$(which nix)")")")"
```

```bash
nix shell nixpkgs#libselinux --command getenforce
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
nix shell nixpkgs#nix-info --command nix-info --markdown
nix show-config
jq --version || nix profile install nixpkgs#jq
nix show-config --json | jq .

nix verify
nix doctor 
nix path-info
nix flake metadata nixpkgs
jq --version || nix profile install nixpkgs#jq
nix flake metadata nixpkgs --json | jq .
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
ls -al "$HOME".nix-profile/bin
ls -al $(echo "$PATH" | cut -d ':' -f 1 | cut -d '=' -f 1 )
nix profile list | tr ' ' "\n"
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

nix-store --query --tree --include-outputs $(nix-store --query --deriver $(readlink -f  $(which nix))) | cat
nix-store --query --graph --include-outputs $(nix-store --query --deriver $(readlink -f $(which nix))) | dot -Tps > graph.ps
```


```bash
nix why-depends --all --derivation nixpkgs#gcc nixpkgs#glibc | cat
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
&& echo 'Broken symbolic link to profiel' $(file /home/ubuntu/.nix-profile)
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

## chroot and others

[Local Nix without Root (HPC)](https://www.reddit.com/r/NixOS/comments/iod7wi/local_nix_without_root_hpc/)

```bash
nix diff-closures /nix/var/nix/profiles/system-655-link /nix/var/nix/profiles/system-658-link
```
From: [Add 'nix diff-closures' command](https://github.com/NixOS/nix/pull/3818). TODO: write it in an generic way, 
not hardcoding the profile number.


### nix statically built WIP

```bash
sudo mkdir -v /nix
sudo chown "$(id -u)":"$(id -g)" -v /nix
sudo -k

SHA256=7429196f21cea77a70341bc46614bba3c5cad6b5 \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/nix-static.sh | sh \
&& . ~/.profile \
&& nix --version \
&& nix flake metadata nixpkgs \
&& nix store gc --verbose
```


```bash
nix \
run \
nixpkgs#hello
```

```bash
nix \
develop \
github:ES-Nix/fhs-environment/enter-fhs
```

&& nix --store "$HOME" flake metadata nixpkgs \
&& nix --store "$HOME"/store store gc --verbose

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
shell
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
nix-build -A pkgsStatic.nix
From: https://github.com/NixOS/nixpkgs/pull/56281
```

`--with-store-dir=path`
From: https://stackoverflow.com/a/37231726

`--with-store-dir` in the nix derivation https://github.com/NixOS/nixpkgs/blob/a3f85aedb1d66266b82d9f8c0a80457b4db5850c/pkgs/tools/package-management/nix/default.nix#L124


TODO: make tests for this in QEMU
https://github.com/NixOS/nixpkgs/pull/56281#issuecomment-484242510


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
nix build github:NixOS/nix#nix-static
nix build github:NixOS/nix/9feca5cdf64b82bfb06dfda07d19d007a2dfa1c1#nix-static
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

TODO: `umask` 
https://github.com/NixOS/nix/issues/2377#issuecomment-633165541
https://ivanix.wordpress.com/tag/umask/


### Install direnv and nix-direnv using nix + flakes

```bash
SHA256=7c60027233ae556d73592d97c074bc4f3fea451d \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/install_direnv_and_nix_direnv.sh | sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& . ~/.direnvrc \
&& direnv --version
```

To remove:
```bash
rm -rfv ~/.direnvrc
```


#### Testing the direnv's instalation

```bash
SHA256=7c60027233ae556d73592d97c074bc4f3fea451d \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/test_install_direnv_nix_direnv.sh | sh
```

You may need `cd ~/foo-bar`.

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


## Tests

This is an environment that is used to test the installer:

```bash
nix build --refresh github:ES-Nix/nix-qemu-kvm/dev#qemu.vm \
&& nix develop --refresh github:ES-Nix/nix-qemu-kvm/dev \
--command bash -c 'vm-kill; run-vm-kvm && prepares-volume && ssh-vm'
```


### Tests


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
nodejs,\
poetry,\
python39,\
rustc,\
yarn\
}

gcc --version
gfortran --version
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

