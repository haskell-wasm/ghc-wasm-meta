#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/sass/dart-sass/releases/download/1.81.0/dart-sass-1.81.0-linux-x64.tar.gz | tar xz --strip-components=1
export PATH=$PATH:$PWD:/opt/toolchain/bin
popd

pushd "$(mktemp -d)"
curl -L https://github.com/tweag/ghc-wasm-miso-examples/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
echo "source-repository-package" >> cabal.project.local
echo "  type: git" >> cabal.project.local
echo "  location: https://github.com/dmjio/miso.git" >> cabal.project.local
echo "  tag: 9d15de0001b7afb98e0983e7bc09ca81faa681fd" >> cabal.project.local
pushd frontend
./build.sh
popd
popd

pushd "$(mktemp -d)"
curl -L https://github.com/tweag/ghc-wasm-reflex-examples/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
pushd frontend
./build.sh
popd
popd

if [[ "$FLAVOUR" == 9.10 ]]; then
  pushd "$(mktemp -d)"
  curl -L https://hackage.haskell.org/package/ormolu-0.7.7.0/ormolu-0.7.7.0.tar.gz | tar xz --strip-components=1
  cp $CI_PROJECT_DIR/cabal.project.local .
  wasm32-wasi-cabal build -finternal-bundle-fixities
  popd
fi
