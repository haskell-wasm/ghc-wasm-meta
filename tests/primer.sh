#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

git clone --depth=1 https://github.com/hackworthltd/primer.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm "git+file://$CI_PROJECT_DIR"

. <(nix print-dev-env .#wasm)

make -f Makefile.wasm32 frontend-prod

popd
