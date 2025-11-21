#!/usr/bin/env bash

set -euo pipefail

cd "$(mktemp -d)"

git clone --depth=1 https://github.com/brakubraku/ding-dong.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm "git+file://$CI_PROJECT_DIR"

. <(nix print-dev-env .)

exec nix shell nixpkgs#pkg-config -c bash -c "cd frontend && exec ./build.sh"
