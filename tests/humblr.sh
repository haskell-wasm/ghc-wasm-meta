#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/konn/humblr/archive/refs/heads/main.tar.gz | tar xz --strip-components=1
rm -f ./*.freeze
wasm32-wasi-cabal --project-file=cabal-wasm.project build all
popd
