#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/konn/humblr/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
rm -f ./*.freeze
cp $CI_PROJECT_DIR/cabal.project.local cabal-wasm.project.local
sed -i \
  -e '/with-/d' \
  -e '/-location:/d' \
  -e '/program-locations/d' \
  -e '/jobs:/d' \
  -e '/optimization:/d' \
  cabal-wasm.project
wasm32-wasi-cabal --project-file=cabal-wasm.project build all
popd
