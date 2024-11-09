#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
echo "import System.Environment.Blank" >> hello.hs
echo 'main = print =<< getArgs' >> hello.hs
wasm32-wasi-ghc hello.hs -o hello.wasm
$CROSS_EMULATOR ./hello.wasm "114 514" 1919810
# wasm-run ./hello.wasm "114 514" 1919810
wasmtime run ./hello.wasm "114 514" 1919810
bun run ./hello.wasm "114 514" 1919810
wasmedge run -- ./hello.wasm "114 514" 1919810
wazero run ./hello.wasm -- "114 514" 1919810
popd
