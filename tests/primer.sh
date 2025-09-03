#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

git clone --depth=1 https://github.com/hackworthltd/primer.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm "git+file://$CI_PROJECT_DIR"

nix develop .#wasm -c make -f Makefile.wasm32 update

nix run nixpkgs#gnused -- -i -e "s/\$ncpus/$CPUS/" "$HOME/.ghc-wasm/.cabal/config"

nix develop .#wasm -c make -f Makefile.wasm32 frontend-prod

popd
