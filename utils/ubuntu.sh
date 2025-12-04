#!/bin/sh

exec podman run -it --rm \
  --env CI=true \
  --env CI_PROJECT_DIR=/workspace \
  --env CPUS=48 \
  --env FLAVOUR="$1" \
  --env PLAYWRIGHT=1 \
  --user root \
  --init \
  --volume ~/workspace/.codex:/root/.codex \
  --volume "$PWD":/workspace \
  --workdir /workspace \
  registry.gitlab.haskell.org/ghc/ci-images/x86_64-linux-ubuntu24_04:a97d5c67d803c6b3811c6cccdf33dc8e9d7eafe3 \
  bash -c \
  "apt update && apt full-upgrade -y && apt install -y bash-completion nano zstd && cp /etc/skel/{.bash_logout,.bashrc,.profile} /root && PREFIX=/tmp/.ghc-wasm ./setup.sh && . /tmp/.ghc-wasm/env && exec bash -i"
