#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

workdir=$(mktemp -d)
trap 'rm -rf "$workdir"' EXIT

cd "$workdir"

git clone --depth=1 https://github.com/agda/agda-language-server.git .
git submodule update --init --recursive --depth=1 --jobs=4

pushd wasm-submodules/agda
git fetch --depth 1 origin agda-web/release-v2.8.0
git checkout FETCH_HEAD
popd

pushd wasm-submodules/network
autoreconf -i
popd

mv cabal.project.wasm32 cabal.project
echo "tests: False" >> cabal.project.local
# lsp-2.8.0.0 -> websockets -> entropy, custom Setup
echo "constraints: lsp < 2.8.0.0" >> cabal.project.local
echo "package agda-language-server" >> cabal.project.local
echo "  flags: +Agda-2-8-0" >> cabal.project.local
cat "$CI_PROJECT_DIR/cabal.project.local" >> cabal.project.local

wasm32-wasi-cabal build
$CROSS_EMULATOR "$(find . -name als.wasm)" --help
