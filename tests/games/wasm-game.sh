#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

curl -L https://github.com/Tritlo/wasm-game/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
sed -i -e "/CHANGELOG.md/d" test.cabal
wasm32-wasi-cabal install --install-method=copy --installdir=app
"$(wasm32-wasi-ghc --print-libdir)"/post-link.mjs --input app/test.wasm --output app/ghc_wasm_jsffi.js
