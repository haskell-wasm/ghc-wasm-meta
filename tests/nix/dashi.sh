#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

git clone --depth=1 https://github.com/ners/dashi.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm-meta "git+file://$CI_PROJECT_DIR"

NIXPKGS_ALLOW_BROKEN=1 nix build --impure --json --no-link

popd
