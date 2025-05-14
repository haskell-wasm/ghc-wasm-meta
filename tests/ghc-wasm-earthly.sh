#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/konn/ghc-wasm-earthly/archive/refs/heads/ghc-9.12.tar.gz | tar xz --strip-components=1
rm -f ./*.freeze
cp "$CI_PROJECT_DIR/cabal.project.local" cabal-wasm.project.local
sed -i \
  -e '/active-repositories:/d' \
  -e '/index-state:/d' \
  -e '/with-/d' \
  -e '/optimization:/d' \
  cabal-wasm.project
wasm32-wasi-cabal --project-file=cabal-wasm.project build all
popd
