#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/sass/dart-sass/releases/download/1.93.2/dart-sass-1.93.2-linux-x64.tar.gz | tar xz --strip-components=1
export PATH=$PATH:$PWD:/opt/toolchain/bin
popd

pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/tweag/ghc-wasm-miso-examples/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
printf "package *\n  optimization: 2\n" >> cabal.project.local
pushd frontend
./build.sh
export TODOMVC_DIST_DIR=$PWD/dist
pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/haskell-wasm/playwright/archive/refs/heads/release-1.55.tar.gz | tar xz --strip-components=1
cd examples/todomvc
npm install
npx playwright install --with-deps --no-shell
npx playwright test --reporter=list --retries=2 --workers=$(($CPUS > 8 ? 8 : $CPUS))
popd
popd
popd
