#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/haskell/time/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" .
sed -i -e '/time/d' cabal.project.local
autoreconf -i
wasm32-wasi-cabal test --test-wrapper="$CROSS_EMULATOR"
popd
