#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/haskell/bzlib/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
mv cabal.project.wasi cabal.project.local
cat "$CI_PROJECT_DIR/cabal.project.local" >> cabal.project.local
wasm32-wasi-cabal test --test-wrapper="$CROSS_EMULATOR"
popd
