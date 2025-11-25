#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/haskell-wasm/jsaddle-wasm.git .
cp "$CI_PROJECT_DIR"/cabal.project.local .
wasm32-wasi-cabal build miso-todomvc --dry-run
cp -r dist-newstyle/src/miso-todo*/static public
wasm32-wasi-cabal install miso-todomvc --install-method=copy --installdir=public
"$(wasm32-wasi-ghc --print-libdir)"/post-link.mjs --input public/app.wasm --output public/ghc_wasm_jsffi.js
export TODOMVC_DIST_DIR=$PWD/public

git clone --depth=1 https://github.com/haskell-wasm/playwright.git
cd playwright/examples/todomvc
npm install
npx playwright install --with-deps --no-shell
npx playwright test --reporter=list --workers=$(($CPUS > 8 ? 8 : $CPUS))
