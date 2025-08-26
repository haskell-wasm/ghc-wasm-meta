#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

curl -L https://github.com/koalaman/shellcheck/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
wasm32-wasi-cabal build
$CROSS_EMULATOR "$(wasm32-wasi-cabal list-bin shellcheck)" --help

popd
