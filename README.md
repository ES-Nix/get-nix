# get-nix
Is a unofficial wrapper of the nix installer.


```
curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/58f35094a75cfedbd4e683d1c356ee31833b2124/get-nix.sh | sh
. "$HOME"/.nix-profile/etc/profile.d/nix.sh
. ~/.bashrc
flake
```

```
apt-get update
apt-get install -y curl
```

Some times usefull:
`sudo rm --recursive /nix`

`du --dereference --human-readable --summarize /nix`


Broken:
nix shell nixpkgs#jq --command "nix show-config --json | jq -S 'keys' | wc"

TODO: create tests asserting for each key an expected value?! 
Use a fixed output derivation to test this output?
nix show-config --json | jq -M '."warn-dirty"[]


`nix develop github:davhau/mach-nix#shellWith.requests.tensorflow.aiohttp`

nix develop github:davhau/mach-nix#shellWith.numpy
nix develop github:davhau/mach-nix#shellWith.pandas
nix develop github:davhau/mach-nix#shellWith.tensorflow

From: https://discourse.nixos.org/t/mach-nix-create-python-environments-quick-and-easy/6858/76

nix build github:cole-h/nixos-config/6779f0c3ee6147e5dcadfbaff13ad57b1fb00dc7#iso


```
docker run \
--interactive \
--tty \
--rm \
lnl7/nix:2.3.7 bash
```

```
curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/58f35094a75cfedbd4e683d1c356ee31833b2124/install-lnl7-oci.sh | sh
. ~/.bashrc
flake
```


## Broken in QEMU

nix develop github:ES-Nix/poetry2nix-examples/a39f8cf6f06af754d440458b7e192e49c95795bb

nix develop github:ES-Nix/poetry2nix-examples/d0f6d7951214451fd9fe4df370576d223e1a43cc
