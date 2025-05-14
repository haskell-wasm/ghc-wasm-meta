#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"
curl -f -L https://github.com/haskell-fswatch/hfsnotify/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" .
wasm32-wasi-cabal build all
wasm32-wasi-cabal list-bin exe:example
$CROSS_EMULATOR "$(wasm32-wasi-cabal list-bin exe:example)"
popd
