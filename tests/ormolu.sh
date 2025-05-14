#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"
git clone --depth=1 https://github.com/tweag/ormolu.git .
sed -i \
  -e '/index-state:/d' \
  cabal.project
cd ormolu-live
sed -i \
  -e '/index-state:/d' \
  cabal.project
cp $CI_PROJECT_DIR/cabal.project.local .
npm ci
npm install -g --prefix /tmp/.ghc-wasm/nodejs esbuild
./build.sh prod
popd
