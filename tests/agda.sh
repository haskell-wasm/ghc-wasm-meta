#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"
git clone --branch=v2.7.0.1 --depth=1 --recurse-submodules --shallow-submodules --jobs=2 https://github.com/agda/agda.git .
curl -L https://raw.githubusercontent.com/agda-web/agda-wasm-dist/refs/heads/master/agda-wasm.patch | git apply
cp $CI_PROJECT_DIR/cabal.project.local .
echo "package unix-compat" >> cabal.project.local
echo "  ghc-options: -optc-Wno-error=implicit-function-declaration" >> cabal.project.local
wasm32-wasi-cabal build agda
$CROSS_EMULATOR "$(wasm32-wasi-cabal list-bin agda)" --help
popd
