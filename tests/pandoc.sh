#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"
curl -L https://github.com/TerrorJack/pandoc/archive/refs/heads/wasm.tar.gz | tar xz --strip-components=1
wasm32-wasi-cabal build pandoc-cli
popd
