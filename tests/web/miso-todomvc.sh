#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

curl -L https://github.com/haskell-miso/miso-todomvc/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR"/cabal.project.local .
make
export TODOMVC_DIST_DIR=$PWD/public

pushd "$(mktemp -d)"
curl -L https://github.com/haskell-wasm/playwright/archive/refs/heads/release-1.56.tar.gz | tar xz --strip-components=1
cd examples/todomvc
npm install
npx playwright install --with-deps --no-shell
npx playwright test --reporter=list --retries=2 --workers=$(($CPUS > 8 ? 8 : $CPUS))
popd

popd
