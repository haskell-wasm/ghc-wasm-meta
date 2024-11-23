#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/konn/humblr/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
rm -f ./*.freeze
cp $CI_PROJECT_DIR/cabal.project.local cabal-wasm.project.local
sed -i \
  -e 's@amesgen/miso@dmjio/miso@' \
  -e 's/bb9ce9a3dd03a7c1ac945943f65955ab10a53011/9d15de0001b7afb98e0983e7bc09ca81faa681fd/' \
  cabal-common.project
sed -i \
  -e '/with-compiler:/d' \
  -e '/jobs:/d' \
  -e '/optimization:/d' \
  -e 's@amesgen/miso@dmjio/miso@' \
  -e 's/bb9ce9a3dd03a7c1ac945943f65955ab10a53011/9d15de0001b7afb98e0983e7bc09ca81faa681fd/' \
  cabal-wasm.project
wasm32-wasi-cabal --project-file=cabal-wasm.project build all
popd
