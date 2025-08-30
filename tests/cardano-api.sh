#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

git clone --depth=1 https://github.com/IntersectMBO/cardano-api.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm-meta "git+file://$CI_PROJECT_DIR"

nix develop .#wasm -c bash -c "exec wasm32-wasi-cabal update"

nix run nixpkgs#gnused -- -i -e "s/\$ncpus/$CPUS/" "$HOME/.ghc-wasm/.cabal/config"

nix develop .#wasm -c bash -c "exec wasm32-wasi-cabal build cardano-wasm"

popd
