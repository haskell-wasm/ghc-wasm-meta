#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"

git clone --depth=1 https://github.com/brakubraku/ding-dong.git .

nix flake lock --allow-dirty-locks --override-input ghc-wasm "git+file://$CI_PROJECT_DIR"

nix develop -c wasm32-wasi-cabal update

nix run nixpkgs#gnused -- -i -e "s/\$ncpus/$CPUS/" "$HOME/.ghc-wasm/.cabal/config"

nix shell nixpkgs#pkg-config -c nix develop -c bash -c "cd frontend && exec ./build.sh"

popd
