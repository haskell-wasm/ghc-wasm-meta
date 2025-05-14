#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"
curl -f -L https://github.com/fourmolu/fourmolu/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
sed -i \
  -e '/index-state:/d' \
  cabal.project
cd web/fourmolu-wasm
cp $CI_PROJECT_DIR/cabal.project.local .
./build.sh
popd
