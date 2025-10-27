#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/bradrn/brassica/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" cabal-wasm.project.local
wasm32-wasi-cabal --project-file=cabal-wasm.project build brassica-interop-wasm
popd
