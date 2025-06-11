#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/haskell-wasm/network/archive/refs/heads/wasi.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" .
autoreconf -i
wasm32-wasi-cabal build
popd
