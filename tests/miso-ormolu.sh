#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/sass/dart-sass/releases/download/1.80.6/dart-sass-1.80.6-linux-x64.tar.gz | tar xz --strip-components=1
export PATH=$PATH:$PWD:/opt/toolchain/bin
popd

pushd "$(mktemp -d)"
curl -L https://github.com/tweag/ghc-wasm-miso-examples/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
pushd frontend
./build.sh
popd
popd

pushd "$(mktemp -d)"
curl -L https://hackage.haskell.org/package/ormolu-0.7.7.0/ormolu-0.7.7.0.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
wasm32-wasi-cabal build -finternal-bundle-fixities
popd
