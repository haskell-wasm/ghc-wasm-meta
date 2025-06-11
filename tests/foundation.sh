#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/haskell-wasm/foundation/archive/refs/heads/wasm.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" .
wasm32-wasi-cabal build basement
popd
