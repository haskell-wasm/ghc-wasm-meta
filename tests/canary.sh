#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
curl -L https://github.com/haskell-wasm/canary/archive/refs/heads/master.tar.gz | tar xz --strip-components=1
cp $CI_PROJECT_DIR/cabal.project.local .
./util/ci
popd
