#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

git clone --depth=1 https://github.com/IntersectMBO/cardano-api.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm-meta "git+file://$CI_PROJECT_DIR"

. <(nix print-dev-env .#wasm)

sed -i \
  -e "0,/-no-hs-main/s/-no-hs-main//" \
  -e "s/,--strip-all//g" \
  cardano-wasm/cardano-wasm.cabal

wasm32-wasi-cabal update

wasm32-wasi-cabal build \
  cardano-wasm:cardano-wasi \
  cardano-wasm:cardano-wasm

exec wasmtime run "$(wasm32-wasi-cabal list-bin cardano-wasm:cardano-wasi)"
