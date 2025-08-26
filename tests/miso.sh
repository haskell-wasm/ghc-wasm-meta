#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/dmjio/miso/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" .
sed -i \
  -e '/index-state:/d' \
  cabal.project
wasm32-wasi-cabal build
popd
