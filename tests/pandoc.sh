#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"
curl -L https://github.com/haskell-wasm/pandoc/archive/refs/heads/wasm.tar.gz | tar xz --strip-components=1
wasm32-wasi-cabal build pandoc-cli
PANDOC_WASM="$(find dist-newstyle -type f -name pandoc.wasm)"

wasmtime run --dir "$PWD"::/ -- "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/WasmEdge/WasmEdge/releases/download/0.14.1/WasmEdge-0.14.1-ubuntu20.04_x86_64.tar.gz | tar xz --strip-components=1
export PATH=$PATH:$PWD/bin
popd

wasmedge run --enable-tail-call --dir /:"$PWD" -- "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/yamt/toywasm/releases/download/v66.0.0/toywasm-v66.0.0-full-ubuntu-20.04-amd64.tgz | tar xz
export PATH=$PATH:$PWD/bin
popd

toywasm --wasi --wasi-dir "$PWD"::/ -- "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/oven-sh/bun/releases/download/bun-v1.2.8/bun-linux-x64.zip -O
unzip bun-linux-x64.zip
BUN=$PWD/bun-linux-x64/bun
popd

env -i "$BUN" run "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

popd
