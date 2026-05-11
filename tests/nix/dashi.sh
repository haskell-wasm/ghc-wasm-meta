#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

git clone --depth=1 https://github.com/ners/dashi.git .

nix flake lock --allow-dirty-locks --override-input nix-wasm/ghc-wasm-meta "git+file://$CI_PROJECT_DIR"

nix build --json --no-link

. <(nix print-dev-env .)

exec wasm32-wasi-cabal build exe:dashi
