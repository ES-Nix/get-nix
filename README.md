# get-nix

Is an unofficial wrapper of the nix installer, unstable for now!


## Single user


https://nixos.org/manual/nix/stable/#sect-single-user-installation

```
test -d /nix || sudo mkdir --mode=0755 /nix \
&& sudo chown "$USER": /nix \
&& SHA256=4fbc7498d5b08c4543ad040463eb0bf212acc70f \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/get-nix.sh | sh \
&& . "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& export TMPDIR=/tmp \
&& cd "$TMPDIR" \
&& echo "$(readlink -f $(which nix-env))" > old_nix_path \
&& nix-shell -I nixpkgs=channel:nixos-21.05 --packages nixFlakes --run 'nix-env --uninstall $(cat old_nix_path) && nix profile install nixpkgs#nixFlakes' \
&& rm -rfv old_nix_path \
&& cd ~ \
&& nix-collect-garbage --delete-old \
&& nix store gc \
&& nix flake --version
```

Maybe, if you use `zsh`, you need `. ~/.zshrc` to get the zsh shell working again.

You may need to install curl (sad, i know, but it might be the last time):
```
sudo apt-get update
sudo apt-get install -y curl
```

Some times usefull:
`sudo rm --recursive /nix`

When you get a error like this (only after many huge builds, but depends how much memory you have)
`error: committing transaction: database or disk is full (in '/nix/var/nix/db/db.sqlite')`

For check memory:
`du --dereference --human-readable --summarize /nix`
`nix path-info --json --all | jq 'map(.narSize) | add'`


## Troubleshoot commands

```bash
nix-shell \
-I nixpkgs=channel:nixos-21.05 \
--packages \
nixFlakes \
--run \
'nix --version'
```

```bash
nix shell nixpkgs#nix-info --command nix-info --markdown
nix show-config
nix show-config --json

nix verify
nix doctor 
nix path-info
nix flake metadata nixpkgs
nix shell nixpkgs#neofetch --command neofetch
```


```bash
nix \
shell \
nixpkgs#jq \
--command \
echo $(nix show-config --json) | jq -S 'keys' | wc
```


```bash
nix \
shell \
nixpkgs#jq \
--command \
echo $(nix show-config --json) | jq -M '."warn-dirty"[]'
```
TODO: create tests asserting for each key an expected value?! 
Use a fixed output derivation to test this output?

[Processing JSON using jq](https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4)
[jqplay](https://jqplay.org/s/K_-O_YrxD5)

Usefull for debug:
```bash
stat $(readlink /root/.nix-defexpr/nixpkgs)
stat $(readlink /nix/var/nix/gcroots/booted-system)
stat $(echo $(echo $NIX_PATH) | cut --delimiter='=' --field=2)
echo -e " "'"$ENV->"'"$ENV\n" '"$NIX_PATH"->'"$NIX_PATH\n" '"$PATH"->'"$PATH\n" '"$USER"->' "$USER\n"
```

Excelent:
```bash
echo "${PATH//:/$'\n'}"
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
nix-store --verify --check-contents
nix-store --verify-path $(nix-store --query --requisites $(which nix))
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
shell \
nixpkgs#{coreutils,graphviz,hello,which} \
--command \
echo $(nix-store --query --graph $(nix-store --query $(which hello))) | dot -Tps > graph.ps \
&& sha256sum graph.ps
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

unshare --user --pid echo YES



file /home/ubuntu/.nix-profile, it can be a symbolic link broken!

TODO: how to test it?
[platform_machine targetMachine](https://github.com/nix-community/poetry2nix/pull/242#discussion_r567281097)


[TODO](https://github.com/nix-community/poetry2nix/pull/242#issuecomment-770346036)
Comment showing the flakes that are broken:

`nix develop github:davhau/mach-nix#shellWith.pandas`

`nix develop github:ES-Nix/poetry2nix-examples/a39f8cf6f06af754d440458b7e192e49c95795bb`

A test for `manylinux1`:
[digital-asset daml](`https://github.com/digital-asset/daml/tree/05e691f55852fbb207f0e43cf23bb95b95866ba3/dev-env/tests/manylinux1)
from [this](https://github.com/NixOS/nixpkgs/issues/71935#issuecomment-561037597).

_manylinux.py has been removed #75763


TODO: i have many of those, join all.
`echo $NIX_PATH`

`python -c "from packaging import tags; print('\n'.join([str(t) for t in tags.sys_tags()]))" | head -10`
https://github.com/numpy/numpy/issues/17784#issuecomment-729275294

easy_install --version
Should be >= 51
easy_install --version
https://github.com/numpy/numpy/issues/17784#issuecomment-742222887



`nix develop github:davhau/mach-nix#shellWith.requests.tensorflow.aiohttp`

nix develop github:davhau/mach-nix#shellWith.numpy
nix develop github:davhau/mach-nix#shellWith.pandas
nix develop github:davhau/mach-nix#shellWith.tensorflow

From: https://discourse.nixos.org/t/mach-nix-create-python-environments-quick-and-easy/6858/76

nix build github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso


## TMP, TMPDIR, XDG_RUNTIME_DIR

WIP:

```bash
env | grep TMP
env | grep TMPDIR
env | grep XDG_RUNTIME_DIR
unset TMP
unset TMPDIR
env | grep TMP
env | grep TMPDIR
```

```bash
echo -e ${PATH//:/\\n}
echo "${PATH//:/$'\n'}"
mount | grep /run/user
```
From: https://unix.stackexchange.com/a/80153


https://unix.stackexchange.com/a/118476
df --print-type /tmp

df --human-readable --print-type "$TMPDIR"

mount | grep /run/user

https://unix.stackexchange.com/a/214386
https://superuser.com/a/542772

MKTEMP=$(mktemp --directory)
TMP={TMP:-"$MKTEMP"}
TMPDIR={TMPDIR:-"$MKTEMP"}


TODOs:
- https://github.com/NixOS/nixpkgs/issues/54707#issuecomment-522566108
- help in this: https://github.com/NixOS/nixpkgs/issues/31133
- https://www.reddit.com/r/NixOS/comments/g46m05/no_space_left_on_device_during_nixinstall/

Explanation: cd https://github.com/NixOS/nixpkgs/issues/34091#issuecomment-399680215


# Uninstalling nix


```bash
rm -rfv "$HOME"/{.nix-channels,.nix-defexpr,.nix-profile,.config/nixpkgs,.cache/nix}
sudo rm -rfv /nix
```
https://stackoverflow.com/questions/51929461/how-to-uninstall-nix#comment119190356_51935794


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


nix diff-closures /nix/var/nix/profiles/system-655-link /nix/var/nix/profiles/system-658-link
From [Add 'nix diff-closures' command](https://github.com/NixOS/nix/pull/3818).



## Broken in QEMU


`nix develop github:ES-Nix/poetry2nix-examples/a39f8cf6f06af754d440458b7e192e49c95795bb`

`nix develop github:ES-Nix/poetry2nix-examples/d0f6d7951214451fd9fe4df370576d223e1a43cc`
`nix develop github:ES-Nix/poetry2nix-examples/4b665ab9947e7d8c0d115937c3676e38836248da`


nix develop github:ES-Nix/poetry2nix-examples/4b665ab9947e7d8c0d115937c3676e38836248da

Procurei no github do numpy algo sobre esse `git clean -fxd`, achei isso, mas não me diz muito:

https://github.com/numpy/numpy/blob/76930e7d0c22e227c9ff9249a90a6254c5a6b547/doc/HOWTO_RELEASE.rst.txt#make-sure-current-branch-builds-a-package-correctly

## TODOs

- Tests, we need tests! Use `nix flake check`?
- Make the installer be as POSIX as possible, and instalable in the [toybox](http://landley.net/toybox/about.html) 
   and his talk [Toybox: Writing a New Command Line From Scratch](https://www.youtube.com/watch?v=SGmtP5Lg_t0). 
   Looks like [nix has one static binary now](https://discourse.nixos.org/t/tweag-nix-dev-update-6/11195), how to 
   throw it in an OCI image?

[Packaging with Nix](https://youtu.be/Ndn5xM1FgrY?t=1882)


Not sure it is a good place to it:

Really amazing thing: 

[Using Nix in production for the last two years by Domen Kožar (NixCon 2017)](https://www.youtube.com/embed/6TBpB-BEiIg?start=1310&end=1543&version=3)

"We were doing snab high-speed networking protocol"  

TODO: slice this in a sane, ready to copy paste url citation thing.

Starts in 1343 
"We would use and we would use and Hidra basically to gc boot benchmarks one per
machine and with specialized software in a control team isolated environment run 
those benchmark. 

So what we wanted to know is that if we take different 
kind of `kernel version` different kind of `QEMU` and different kind of `our X` software 
and so on build bigger build metrics of things and see if there's any 
regressions. 

We also had support to patch those so you could like for 
example we had some patches so we could compare the patch software versus other 
software." 

"
The evaluation took like 20 minutes.
With this change it only took 10 seconds. 
"
Duration 6 seconds [Using Nix in production for the last two years by Domen Kožar (NixCon 2017)](https://www.youtube.com/embed/6TBpB-BEiIg?start=1438&end=1446&version=3)


TODO: this thing must be a flake!


TODO: Transform this in a test [Sometimes you will want to turn an alias into a function, but when you source the bashrc file, a weird error may occur:](https://unix.stackexchange.com/a/383807)
, so it looks like is possible to have problem with the installer.


### nix statically built WIP

```
SHA256=fd1f59eaf2f5f5a13de867a7d49558a25b4cfcff \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/nix-static.sh | sh \
&& . ~/.bashrc \
&& nix --version \
&& nix store gc
```

```
nix \
build \
github:ES-Nix/nix-oci-image/nix-static-unpriviliged#oci.nix-static-toybox-static-ca-bundle-etc-passwd-etc-group-tmp
```

`[0/1 built] Real-time signal 0` why?

https://stackoverflow.com/questions/6345973/who-uses-posix-realtime-signals-and-why

strings $HOME/bin/nix | grep Real


nix-build -A pkgsStatic.nix
From: https://github.com/NixOS/nixpkgs/pull/56281


TODO: make tests for this in QEMU
https://github.com/NixOS/nixpkgs/pull/56281#issuecomment-484242510


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


[Eelco in discourse.nixos](https://discourse.nixos.org/t/building-a-statically-linked-nix-for-hpc-environments/10865/18)

TODO: https://youtu.be/Ndn5xM1FgrY?t=329 and https://youtu.be/Ndn5xM1FgrY?t=439

[Nix Portable: Nix - Static, Permissionless, Install-free, Pre-configured](https://discourse.nixos.org/t/nix-portable-nix-static-permissionless-install-free-pre-configured/11719)


> Oh yeah, chroot stores won’t work on macOS. Neither will proot. Having a flat-file binary cache in the shared dir and copying to/from that will be your only option there.
[How to use a local directory as a nix binary cache?](https://discourse.nixos.org/t/how-to-use-a-local-directory-as-a-nix-binary-cache/655/14)


In this [issue comment](https://github.com/NixOS/nixpkgs/pull/70024#issuecomment-717568914)
[see too](https://matthewbauer.us/blog/static-nix.html).
nix build github:NixOS/nix#nix-static

where nix is the static nix from https://matthewbauer.us/nix and a pkgsStatic.busybox
RUN ln -sf /bin/busybox /bin/sh
https://discourse.nixos.org/t/dockertools-buildimage-and-user-writable-tmp/5397/8

TODO: use this to troubleshoot
- https://stackoverflow.com/a/22686512
- https://serverfault.com/a/615344


TODO: `umask` 
https://github.com/NixOS/nix/issues/2377#issuecomment-633165541
https://ivanix.wordpress.com/tag/umask/


### Install direnv and nix-direnv using nix + flakes

```bash
SHA256=4fbc7498d5b08c4543ad040463eb0bf212acc70f \
&& curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/"$SHA256"/install_direnv_and_nix_direnv.sh | sh \
&& . ~/."$(ps -ocomm= -q $$)"rc \
&& . ~/.direnvrc \
&& direnv --version
```

#### Testing the direnv's instalation

```bash
SHA256=4fbc7498d5b08c4543ad040463eb0bf212acc70f \
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


#### Troubleshoot direnv and nix-direnv

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



## Tests


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
--env=DISPLAY=':0.0' \
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
nix \
develop \
github:ES-Nix/nix-flakes-shellHook-writeShellScriptBin-defaultPackage/65e9e5a64e3cc9096c78c452b51cc234aa36c24f \
--command \
podman \
run \
--interactive=true \
--tty=true \
alpine:3.13.0 \
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
github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso
```

```bash
nix \
build \
github:ES-Nix/nixosTest/2f37db3fe507e725f5e94b42a942cdfef30e5d75#checks.x86_64-linux.test-nixos
```


That is insane to be possible, but it is, well hope it does not brake for you:

```
$ nix shell nixpkgs/7138a338b58713e0dea22ddab6a6785abec7376a#{\
gcc10,\
gcc6,\
gfortran10,\
gfortran6,\
julia,\
nodejs,\
poetry,\
python39,\
rustc,\
yarn\
}

gcc --version
#gcc6 --version
gfortran10 --version
gfortran6 --version
julia --version
nodejs --version
poetry --version
python3 --version
rustc --version
yarn --version
```


### Install zsh

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


`env | sort`
`ps -aux | grep apt`

cat /etc/passwd | grep sh
From: https://askubuntu.com/a/1206350

stat "$(which chsh)"
