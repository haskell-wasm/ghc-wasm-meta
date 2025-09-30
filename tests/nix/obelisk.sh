#!/usr/bin/env bash

set -euo pipefail

pushd "$(mktemp -d)"
git clone --depth=1 --branch maralorn/new-backend-wasm https://github.com/obsidiansystems/obelisk.git .
nix shell nixpkgs#haskellPackages.nix-thunk -c nix-thunk unpack dep/reflex-platform
nix shell nixpkgs#haskellPackages.nix-thunk -c nix-thunk unpack dep/reflex-platform/nix-wasm
pushd dep/reflex-platform/nix-wasm
nix flake lock --allow-dirty-locks --override-input ghc-wasm-meta "git+file://$CI_PROJECT_DIR"
popd
nix build -f ./skeleton ghcwasm.frontend
popd
