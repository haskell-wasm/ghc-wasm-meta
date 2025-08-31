#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

curl -L https://github.com/cu1ch3n/type-inference-zoo/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
wasm32-wasi-cabal build --enable-tests
wasm32-wasi-cabal test --test-wrapper="$CROSS_EMULATOR"

popd
