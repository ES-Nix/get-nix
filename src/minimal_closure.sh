#!/bin/bash

# See https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
#set -euxo pipefail

set -x


chmod 0755 -Rv /nix/store \
&& echo "$(nix-store --query --requisites "$(which nix)")" | tr ' ' '\n' | xargs -I{} chmod 0555 -Rv {} \
&& chmod 0444 -v "$HOME"/.nix-profile/etc/profile.d/nix.sh \
&& chmod 0444 -v "$(readlink "$HOME"/.cache/nix/flake-registry.json)" \
&& rm -frv /nix/store/ 2> /dev/null

mkdir --parent --mode=0755 "$HOME"/store \
&& cp \
   --no-dereference \
   --recursive \
   --verbose \
   $(nix-store --query --requisites "$(which nix)") \
   "$HOME"/store \
&& cp "$(readlink "$HOME"/.cache/nix/flake-registry.json)" "$HOME"/store \
&& mkdir -p "$HOME"/store/.nix-profile/etc/profile.d \
&& cp \
   --no-dereference \
   --recursive \
   --verbose \
   "$HOME"/.nix-profile/etc/profile.d/nix.sh \
   "$HOME"/store/.nix-profile/etc/profile.d



echo "$(nix-store --query --requisites "$(which nix)")" | tr ' ' '\n' | xargs -I{} cp -Rv {} "$HOME"/aux-nix/


ldd $(which nix) | wc -l

ldd $(which nix) | grep nix | sed 's/.* => //' | sed 's/ .*//' | cut -d/ -f1-4 | sort | uniq | wc -l

ldd "$(which nix)" | grep nix | sed 's/.* => //' | sed 's/ .*//' | cut -d/ -f1-4 | sort | uniq > nix-ldd.txt


echo "$(echo "$(nix-store --query --requisites "$(which nix)")" | tr ' ' '\n' | sort)" > nix-requisites.txt
echo "$(echo /nix/store/* | tr ' ' '\n' | sort)" > nix-store.txt
diff nix-requisites.txt nix-store.txt

find / -name '*flake-registry.json' -exec echo -- {} + 2> /dev/null
"$HOME"/.cache/nix/flake-registry.json

nix \
registry \
add \
--registry "$HOME"/custom-flake-registry.json nixpkgs github:NixOS/nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc


echo /nix/store/*-bootstrap-tools.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bootstrap-tools.drv >> tmp-nix-requisites.txt
echo /nix/store/*-libunistring-0.9.10.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-zlib-1.2.11.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-perl-5.34.0.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bison-3.7.6.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-m4-1.4.19.tar.bz2.drv >> tmp-nix-requisites.txt
echo /nix/store/*-gettext-0.21.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-xz-5.2.5.tar.bz2.drv >> tmp-nix-requisites.txt
echo /nix/store/*-binutils-2.35.1.tar.bz2.drv >> tmp-nix-requisites.txt
echo /nix/store/*-texinfo-6.8.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-libidn2-2.3.2.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-libffi-3.4.2.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bzip2-1.0.6.0.2.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-libtool-2.4.6.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-automake-1.16.3.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-autoconf-2.71.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-gettext-1.07.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-help2man-1.48.1.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-expat-2.4.1.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-005.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-002.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-004.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-008.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-003.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-006.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-001.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash-5.1.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-bash51-007.drv >> tmp-nix-requisites.txt
echo /nix/store/*-Python-3.9.6.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-locale-C.diff.drv >> tmp-nix-requisites.txt
echo /nix/store/*-glibc-2.33.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-glibc-reinstate-prlimit64-fallback.patch?id=eab07e78b691ae7866267fc04d31c7c3ad6b0eeb.drv >> tmp-nix-requisites.txt
echo /nix/store/*-patchelf-0.13.tar.bz2.drv >> tmp-nix-requisites.txt
echo /nix/store/*-gmp-6.2.1.tar.bz2.drv >> tmp-nix-requisites.txt
echo /nix/store/*-mpfr-4.1.0.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-isl-0.20.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-mpc-1.2.1.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-gcc-10.3.0.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-libelf-0.8.13.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-which-2.21.tar.gz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-tar-1.34.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-pcre-8.44.tar.bz2.drv >> tmp-nix-requisites.txt
echo /nix/store/*-findutils-4.8.0.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-sed-4.8.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-patch-2.7.6.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-ed-1.17.tar.lz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-diffutils-3.8.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-gawk-5.1.0.tar.xz.drv >> tmp-nix-requisites.txt
echo /nix/store/*-make-4.3.tar.gz.drv >> tmp-nix-requisites.txt

ldd "$(which nix)" | grep nix | sed 's/.* => //' | sed 's/ .*//' | cut -d/ -f1-4 > tmp-nix-requisites.txt
echo "$(readlink "$HOME"/.cache/nix/flake-registry.json)" >> tmp-nix-requisites.txt

echo "$(nix-store --query --requisites "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)")" >> tmp-nix-requisites.txt
echo "$(nix-store --query --referrers-closure --include-outputs "$(nix eval --raw nixpkgs/cb3a0f55e8e37c4f7db239ce27491fd66c9503cc#nixFlakes)")" >> tmp-nix-requisites.txt

cat tmp-nix-requisites.txt | sort | uniq > nix-requisites.txt

echo /nix/store/* | tr ' ' '\n' > all-nix-store.txt

cat nix-requisites.txt | wc -l
cat all-nix-store.txt | wc -l

grep -v -f nix-requisites.txt all-nix-store.txt | wc -l

grep -v -f nix-requisites.txt all-nix-store.txt | xargs -I{} chmod 0755 -Rv {}
grep -v -f nix-requisites.txt all-nix-store.txt | xargs -I{} rm -frv {}

rm -frv {tmp-nix-requisites.txt,nix-requisites.txt,all-nix-store.txt}

nix run nixpkgs#hello
nix run nixpkgs#hello
nix shell nixpkgs#python3 --command python --version
nix shell nixpkgs#python3 --command python --version

mkdir backup
cp -r /nix/store/ backup/

echo $(nix run nixpkgs#hello 2>&1 >/dev/null) | cut -d/ -f 4 | cut -d"'" -f1 | xargs -I{} cp -v backup/store/{} /nix/store/

echo $(nix run nixpkgs#hello 2>&1 >/dev/null) | cut -d/ -f 4 | cut -d"'" -f1 | xargs -I{} cp -v backup/store/{} /nix/store/ | sed 's/.* -> //' >> out.txt

# Almost works:
# grep -v -f nix-requisites.txt all-nix-store.txt | xargs nix store delete
