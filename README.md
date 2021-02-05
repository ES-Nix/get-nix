# get-nix

Is a unofficial wrapper of the nix installer, unstable for now.


```
curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/9f55ec4ff27ad64e2704855bfcc4bd1dd697b460/get-nix.sh | sh
. "$HOME"/.nix-profile/etc/profile.d/nix.sh
. ~/.bashrc
flake
nix --version
```


You may need to install curl (sad, i know):
```
apt-get update
apt-get install -y curl
```

Some times usefull:
`sudo rm --recursive /nix`

When you get a error like this (only after many huge builds, but depends how much memory you have)
`error: committing transaction: database or disk is full (in '/nix/var/nix/db/db.sqlite')`

For check memory:
`du --dereference --human-readable --summarize /nix`
`nix path-info --json --all | jq 'map(.narSize) | add'`


## Troubleshoot commands

TODO: `nix show-config` really cool!

See too nix --option` and `nix --help-config`.


Broken:
nix shell nixpkgs#jq --command "nix show-config --json | jq -S 'keys' | wc"

TODO: create tests asserting for each key an expected value?! 
Use a fixed output derivation to test this output?
nix show-config --json | jq -M '."warn-dirty"[]

[Processing JSON using jq](https://gist.github.com/olih/f7437fb6962fb3ee9fe95bda8d2c8fa4)
[jqplay](https://jqplay.org/s/K_-O_YrxD5)

Usefull for debug:
```
stat $(readlink /root/.nix-defexpr/nixpkgs)
stat $(readlink /nix/var/nix/gcroots/booted-system)
stat $(echo $(echo $NIX_PATH) | cut --delimiter='=' --field=2)
echo -e " "'"$ENV->"'"$ENV\n" '"$NIX_PATH"->'"$NIX_PATH\n" '"$PATH"->'"$PATH\n" '"$USER"->' "$USER\n"
```

For detect KVM:
```
egrep -c '(vmx|svm)' /proc/cpuinfo
egrep -q 'vmx|svm' /proc/cpuinfo && echo yes || echo no
```
TODO: use ripgrep?
https://github.com/actions/virtual-environments/issues/183#issuecomment-580992331
https://github.com/sickcodes/Docker-OSX/issues/15#issuecomment-640088527
https://minikube.sigs.k8s.io/docs/drivers/kvm2/#installing-prerequisites

That is insane to possible, but it is:
nix shell nixpkgs#{rustc,python39,julia,gcc10,gcc6,gfortran10,gfortran6,nodejs14,poetry,yarn}
rustc --version
python39 --version
julia15 --version
node --version
rustc --version
gcc10 --version
g++ --version


TODO: make a flake with all this and more thigs hard to install and with a level of controll of revisons of commits!


## 

Many commands to check/help to troubleshoot:
```
nix verify
nix doctor 
nix path-info
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


nix optimise-store

nix-store --gc --print-roots
nix-store --gc --print-live
nix-store --gc --print-dead

nix-store --query --requisites $(which nix) | cat
nix-store --query --requisites --include-outputs $(which nix) | cat


nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which nix)) | cat

nix-store --query --graph --include-outputs $(nix-store --query --deriver $(which nix)) | dot -Tps > graph.ps
```


nix shell nixpkgs#{graphviz,okular,hello,curl,wget}
nix-store --query --graph $(nix-store --query $(which hello)) | dot -Tps > graph.ps

nix shell nixpkgs#{graphviz,okular,qgis}
nix-store --query --graph $(nix-store --query $(which qgis)) | dot -Tps > graph.ps

nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which nixFlakes)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which commonsCompress)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which gnutar)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which lzma.bin)) | cat
nix-store --query --tree --include-outputs $(nix-store --query --deriver $(which git)) | cat

Really cool:
```
du --human-readable --summarize --total $(nix-store --query --requisites $(which nix)) | sort --human-numeric-sort
```

unshare --user --pid echo YES



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

TODO: test it, a think it is broken :facepalm:
```
docker run \
--interactive \
--tty \
--rm \
lnl7/nix:2.3.7 bash -c 'nix-env --install --attr nixpkgs.curl && curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/e47ab707cfd099a6669e7a2e47aeebd36e1c101d/install-lnl7-oci.sh | sh && . ~/.bashrc && flake'
```

Splited in two steps: 
```
docker run \
--interactive \
--tty \
--rm \
lnl7/nix:2.3.7 bash
```

```
nix-env --install --attr nixpkgs.curl
curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/e47ab707cfd099a6669e7a2e47aeebd36e1c101d/install-lnl7-oci.sh | sh
. ~/.bashrc
flake
```


## Podman 

```
podman run \
--interactive \
--runtime $(which runc) \
--signature-policy policy.json \
--tty \
--rm \
docker.io/lnl7/nix:2.3.7 bash -c 'nix-env --install --attr nixpkgs.curl && curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/e47ab707cfd099a6669e7a2e47aeebd36e1c101d/install-lnl7-oci.sh | sh && . ~/.bashrc && flake'
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
   throw it in a OCI image?




Not sure it is a good place to it:

Really amazing thing: 

[Using Nix in production for the last two years by Domen Kožar (NixCon 2017)](https://www.youtube.com/embed/6TBpB-BEiIg?start=1310&end=1543&version=3)

"We were doing snab high-speed networking protocol and and  

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