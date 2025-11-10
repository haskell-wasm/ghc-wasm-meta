#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

curl -L https://github.com/AndrasKovacs/flatparse/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" cabal.project.local
wasm32-wasi-cabal build --enable-tests --enable-benchmarks
wasm32-wasi-cabal test --test-wrapper="$CROSS_EMULATOR"
