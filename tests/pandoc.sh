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

wasmi_cli --dir "$PWD" -- "$PANDOC_WASM" "$PWD/README.md" -o "$PWD/README.rst"
head --lines=20 README.rst
rm README.rst

pushd "$(mktemp -d)"
curl -L https://github.com/WasmEdge/WasmEdge/releases/download/0.15.0/WasmEdge-0.15.0-manylinux_2_28_x86_64.tar.xz | tar xJ
export PATH=$PATH:$PWD/bin
popd

wasmedge run --enable-tail-call --dir /:"$PWD" -- "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/yamt/toywasm/releases/download/v71.0.0/toywasm-v71.0.0-full-ubuntu-22.04-amd64.tgz | tar xz
export PATH=$PATH:$PWD/bin
popd

toywasm --wasi --wasi-dir "$PWD"::/ -- "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

pushd "$(mktemp -d)"
curl -f -L --retry 5 https://github.com/oven-sh/bun/releases/download/bun-v1.2.21/bun-linux-x64.zip -O
unzip bun-linux-x64.zip
BUN=$PWD/bun-linux-x64/bun
popd

env -i "$BUN" run "$PANDOC_WASM" README.md -o README.rst
head --lines=20 README.rst
rm README.rst

popd
