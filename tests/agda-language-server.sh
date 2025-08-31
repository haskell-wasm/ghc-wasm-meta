#!/usr/bin/env bash

set -euo pipefail

export PATH=$PATH:/opt/toolchain/bin

pushd "$(mktemp -d)"

git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/agda/agda-language-server.git .

pushd wasm-submodules/network
autoreconf -i
popd

mv cabal.project.wasm32 cabal.project
echo "tests: True" >> cabal.project.local
echo "package agda-language-server" >> cabal.project.local
echo "  flags: +Agda-2-7-0" >> cabal.project.local
cat "$CI_PROJECT_DIR/cabal.project.local" >> cabal.project.local

wasm32-wasi-cabal build
$CROSS_EMULATOR "$(find . -name als.wasm)" --help

popd
