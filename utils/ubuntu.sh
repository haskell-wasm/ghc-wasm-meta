#!/bin/sh

exec podman run -it --rm \
  --userns=keep-id:uid=1001,gid=1001 \
  --env CI=true \
  --env CI_PROJECT_DIR=/workspace \
  --env CPUS=16 \
  --env FLAVOUR="$1" \
  --env PLAYWRIGHT=1 \
  --init \
  --volume "$PWD":/workspace \
  --workdir /workspace \
  registry.gitlab.haskell.org/ghc/ci-images/x86_64-linux-ubuntu24_04:73b50b6775bef17915914bccc17d15eb818a5dac \
  bash -c \
  "sudo apt update && sudo apt full-upgrade -y && sudo apt install -y bash-completion btrfs-progs nano zstd && PREFIX=/home/ghc/.ghc-wasm ./setup.sh && . /home/ghc/.ghc-wasm/env && exec bash -i"
