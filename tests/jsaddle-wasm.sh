#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -f -L https://github.com/amesgen/jsaddle-wasm/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
cp "$CI_PROJECT_DIR/cabal.project.local" .
wasm32-wasi-cabal build all
popd
