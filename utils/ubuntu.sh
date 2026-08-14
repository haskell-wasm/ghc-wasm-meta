#!/bin/sh

exec podman run -it --rm \
  --userns=keep-id:uid=1001,gid=1001 \
  --env CI=true \
  --env CI_PROJECT_DIR=/workspace \
  --env CPUS=16 \
  --env FLAVOUR="$1" \
  --env PLAYWRIGHT=1 \
  --init \
  --tmpfs /tmp:exec \
  --volume "$PWD":/workspace \
  --workdir /workspace \
  ghcr.io/christopherhx/runner-images:ubuntu26-runner-large-latest \
  bash -c \
  "cabal update --ignore-project && cabal install --ignore-project alex happy && ./setup.sh && . ~/.ghc-wasm/env && exec bash -i"
