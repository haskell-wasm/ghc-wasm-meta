#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/haskell-wasm/jsaddle-wasm.git .
cp "$CI_PROJECT_DIR"/cabal.project.local cabal.debug.project.local
cp "$CI_PROJECT_DIR"/cabal.project.local cabal.release.project.local

wasm32-wasi-cabal --project-file=cabal.release.project build miso-todomvc --dry-run
cp -r dist-newstyle/src/miso-todo*/static public
wasm32-wasi-cabal --project-file=cabal.release.project install miso-todomvc --install-method=copy --installdir=public
"$(wasm32-wasi-ghc --print-libdir)"/post-link.mjs --input public/app.wasm --output public/ghc_wasm_jsffi.js
export TODOMVC_DIST_DIR=$PWD/public

git clone --depth=1 https://github.com/haskell-wasm/playwright.git
pushd playwright/examples/todomvc
npm install
npx playwright install --with-deps --no-shell
npx playwright test --reporter=list --workers=$(($CPUS > 8 ? 8 : $CPUS))
popd

wasm32-wasi-cabal --project-file=cabal.debug.project install miso-todomvc --install-method=copy --installdir=public --overwrite-policy=always
"$(wasm32-wasi-ghc --print-libdir)"/post-link.mjs --input public/app.wasm --output public/ghc_wasm_jsffi.js
sed -i -e "s/-H64m/-DS/" public/index.js

pushd playwright/examples/todomvc
npx playwright test --reporter=list --timeout=60000 --workers=$(($CPUS > 8 ? 8 : $CPUS))
popd
